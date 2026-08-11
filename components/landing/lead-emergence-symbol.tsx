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
  '/brand/roadmap/mock-stage-01-see-v9.png',
  '/brand/roadmap/mock-stage-02-reframe-v9.png',
  '/brand/roadmap/mock-stage-03-align-v9.png',
  '/brand/roadmap/mock-stage-04-build-v9.png',
  '/brand/roadmap/mock-stage-05-produce-v9.png',
  '/brand/roadmap/mock-stage-06-new-reality-v9.png',
  '/brand/roadmap/mock-stage-07-see-again-v9.png',
] as const;

function clamp(value: number) {
  if (!Number.isFinite(value)) return 0;
  return Math.max(0, Math.min(1, value));
}

export function LeadEmergenceSymbol({ progress, className, title = 'Lead Emergence symbol' }: LeadEmergenceSymbolProps) {
  const stem = clamp(progress.stem);
  const structure = clamp(progress.structure);
  const pathway = clamp(progress.pathway);
  const arc = clamp(progress.arc);
  const resolved = clamp(progress.resolved);
  const cycle = clamp(progress.cycle);
  const frameOpacity = [
    1 - stem,
    stem * (1 - structure),
    structure * (1 - pathway),
    pathway * (1 - arc),
    arc * (1 - resolved),
    resolved * (1 - cycle),
    cycle,
  ];

  return (
    <span className={`${symbolStyles.root} ${className ?? ''}`} role="img" aria-label={title}>
      {sourceFrames.map((source, index) => (
        <Image
          alt=""
          aria-hidden="true"
          className={symbolStyles.frame}
          fill
          key={source}
          priority
          sizes="(max-width: 720px) 90vw, 42vw"
          src={source}
          style={{ opacity: frameOpacity[index] }}
          unoptimized
        />
      ))}
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
