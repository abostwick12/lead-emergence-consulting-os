'use client';

import './returning-user.css';

type ReturningUserProps = {
  onSignIn: () => void;
};

export function ReturningUser({ onSignIn }: ReturningUserProps) {
  return (
    <section className="returning-user" aria-labelledby="returning-user-title">
      <div className="returning-user__inner">
        <h2 className="returning-user__title" id="returning-user-title">
          Returning user?
        </h2>
        <p className="returning-user__copy">
          Sign in to quickly access your environment.
        </p>
        <button className="returning-user__button" type="button" onClick={onSignIn}>
          <span>Sign in</span>
          <svg aria-hidden="true" viewBox="0 0 32 32" className="returning-user__arrow">
            <path
              d="M7 16h18M18 9l7 7-7 7"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </button>
      </div>
    </section>
  );
}
