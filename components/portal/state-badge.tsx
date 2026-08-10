import type { ReviewState } from '@/lib/portal/types';

export function StateBadge({ state }: { state: ReviewState }) {
  const className = state.toLowerCase().replaceAll(' ', '-');
  return <span className={`state-badge state-${className}`}>{state}</span>;
}

export function StateLegend() {
  const states: ReviewState[] = ['AI SUGGESTION', 'INTERPRETATION', 'VALIDATED INSIGHT', 'DECISION'];
  return (
    <section className="state-legend" aria-label="Knowledge state legend">
      <p className="eyebrow">How to read this workspace</p>
      <div className="legend-items">
        {states.map((state) => <StateBadge key={state} state={state} />)}
      </div>
      <p>Suggestions invite review. Interpretations propose meaning. Insights are human-validated. Decisions record authorized choices.</p>
    </section>
  );
}
