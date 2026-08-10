import type { CSSProperties } from 'react';

export type SymbolProgress = {
  seed: number;
  structure: number;
  arc: number;
  rays: number;
  pathway: number;
  resolved: number;
  cycle: number;
};

type LeadEmergenceSymbolProps = {
  progress: SymbolProgress;
  className?: string;
  title?: string;
};

const rayAngles = Array.from({ length: 25 }, (_, index) => 198 + index * 6);

function pointOnCircle(angle: number, radius: number) {
  const radians = (angle * Math.PI) / 180;
  return {
    x: Number((320 + Math.cos(radians) * radius).toFixed(3)),
    y: Number((285 + Math.sin(radians) * radius).toFixed(3)),
  };
}

export function LeadEmergenceSymbol({ progress, className, title = 'Lead Emergence symbol' }: LeadEmergenceSymbolProps) {
  const triangleOffset = 1 - progress.structure;
  const arcOffset = 1 - progress.arc;
  const pathwayOffset = 1 - progress.pathway;
  const symbolOpacity = 1 - progress.cycle * 0.63;
  const symbolTransform = `translate(0 ${progress.cycle * 28}) scale(${1 - progress.cycle * 0.18})`;
  const style = { '--resolve': progress.resolved } as CSSProperties;

  return (
    <svg className={className} style={style} viewBox="0 0 640 640" role="img" aria-label={title}>
      <defs>
        <linearGradient id="le-blue-plane" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#66dfff" />
          <stop offset="0.42" stopColor="#1267b4" />
          <stop offset="1" stopColor="#07284f" />
        </linearGradient>
        <linearGradient id="le-blue-deep" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#178bd6" />
          <stop offset="1" stopColor="#05162f" />
        </linearGradient>
        <linearGradient id="le-white-path" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#ffffff" />
          <stop offset="0.48" stopColor="#a6ddff" />
          <stop offset="1" stopColor="#2474bd" />
        </linearGradient>
        <linearGradient id="le-gold" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#ffd878" />
          <stop offset="1" stopColor="#d18b16" />
        </linearGradient>
        <radialGradient id="le-point" cx="50%" cy="50%" r="50%">
          <stop offset="0" stopColor="#f7fdff" />
          <stop offset="0.2" stopColor="#78e8ff" />
          <stop offset="0.58" stopColor="#168fd8" stopOpacity="0.6" />
          <stop offset="1" stopColor="#168fd8" stopOpacity="0" />
        </radialGradient>
        <filter id="le-glow" x="-80%" y="-80%" width="260%" height="260%">
          <feGaussianBlur stdDeviation="8" result="blur" />
          <feMerge><feMergeNode in="blur" /><feMergeNode in="SourceGraphic" /></feMerge>
        </filter>
        <filter id="le-soft-glow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="4" result="blur" />
          <feMerge><feMergeNode in="blur" /><feMergeNode in="SourceGraphic" /></feMerge>
        </filter>
      </defs>

      <g opacity={symbolOpacity} transform={symbolTransform} style={{ transformOrigin: '320px 300px' }}>
        <g opacity={progress.rays}>
          {rayAngles.map((angle, index) => {
            const inner = pointOnCircle(angle, 190);
            const outer = pointOnCircle(angle, index % 2 === 0 ? 226 : 214);
            return (
              <line
                key={angle}
                x1={inner.x}
                y1={inner.y}
                x2={outer.x}
                y2={outer.y}
                stroke="url(#le-gold)"
                strokeLinecap="round"
                strokeWidth={index % 2 === 0 ? 2.2 : 1.4}
                opacity={Math.max(0, Math.min(1, progress.rays * 1.8 - index / rayAngles.length))}
              />
            );
          })}
        </g>

        <path d="M 165 304 A 174 174 0 1 1 475 304" fill="none" stroke="url(#le-gold)" strokeDasharray="1" strokeDashoffset={arcOffset} pathLength="1" strokeLinecap="round" strokeWidth="5" opacity={progress.arc} filter="url(#le-soft-glow)" />

        <g opacity={progress.pathway}>
          <path d="M 320 270 L 91 558 L 265 470 Z" fill="url(#le-blue-deep)" opacity="0.52" />
          <path d="M 320 270 L 549 558 L 375 470 Z" fill="url(#le-blue-deep)" opacity="0.52" />
          <path d="M 265 470 L 91 558 L 252 528 L 320 302 Z" fill="#0b4a89" opacity="0.72" />
          <path d="M 375 470 L 549 558 L 388 528 L 320 302 Z" fill="#0b4a89" opacity="0.72" />
          <path d="M 320 283 C 313 345 299 409 264 541" fill="none" stroke="#41bdf3" strokeDasharray="1" strokeDashoffset={pathwayOffset} pathLength="1" strokeLinecap="round" strokeWidth="3" opacity="0.78" />
          <path d="M 320 283 C 327 345 341 409 376 541" fill="none" stroke="#41bdf3" strokeDasharray="1" strokeDashoffset={pathwayOffset} pathLength="1" strokeLinecap="round" strokeWidth="3" opacity="0.78" />
        </g>

        <g opacity={progress.resolved}>
          <path d="M 320 270 L 144 489 L 286 398 Z" fill="url(#le-blue-plane)" />
          <path d="M 320 270 L 496 489 L 354 398 Z" fill="url(#le-blue-deep)" />
          <path d="M 320 270 L 286 398 L 320 372 L 354 398 Z" fill="url(#le-white-path)" />
          <path d="M 320 372 L 270 515 L 320 473 L 370 515 Z" fill="url(#le-white-path)" opacity="0.9" />
          <path d="M 270 515 L 121 573 L 238 557 Z" fill="#08213d" opacity="0.94" />
          <path d="M 370 515 L 519 573 L 402 557 Z" fill="#08213d" opacity="0.94" />
        </g>

        <g opacity={progress.structure}>
          <path d="M 320 270 L 126 506" fill="none" stroke="#2f9de1" strokeDasharray="1" strokeDashoffset={triangleOffset} pathLength="1" strokeLinecap="round" strokeWidth="3" />
          <path d="M 320 270 L 514 506" fill="none" stroke="#2f9de1" strokeDasharray="1" strokeDashoffset={triangleOffset} pathLength="1" strokeLinecap="round" strokeWidth="3" />
        </g>

        <g opacity={progress.seed} filter="url(#le-glow)">
          <circle cx="320" cy="270" r="34" fill="url(#le-point)" />
          <circle cx="320" cy="270" r="7" fill="#78e8ff" />
          <circle cx="320" cy="270" r="2.5" fill="#ffffff" />
        </g>
      </g>

      <g opacity={progress.cycle} filter="url(#le-glow)">
        <circle cx="320" cy="118" r="38" fill="url(#le-point)" />
        <circle cx="320" cy="118" r="7" fill="#78e8ff" />
        <circle cx="320" cy="118" r="2.5" fill="#ffffff" />
      </g>
    </svg>
  );
}

export const completeSymbolProgress: SymbolProgress = {
  seed: 1,
  structure: 1,
  arc: 1,
  rays: 1,
  pathway: 1,
  resolved: 1,
  cycle: 0,
};
