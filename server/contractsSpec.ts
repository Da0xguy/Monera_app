/**
 * Smart Contract Layer & Architectural Flow Specifications
 * As specified in Section 4 & Section 1 of Monera Tech Spec Doc
 */

export const ASCII_SEQUENCE_DIAGRAMS = {
  sudoJitAuth: `
+----------------------------------------------------------------------------------------------------+
|                         SUDO AFRICA JUST-IN-TIME (JIT) AUTHORIZATION FLOW                          |
+----------------------------------------------------------------------------------------------------+

 Cardholder          POS / Merchant         Sudo Africa          Monera Backend          Monad L1
     │                      │                     │                     │                     │
     │ 1. Tap Mastercard    │                     │                     │                     │
     ├─────────────────────>│                     │                     │                     │
     │                      │ 2. Auth Request     │                     │                     │
     │                      ├────────────────────>│                     │                     │
     │                      │                     │ 3. POST JIT Webhook │                     │
     │                      │                     │    (HMAC Signature) │                     │
     │                      │                     ├────────────────────>│                     │
     │                      │                     │                     │ 4. Verify Signature │
     │                      │                     │                     │    & Parse Zod      │
     │                      │                     │                     │                     │
     │                      │                     │                     │ 5. Acquire Card Lock│
     │                      │                     │                     │    (Prevent Races)  │
     │                      │                     │                     │                     │
     │                      │                     │                     │ 6. Check Off-Chain  │
     │                      │                     │                     │    Ledger Balance   │
     │                      │                     │                     │                     │
     │                      │                     │                     │ 7. Atomic Hold/Debit│
     │                      │                     │                     │    Ledger Account   │
     │                      │                     │ 8. HTTP 200 JSON    │                     │
     │                      │                     │    {code: "00"}     │                     │
     │                      │                     │<────────────────────┤ [SLO < 200ms]       │
     │                      │ 9. Approve Swipe    │                     │                     │
     │                      │<────────────────────┤                     │                     │
     │ 10. Receipt Printed  │                     │                     │                     │
     │<─────────────────────┤                     │                     │                     │
     │                      │                     │                     │                     │
     │                      │                     │                     │ 11. Async Batch     │
     │                      │                     │                     │     Anchor on Monad │
     │                      │                     │                     ├────────────────────>│
     │                      │                     │                     │                     │
`,

  nibssNqr: `
+----------------------------------------------------------------------------------------------------+
|                         NIBSS NQR MERCHANT SCAN-TO-PAY & SETTLEMENT                                |
+----------------------------------------------------------------------------------------------------+

 Customer App         Merchant Terminal        Monera Backend            NIBSS NIP Rail        Monad L1
     │                       │                        │                        │                  │
     │ 1. Scan NQR Code      │                        │                        │                  │
     ├──────────────────────>│                        │                        │                  │
     │ 2. Resolve Payload    │                        │                        │                  │
     │    (Merchant ID)      │                        │                        │                  │
     ├───────────────────────────────────────────────>│                        │                  │
     │ 3. Confirm with PIN   │                        │                        │                  │
     ├───────────────────────────────────────────────>│                        │                  │
     │                       │                        │ 4. Debit Stablecoin    │                  │
     │                       │                        │    Off-Chain Ledger    │                  │
     │                       │                        │                        │                  │
     │                       │                        │ 5. Trigger NGN Payout  │                  │
     │                       │                        ├───────────────────────>│                  │
     │                       │ 6. Merchant Credit     │                        │                  │
     │                       │<────────────────────────────────────────────────┤                  │
     │ 7. Instant Success    │                        │                        │                  │
     │<───────────────────────────────────────────────┤                        │                  │
     │                       │                        │ 8. Periodic State      │                  │
     │                       │                        │    Settlement Anchor   ├─────────────────>│
`,

  nonCustodialPrivy: `
+----------------------------------------------------------------------------------------------------+
|                      NON-CUSTODIAL EMBEDDED WALLET ARCHITECTURE (PRIVY)                            |
+----------------------------------------------------------------------------------------------------+

  User Device                     Privy Secure Enclave                    Monera Backend
  [Passkey / SMS / Google]          [Threshold Cryptography]                [Zero Private Keys]
         │                                   │                                      │
         │ 1. Passkey / OTP Auth             │                                      │
         ├──────────────────────────────────>│                                      │
         │ 2. Sub-key Share Generated        │                                      │
         │<──────────────────────────────────┤                                      │
         │ 3. Send Privy Session Token       │                                      │
         ├─────────────────────────────────────────────────────────────────────────>│
         │                                   │                                      │ 4. Verify Session
         │                                   │                                      │    Store Monad Address
         │                                   │                                      │    (No Private Key!)
         │                                   │                                      │
`
};

