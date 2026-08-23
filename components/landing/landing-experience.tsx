'use client';

import Image from 'next/image';
import Link from 'next/link';
import { ArrowDown, ArrowRight, ChartNoAxesColumnIncreasing, LockKeyhole, UserRound, UsersRound, X } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import styles from './landing.module.css';

const MINISTRY_LOGIN_URL = 'https://ministry.leademergence.com/login';
const MINISTRY_GUEST_URL = 'https://ministry.leademergence.com/api/auth/guest';

const stages = [
  {
    number: '01',
    short: 'SEE',
    title: 'Attention before action.',
    copy: 'The work begins by encountering reality as it is—the people, rhythms, tensions, strengths, and constraints already present.',
  },
  {
    number: '02',
    short: 'REFRAME',
    title: 'Meaning gives direction.',
    copy: 'Patterns become meaning. Assumptions are challenged. What was difficult to articulate is named clearly enough for a different future to become imaginable.',
  },
  {
    number: '03',
    short: 'ALIGN',
    title: 'Boundaries create space. Relationships create coherence.',
    copy: 'People, purpose, and systems are placed in right relation to each other. Alignment is not agreement—it is coherence.',
  },
  {
    number: '04',
    short: 'BUILD',
    title: 'Capability takes root.',
    copy: 'People develop. Judgment strengthens. Structures, rhythms, practice, and technology create the conditions for capability to grow and multiply.',
  },
  {
    number: '05',
    short: 'PRODUCE',
    title: 'Results emerge.',
    copy: 'Not output for its own sake—fruit. Value that strengthens both the harvest and the soil that produced it.',
  },
  {
    number: '06',
    short: 'NEW REALITY',
    title: 'Step into what has become possible.',
    copy: 'What was once envisioned and designed becomes lived reality. The organization begins operating from a new baseline—real, inhabited, and alive.',
  },
  {
    number: '07',
    short: 'SEE AGAIN',
    title: 'Because reality never stops becoming.',
    copy: 'A new reality becomes the starting point for fresh attention and the next cycle.',
  },
] as const;

const thresholds = [0, 0.12, 0.25, 0.38, 0.51, 0.64, 0.82, 1];

const stageImages = stages.map((stage) => `/brand/roadmap/mock-stage-${stage.number}-${stage.short.toLowerCase().replaceAll(' ', '-')}-v10.png`);

function rangeProgress(value: number, start: number, end: number) {
  return Math.max(0, Math.min(1, (value - start) / (end - start)));
}

function activeStageFor(progress: number) {
  const stage = thresholds.findIndex((threshold, index) => index < thresholds.length - 1 && progress >= threshold && progress < thresholds[index + 1]);
  return stage === -1 ? 6 : stage;
}

function BrandLockup({ compact = false }: { compact?: boolean }) {
  return (
    <span className={compact ? styles.brandCompact : styles.brandLockup}>
      <strong><i>Lead</i> Emergence</strong>
      <small>{compact ? 'LEADERSHIP TECHNOLOGY' : 'PEOPLE · PURPOSE · SYSTEMS'}</small>
    </span>
  );
}

