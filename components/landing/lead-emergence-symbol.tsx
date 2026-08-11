import Image from 'next/image';
import symbolStyles from './lead-emergence-symbol.module.css';

export type SymbolProgress = {
  seed: number;
  stem: number;
  structure: number;
  pathway: number;
  arc: number;
  rays: number;
  resolved: number;
  cycle: number;
};

type LeadEmergenceSymbolProps = {
  progress: SymbolProgress;
  className?: string;
  title?: string;
};

const buildLayers = [
  { source: '/brand/roadmap/symbol-seed-v6.png', progress: 'seed' },
  { source: '/brand/roadmap/symbol-stem-v6.png', progress: 'stem' },
  { source: '/brand/roadmap/symbol-structure-v6.png', progress: 'structure' },
  { source: '/brand/roadmap/symbol-pathway-v6.png', progress: 'pathway' },
  { source: '/brand/roadmap/symbol-arc-v6.png', progress: 'arc' },
  { source: '/brand/roadmap/symbol-rays-v6.png', progress: 'rays' },
] as const satisfies ReadonlyArray<{ source: string; progress: keyof SymbolProgress }>;

function clamp(value: number) {
  if (!Number.isFinite(value)) return 0;
  return Math.max(0, Math.min(1, value));
}

export function LeadEmergenceSymbol({ progress, className, title = 'Lead Emergence symbol' }: LeadEmergenceSymbolProps) {
  const cycleOpacity = clamp(progress.cycle);
  const resolvedOpacity = clamp(progress.resolved) * (1 - cycleOpacity * 0.45);
  const buildOpacity = (1 - clamp(progress.resolved)) * (1 - cycleOpacity);
  const resolvedScale = 1 - cycleOpacity * 0.32;
  const resolvedOffset = cycleOpacity * 10;

  return (
    <span className={`${symbolStyles.root} ${className ?? ''}`} role="img" aria-label={title}>
      {buildLayers.map(({ source, progress: progressKey }) => (
        <Image
          alt=""
          aria-hidden="true"
          className={symbolStyles.frame}
          fill
          key={progressKey}
          priority
          sizes="(max-width: 720px) 90vw, 42vw"
          src={source}
          style={{ opacity: clamp(progress[progressKey]) * buildOpacity }}
          unoptimized
        />
      ))}
      <Image
        alt=""
        aria-hidden="true"
        className={`${symbolStyles.frame} ${symbolStyles.resolvedFrame}`}
        fill
        priority
        sizes="(max-width: 720px) 90vw, 42vw"
        src="/brand/roadmap/symbol-resolved-v6.png"
        style={{ opacity: resolvedOpacity, transform: `translateY(${resolvedOffset}%) scale(${resolvedScale})` }}
        unoptimized
      />
      <Image
        alt=""
        aria-hidden="true"
        className={`${symbolStyles.frame} ${symbolStyles.cycleSeed}`}
        fill
        priority
        sizes="(max-width: 720px) 90vw, 42vw"
        src="/brand/roadmap/symbol-seed-v6.png"
        style={{ opacity: cycleOpacity }}
        unoptimized
      />
    </span>
  );
}

export const completeSymbolProgress: SymbolProgress = {
  seed: 1,
  stem: 1,
  structure: 1,
  pathway: 1,
  arc: 1,
  rays: 1,
  resolved: 1,
  cycle: 0,
};
