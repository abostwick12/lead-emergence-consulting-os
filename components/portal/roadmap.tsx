import type { RoadmapStage } from '@/lib/portal/types';

export function Roadmap({ stages }: { stages: RoadmapStage[] }) {
  return (
    <section className="roadmap-section" aria-labelledby="roadmap-heading">
      <div className="section-heading">
        <div>
          <p className="eyebrow">Emergence roadmap</p>
          <h2 id="roadmap-heading">One journey, seven connected movements</h2>
        </div>
        <p className="section-note">The roadmap is context—not seven separate applications.</p>
      </div>
      <ol className="roadmap">
        {stages.map((stage) => (
          <li key={stage.number} className={`roadmap-stage roadmap-${stage.status.toLowerCase()}`}>
            <span className="stage-number">{stage.number}</span>
            <div>
              <strong>{stage.name}</strong>
              <span>{stage.status}</span>
            </div>
            <p>{stage.description}</p>
          </li>
        ))}
      </ol>
    </section>
  );
}