export function LandingExperience() {
  const narrativeRef = useRef<HTMLElement>(null);
  const dialogRef = useRef<HTMLDialogElement>(null);
  const [progress, setProgress] = useState(0);
  const [reducedMotion, setReducedMotion] = useState(false);

  useEffect(() => {
    const media = window.matchMedia('(prefers-reduced-motion: reduce)');
    const sync = () => setReducedMotion(media.matches);
    sync();
    media.addEventListener('change', sync);
    return () => media.removeEventListener('change', sync);
  }, []);

  useEffect(() => {
    let frame = 0;
    const update = () => {
      frame = 0;
      const section = narrativeRef.current;
      if (!section) return;
      const rect = section.getBoundingClientRect();
      const distance = Math.max(1, section.offsetHeight - window.innerHeight);
      const next = Math.max(0, Math.min(1, -rect.top / distance));
      setProgress((current) => Math.abs(current - next) > 0.001 ? next : current);
    };
    const schedule = () => {
      if (!frame) frame = window.requestAnimationFrame(update);
    };
    update();
    window.addEventListener('scroll', schedule, { passive: true });
    window.addEventListener('resize', schedule);
    return () => {
      if (frame) window.cancelAnimationFrame(frame);
      window.removeEventListener('scroll', schedule);
      window.removeEventListener('resize', schedule);
    };
  }, []);

  const activeStage = activeStageFor(progress);
  const openEntry = () => dialogRef.current?.showModal();
  const closeEntry = () => dialogRef.current?.close();
  const jumpToStage = (index: number) => {
    const section = narrativeRef.current;
    if (!section) return;
    const targetProgress = index === 6
      ? 0.95
      : thresholds[index] + (thresholds[index + 1] - thresholds[index]) * 0.46;
    const top = section.offsetTop + targetProgress * Math.max(1, section.offsetHeight - window.innerHeight);
    window.scrollTo({ top, behavior: reducedMotion ? 'auto' : 'smooth' });
  };

  return (
    <main className={styles.landing} id="top">
      <a className={styles.skipLink} href="#main-content">Skip to the story</a>
      <header className={styles.navigation}>
        <Link href="#top" aria-label="Lead Emergence home"><BrandLockup compact /></Link>
        <button className={styles.signInButton} type="button" onClick={openEntry}>Sign in <ArrowRight aria-hidden="true" /></button>
      </header>

      <section className={styles.opening} aria-labelledby="opening-title">
        <div className={styles.openingRule} aria-hidden="true" />
        <p className={styles.eyebrow}>THE EMERGENCE ROADMAP</p>
        <h1 id="opening-title">Before you build what comes next,<br />{' '}<em>you have to see what is actually there.</em></h1>
        <a className={styles.scrollCue} href="#journey"><span>SCROLL TO BEGIN</span><ArrowDown aria-hidden="true" /></a>
      </section>

      <section className={styles.narrative} id="journey" ref={narrativeRef} aria-labelledby="journey-title" data-active-stage={activeStage + 1}>
        <h2 className={styles.visuallyHidden} id="journey-title">The seven-stage Emergence roadmap</h2>
        <ol className={styles.semanticStages}>
          {stages.map((stage) => <li key={stage.number}><strong>{stage.short}: {stage.title}</strong> {stage.copy}</li>)}
        </ol>
        <div className={styles.stickyFrame}>
          <div className={styles.storyGrid} id="main-content">
            <div className={styles.copyStage} aria-hidden="true">
              <article className={styles.stageCopy} key={stages[activeStage].number}>
                <div className={styles.stageMeta}><span>{stages[activeStage].number}</span><span>OF 07</span></div>
                <p className={styles.stageName}>{stages[activeStage].short}</p>
                <div className={styles.stageRule} />
                <h3>{stages[activeStage].title}</h3>
                <p className={styles.stageBody}>{stages[activeStage].copy}</p>
              </article>
            </div>

            <div className={styles.symbolStage} aria-hidden="true">
              <div className={styles.symbolSequence}>
                {stageImages.map((src, index) => {
                  const transition = activeStage === 0 || reducedMotion ? 1 : rangeProgress(progress, thresholds[activeStage], thresholds[activeStage] + 0.035);
                  const visible = index === activeStage ? transition : index === activeStage - 1 ? 1 - transition : 0;
                  return <Image className={styles.symbolImage} fill key={src} priority={index < 2} sizes="(max-width: 720px) 76vw, 560px" src={src} alt="" unoptimized style={{ opacity: visible }} />;
                })}
              </div>
            </div>
          </div>

          <nav className={styles.stageRail} aria-label="Roadmap progress">
            {stages.map((stage, index) => (
              <a
                href={`#stage-${stage.number}`}
                className={index === activeStage ? styles.stageRailActive : ''}
                key={stage.number}
                aria-current={index === activeStage ? 'step' : undefined}
                onClick={(event) => { event.preventDefault(); jumpToStage(index); }}
              >
                <span>{stage.number}</span><small>{stage.short}</small>
              </a>
            ))}
          </nav>
        </div>
        <div className={styles.stageAnchors} aria-hidden="true">
          {stages.map((stage) => <span id={`stage-${stage.number}`} key={stage.number} />)}
        </div>
      </section>

      <section className={styles.brandReveal} aria-labelledby="brand-title">
        <div className={styles.brandPanel}>
          <div className={styles.brandStatement}>
            <p className={styles.eyebrow}>ONE CONTINUOUS PRACTICE</p>
            <h2 id="brand-title"><i>Lead</i> Emergence</h2>
            <p>Technology for leaders building organizations and ministries where people, purpose, and systems can flourish together.</p>
          </div>
        </div>
      </section>

      <section className={styles.productEntry} id="products" aria-labelledby="products-title">
        <div className={styles.entryFrame}>
          <header className={styles.entryIntro}>
            <h2 id="products-title">Choose your workspace</h2>
            <p>Choose the environment that fits your role and calling.</p>
          </header>

          <article className={`${styles.productCard} ${styles.ministryCard}`}>
            <div className={styles.productTopline}><span>FORMATION</span><span className={styles.productIcon}><UsersRound aria-hidden="true" /></span></div>
            <h3>Ministry</h3>
            <p className={styles.positioning}>Create more space for shepherding.</p>
            <p>Bring people, ministry operations, discipleship, and biblical purpose into one environment designed around how ministry actually works.</p>
            <div className={styles.entryStack}>
              <a className={styles.entryLink} href={MINISTRY_LOGIN_URL}>
                <UsersRound aria-hidden="true" />
                <span><strong>Team member login</strong><small>Staff, leaders, and volunteers</small></span>
                <ArrowRight aria-hidden="true" />
              </a>
              <a className={styles.entryLink} href={MINISTRY_GUEST_URL}>
                <UserRound aria-hidden="true" />
                <span><strong>Guest access</strong><small>Students and parents with an invite link</small></span>
                <ArrowRight aria-hidden="true" />
              </a>
            </div>
          </article>

          <article className={`${styles.productCard} ${styles.consultingCard}`}>
            <div className={styles.productTopline}><span>TRANSFORMATION</span><span className={styles.productIcon}><ChartNoAxesColumnIncreasing aria-hidden="true" /></span></div>
            <h3>Lead Emergence Consulting</h3>
            <p className={styles.positioning}>Build the organization that should exist next.</p>
            <p>See reality clearly, challenge inherited assumptions, align around purpose, cultivate capability, and preserve why the organization was built that way.</p>
            <div className={styles.entryStack}>
              <Link className={styles.entryLink} href="/intake/consulting">
                <UserRound aria-hidden="true" />
                <span><strong>Start a client conversation</strong><small>Share your context before creating a workspace</small></span>
                <ArrowRight aria-hidden="true" />
              </Link>
              <Link className={styles.entryLink} href="/login?returnTo=%2Fconsultant">
                <UserRound aria-hidden="true" />
                <span><strong>Consultant login</strong><small>Run engagements, frameworks, and deliverables</small></span>
                <ArrowRight aria-hidden="true" />
              </Link>
              <Link className={styles.entryLink} href="/login?returnTo=%2Fclient">
                <UsersRound aria-hidden="true" />
                <span><strong>Client login</strong><small>Track your engagement, decisions, and progress</small></span>
                <ArrowRight aria-hidden="true" />
              </Link>
            </div>
          </article>

        </div>
      </section>

      <footer className={styles.footer}>
        <BrandLockup compact />
        <p>People · Purpose · Systems</p>
      </footer>

      <dialog className={styles.entryDialog} ref={dialogRef} onClick={(event) => { if (event.target === dialogRef.current) closeEntry(); }}>
        <div className={styles.dialogPanel}>
          <button className={styles.closeButton} type="button" onClick={closeEntry} aria-label="Close sign in selector"><X aria-hidden="true" /></button>
          <p className={styles.eyebrow}>RETURNING USER</p>
          <h2>Choose your environment.</h2>
          <p>Your identity may be shared, but access remains independent for each product.</p>
          <div className={styles.dialogOptions}>
            <section>
              <div><ChartNoAxesColumnIncreasing aria-hidden="true" /><strong>Lead Emergence Consulting</strong></div>
              <Link href="/login?returnTo=%2Fconsultant">Consultant <ArrowRight aria-hidden="true" /></Link>
              <Link href="/login?returnTo=%2Fclient">Client <ArrowRight aria-hidden="true" /></Link>
            </section>
            <section>
              <div><UsersRound aria-hidden="true" /><strong>Ministry</strong></div>
              <a href={MINISTRY_LOGIN_URL}>Ministry user <ArrowRight aria-hidden="true" /></a>
            </section>
          </div>
          <div className={styles.dialogSecurity}><LockKeyhole aria-hidden="true" /><span>Each environment applies its own authorization and privacy rules.</span></div>
        </div>
      </dialog>
    </main>
  );
}
