import Image from 'next/image';
import symbolStyles from './lead-emergence-symbol.module.css';

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

const frames = [
  '/brand/roadmap/stage-01-see-alpha.png',
  '/brand/roadmap/stage-02-reframe-alpha.png',
  '/brand/roadmap/stage-03-align-alpha.png',
  '/brand/roadmap/stage-04-build-alpha.png',
  '/brand/roadmap/stage-05-produce-alpha.png',
  '/brand/roadmap/stage-06-new-reality-alpha.png',
  '/brand/roadmap/stage-07-see-again-alpha.png',
] as const;

function clamp(value: number) {
  return Math.max(0, Math.min(1, value));
}

export function LeadEmergenceSymbol({ progress, className, title = 'Lead Emergence symbol' }: LeadEmergenceSymbolProps) {
  const opacities = [
    progress.seed * (1 - progress.structure),
    progress.structure * (1 - progress.arc),
    progress.arc * (1 - progress.rays),
    progress.rays * (1 - progress.pathway),
    progress.pathway * (1 - progress.resolved),
    progress.resolved * (1 - progress.cycle),
    progress.cycle,
  ].map(clamp);

  return (
    <span className={`${symbolStyles.root} ${className ?? ''}`} role="img" aria-label={title}>
      {frames.map((source, index) => (
        <Image
          alt=""
          aria-hidden="true"
          className={symbolStyles.frame}
          fill
          key={source}
          priority
          sizes="(max-width: 720px) 90vw, 42vw"
          src={source}
          style={{ opacity: opacities[index] }}
        />
      ))}
    </span>
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
