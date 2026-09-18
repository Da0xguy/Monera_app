import React from 'react';

interface MoneraLogoProps {
  className?: string;
  size?: number | string;
  variant?: 'full' | 'icon' | 'horizontal';
  color?: 'white' | 'blue' | 'black' | 'current';
}

export const MoneraLogo: React.FC<MoneraLogoProps> = ({
  className = '',
  size = 36,
  variant = 'icon',
  color = 'current',
}) => {
  const colorClass =
    color === 'white'
      ? 'text-white'
      : color === 'blue'
      ? 'text-cyan-400'
      : color === 'black'
      ? 'text-black'
      : 'text-current';

  if (variant === 'icon') {
    return (
      <svg
        viewBox="0 0 260 210"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ width: size, height: typeof size === 'number' ? (size * 210) / 260 : undefined }}
        className={`inline-block shrink-0 ${colorClass} ${className}`}
      >
        <g fill="currentColor">
          {/* Central Inverted Triangle */}
          <polygon points="88,10 172,10 130,78" />

          {/* Outer Winged M Chevron */}
          <polygon points="10,10 66,10 130,110 194,10 250,10 130,195" />

          {/* Left Flanking Triangle (Pointing UP) */}
          <polygon points="32,108 5,150 59,150" />

          {/* Right Flanking Triangle (Pointing UP) */}
          <polygon points="228,108 201,150 255,150" />
        </g>
      </svg>
    );
  }

  if (variant === 'horizontal') {
    return (
      <div className={`inline-flex items-center gap-2.5 ${colorClass} ${className}`}>
        <svg
          viewBox="0 0 260 210"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          style={{ width: size, height: typeof size === 'number' ? (size * 210) / 260 : undefined }}
          className="shrink-0"
        >
          <g fill="currentColor">
            <polygon points="88,10 172,10 130,78" />
            <polygon points="10,10 66,10 130,110 194,10 250,10 130,195" />
            <polygon points="32,108 5,150 59,150" />
            <polygon points="228,108 201,150 255,150" />
          </g>
        </svg>
        <span
          className="font-extrabold tracking-wider font-sans uppercase leading-none"
          style={{ fontSize: typeof size === 'number' ? size * 0.75 : '1.25rem' }}
        >
          MONERA
        </span>
      </div>
    );
  }

  // variant === 'full' (emblem on top, MONERA underneath)
  return (
    <svg
      viewBox="0 0 260 270"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      style={{ width: size, height: typeof size === 'number' ? (size * 270) / 260 : undefined }}
      className={`inline-block shrink-0 ${colorClass} ${className}`}
    >
      <g fill="currentColor">
        {/* Central Inverted Triangle */}
        <polygon points="88,10 172,10 130,78" />

        {/* Outer Winged M Chevron */}
        <polygon points="10,10 66,10 130,110 194,10 250,10 130,195" />

        {/* Left Flanking Triangle */}
        <polygon points="32,108 5,150 59,150" />

        {/* Right Flanking Triangle */}
        <polygon points="228,108 201,150 255,150" />

        {/* MONERA Wordmark */}
        <text
          x="130"
          y="250"
          fontFamily="'Plus Jakarta Sans', 'Montserrat', 'Arial Black', sans-serif"
          fontWeight="900"
          fontSize="40"
          textAnchor="middle"
          letterSpacing="2.5"
        >
          MONERA
        </text>
      </g>
    </svg>
  );
};