export const CONTRACT_TREASURY_VAULT_SOLIDITY = `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TreasuryVault
 * @author Monera / The3rdWebLabs
 * @notice Holds pooled idle stablecoin balances opted into Earn on Monad L1.
 *         Integrates with Monad-native yield sources and tracks per-user share accounting.
 * @dev Non-custodial vault utilizing ERC-4626 standard yield tokenization.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface ITreasuryVault {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares);
    event YieldHarvested(uint256 yieldAmount, uint256 timestamp);

    function asset() external view returns (address assetTokenAddress);
    function totalAssets() external view returns (uint256 totalManagedAssets);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
}

contract TreasuryVault is ITreasuryVault {
    IERC20 public immutable underlyingAsset;
    string public name = "Monera Earn Vault Share";
    string public symbol = "mvUSD";
    uint8 public immutable decimals = 6;

    uint256 public totalVaultShares;
    mapping(address => uint256) public shareBalances;
    mapping(address => mapping(address => uint256)) public allowances;

    address public immutable backendRelayer;
    address public immutable emergencyMultisig;
    bool public isPaused;

    modifier onlyRelayerOrMultisig() {
        require(msg.sender == backendRelayer || msg.sender == emergencyMultisig, "UNAUTHORIZED");
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused, "VAULT_PAUSED");
        _;
    }

    constructor(address _asset, address _backendRelayer, address _emergencyMultisig) {
        require(_asset != address(0) && _backendRelayer != address(0), "INVALID_ADDRESS");
        underlyingAsset = IERC20(_asset);
        backendRelayer = _backendRelayer;
        emergencyMultisig = _emergencyMultisig;
    }

    function asset() external view override returns (address) {
        return address(underlyingAsset);
    }

    function totalAssets() public view override returns (uint256) {
        return underlyingAsset.balanceOf(address(this));
    }

    function convertToShares(uint256 assets) public view override returns (uint256) {
        uint256 currentAssets = totalAssets();
        if (totalVaultShares == 0 || currentAssets == 0) {
            return assets;
        }
        return (assets * totalVaultShares) / currentAssets;
    }

    function convertToAssets(uint256 shares) public view override returns (uint256) {
        if (totalVaultShares == 0) {
            return shares;
        }
        return (shares * totalAssets()) / totalVaultShares;
    }

    function deposit(uint256 assets, address receiver) external override whenNotPaused returns (uint256 shares) {
        require(assets > 0, "ZERO_ASSETS");
        shares = convertToShares(assets);
        require(shares > 0, "ZERO_SHARES");

        underlyingAsset.transferFrom(msg.sender, address(this), assets);

        totalVaultShares += shares;
        shareBalances[receiver] += shares;

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function withdraw(uint256 assets, address receiver, address owner) external override returns (uint256 shares) {
        require(assets > 0, "ZERO_ASSETS");
        shares = convertToShares(assets);
        
        if (msg.sender != owner) {
            uint256 allowed = allowances[owner][msg.sender];
            require(allowed >= shares, "INSUFFICIENT_ALLOWANCE");
            allowances[owner][msg.sender] = allowed - shares;
        }

        require(shareBalances[owner] >= shares, "INSUFFICIENT_BALANCE");
        shareBalances[owner] -= shares;
        totalVaultShares -= shares;

        underlyingAsset.transfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
}
`;

export const CONTRACT_SETTLEMENT_ANCHOR_SOLIDITY = `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title SettlementAnchor
 * @author Monera / The3rdWebLabs
 * @notice Periodically anchors batches of off-chain ledger states and Sudo/NQR settlement events
 *         on Monad L1 (~600ms finality) for immutable auditability and dispute resolution.
 */
contract SettlementAnchor {
    struct SettlementBatch {
        bytes32 merkleRoot;
        uint256 totalVolumeUsd;
        uint32 txCount;
        uint64 timestamp;
        string ipfsAuditCid;
    }

    address public immutable relayer;
    address public immutable governor;
    uint256 public batchCount;
    mapping(uint256 => SettlementBatch) public settlementBatches;

    event BatchAnchored(
        uint256 indexed batchId,
        bytes32 indexed merkleRoot,
        uint256 totalVolumeUsd,
        uint32 txCount,
        uint64 timestamp,
        string ipfsAuditCid
    );

    constructor(address _relayer, address _governor) {
        relayer = _relayer;
        governor = _governor;
    }

    function anchorBatch(
        bytes32 _merkleRoot,
        uint256 _totalVolumeUsd,
        uint32 _txCount,
        string calldata _ipfsAuditCid
    ) external returns (uint256 newBatchId) {
        require(msg.sender == relayer || msg.sender == governor, "UNAUTHORIZED_RELAYER");
        require(_merkleRoot != bytes32(0), "INVALID_ROOT");

        newBatchId = ++batchCount;
        settlementBatches[newBatchId] = SettlementBatch({
            merkleRoot: _merkleRoot,
            totalVolumeUsd: _totalVolumeUsd,
            txCount: _txCount,
            timestamp: uint64(block.timestamp),
            ipfsAuditCid: _ipfsAuditCid
        });

        emit BatchAnchored(newBatchId, _merkleRoot, _totalVolumeUsd, _txCount, uint64(block.timestamp), _ipfsAuditCid);
    }
}
`;
