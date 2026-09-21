// lib/widgets/monera_atm_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../models/card_model.dart';
import 'monera_logo.dart';

class MoneraAtmCard extends StatefulWidget {
  final CardModel card;
  final bool isFlipped;
  final VoidCallback? onFlip;
  final VoidCallback? onFreezeToggle;
  final VoidCallback? onSettingsTap;

  const MoneraAtmCard({
    super.key,
    required this.card,
    this.isFlipped = false,
    this.onFlip,
    this.onFreezeToggle,
    this.onSettingsTap,
  });

  @override
  State<MoneraAtmCard> createState() => _MoneraAtmCardState();
}

class _MoneraAtmCardState extends State<MoneraAtmCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBack = false;
  bool _isPanUnmasked = false;

  @override
  void initState() {
    super.initState();
    _showBack = widget.isFlipped;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
    _animation.addListener(() {
      if (_animation.value >= 0.5 && !_showBack) {
        setState(() => _showBack = true);
      } else if (_animation.value < 0.5 && _showBack) {
        setState(() => _showBack = false);
      }
    });

    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant MoneraAtmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFlipped != widget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFlip() {
    HapticFeedback.lightImpact();
    if (widget.onFlip != null) {
      widget.onFlip!();
    } else {
      if (_controller.isCompleted || _controller.value > 0.5) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhysical = widget.card.type == 'physical';
    final isFrozen = widget.card.isFrozen;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * math.pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0015) // Perspective
          ..rotateY(angle);

        return GestureDetector(
          onTap: _handleFlip,
          child: Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _showBack
                ? Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: _buildCardBack(isPhysical, isFrozen),
                  )
                : _buildCardFront(isPhysical, isFrozen),
          ),
        );
      },
    );
  }

  Widget _buildCardFront(bool isPhysical, bool isFrozen) {
    return Container(
      width: double.infinity,
      height: 228,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: _getCardGradient(isPhysical, isFrozen),
        border: Border.all(
          color: isFrozen
              ? Colors.white.withValues(alpha: 0.25)
              : (isPhysical
                  ? const Color(0xFF94A3B8).withValues(alpha: 0.4)
                  : AppColors.lime.withValues(alpha: 0.5)),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: isFrozen
                ? Colors.black.withValues(alpha: 0.4)
                : (isPhysical
                    ? Colors.black.withValues(alpha: 0.55)
                    : AppColors.darkGreen.withValues(alpha: 0.45)),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Watermark: Large faint Monera Emblem
            const Positioned(
              right: -30,
              bottom: -35,
              child: Opacity(
                opacity: 0.08,
                child: MoneraLogo(
                  size: 210,
                  color: Colors.white,
                ),
              ),
            ),

            // Diagonal metallic light reflection
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.45, 0.5, 1.0],
                    colors: [
                      Colors.white.withValues(alpha: 0.09),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Card Foreground Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Bar: Monera Logo + Status Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Monera Horizontal Logo with Emblem & Wordmark
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MoneraLogo(
                            variant: MoneraLogoVariant.horizontal,
                            size: 22,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPhysical ? 'TITANIUM' : 'VIRTUAL',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Active / Frozen Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFrozen
                              ? AppColors.crimsonRed.withValues(alpha: 0.28)
                              : AppColors.lime.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isFrozen
                                ? AppColors.crimsonRed
                                : AppColors.lime,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isFrozen
                                    ? Colors.redAccent
                                    : AppColors.lime,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isFrozen ? 'FROZEN' : 'ACTIVE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Middle Row: EMV Chip & Contactless Waves
                  Row(
                    children: [
                      const _EmvChipWidget(),
                      const SizedBox(width: 14),
                      Icon(
                        Icons.contactless_outlined,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 22,
                      ),
                      const Spacer(),
                      const Text(
                        'SUDO JIT • MONAD L1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),

                  // Card Number (Masked or Unmasked)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isPanUnmasked
                            ? '5399 4819 2038 ${widget.card.last4}'
                            : widget.card.maskedPan,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.8,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isPanUnmasked = !_isPanUnmasked;
                          });
                        },
                        child: Icon(
                          _isPanUnmasked
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Row: Cardholder Name, Expiry & Mastercard Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CARDHOLDER',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.card.cardholderName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VALID THRU',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.card.expiryMonth}/${widget.card.expiryYear}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const _MastercardEmblem(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(bool isPhysical, bool isFrozen) {
    return Container(
      width: double.infinity,
      height: 228,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: _getCardGradient(isPhysical, isFrozen),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Black Magnetic Stripe
            Container(
              width: double.infinity,
              height: 42,
              color: const Color(0xFF111111),
            ),
            const SizedBox(height: 18),
            // Signature Strip & CVV
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEFF1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'AUTHORIZED SIGNATURE • NOT VALID UNLESS SIGNED',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'CVV ',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const Text(
                          '891',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(const ClipboardData(text: '891'));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('CVV copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Icon(Icons.copy,
                              size: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Legal & Monad L1 Specs
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Issued by Sudo Africa pursuant to license from Mastercard International.\n'
                      'Direct settlement via Monad L1 (Chain ID: 10143) treasury ledger.\n'
                      '24/7 JIT Authorization with <200ms latency SLO.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  _MastercardEmblem(isSmall: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getCardGradient(bool isPhysical, bool isFrozen) {
    if (isFrozen) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF334155),
          Color(0xFF1E293B),
          Color(0xFF0F172A),
        ],
      );
    }
    if (isPhysical) {
      // Premium Matte Titanium / Obsidian Black
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF27272A),
          Color(0xFF18181B),
          Color(0xFF09090B),
        ],
      );
    }
    // High-End Emerald & Monera Deep Forest Green
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0A4D3B),
        Color(0xFF063D2E),
        Color(0xFF021B14),
      ],
    );
  }
}

/// Realistic metallic gold EMV chip with circuitry pattern
class _EmvChipWidget extends StatelessWidget {
  const _EmvChipWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFDF79),
            Color(0xFFD4AF37),
            Color(0xFFAA8014),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ChipCircuitPainter(),
      ),
    );
  }
}

class _ChipCircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7D5F00).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final w = size.width;
    final h = size.height;

    // Outer chip rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 3, w - 8, h - 6),
        const Radius.circular(3),
      ),
      paint,
    );

    // Microchip contact dividing lines
    canvas.drawLine(Offset(4, h * 0.45), Offset(w - 4, h * 0.45), paint);
    canvas.drawLine(Offset(w * 0.35, 3), Offset(w * 0.35, h - 3), paint);
    canvas.drawLine(Offset(w * 0.65, 3), Offset(w * 0.65, h - 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Authentic dual interlocking circles Mastercard emblem
class _MastercardEmblem extends StatelessWidget {
  final bool isSmall;

  const _MastercardEmblem({this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final radius = isSmall ? 10.0 : 14.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: const BoxDecoration(
            color: Color(0xFFEB001B), // Mastercard Red
            shape: BoxShape.circle,
          ),
        ),
        Transform.translate(
          offset: Offset(-radius * 0.75, 0),
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: const Color(0xFFF79E1B)
                  .withValues(alpha: 0.88), // Mastercard Amber
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
