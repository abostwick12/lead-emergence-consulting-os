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

const sourceFrames = [
  '/brand/roadmap/mock-stage-01-see-v10.png',
  '/brand/roadmap/mock-stage-02-reframe-v10.png',
  '/brand/roadmap/mock-stage-03-align-v10.png',
  '/brand/roadmap/mock-stage-04-build-v10.png',
  '/brand/roadmap/mock-stage-05-produce-v10.png',
  '/brand/roadmap/mock-stage-06-new-reality-v10.png',
  '/brand/roadmap/mock-stage-07-see-again-v10.png',
] as const;

function clamp(value: number) {
  if (!Number.isFinite(value)) return 0;
  return Math.max(0, Math.min(1, value));
}

export function LeadEmergenceSymbol({ progress, className, title = 'Lead Emergence symbol' }: LeadEmergenceSymbolProps) {
  const frameIndex = clamp(progress.cycle) >= 0.5 ? 6
    : clamp(progress.resolved) >= 0.5 ? 5
      : clamp(progress.arc) >= 0.5 ? 4
        : clamp(progress.pathway) >= 0.5 ? 3
          : clamp(progress.structure) >= 0.5 ? 2
            : clamp(progress.stem) >= 0.5 ? 1
              : 0;

  return (
    <span className={`${symbolStyles.root} ${className ?? ''}`} role="img" aria-label={title}>
      <Image
        alt=""
        aria-hidden="true"
        className={symbolStyles.frame}
        fill
        priority
        sizes="(max-width: 720px) 90vw, 42vw"
        src={sourceFrames[frameIndex]}
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
