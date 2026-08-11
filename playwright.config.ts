import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: false,
  // The deterministic fixture repositories are process-scoped and Next dev
  // compiles routes on first navigation. Serial execution keeps synthetic
  // state isolated and prevents first-load navigation contention.
  workers: 1,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? [['html', { open: 'never' }], ['list']] : 'list',
  use: {
    baseURL: 'http://localhost:3200',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'desktop-chromium',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 1000 } },
      testIgnore: /mobile\.spec\.ts/,
    },
    {
      name: 'mobile-chromium',
      use: { ...devices['Pixel 7'] },
      testMatch: /mobile\.spec\.ts/,
    },
  ],
  webServer: {
    command: 'npm run dev -- -p 3200',
    url: 'http://localhost:3200/login',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
    env: {
      E2E_MOCK_AUTH: 'true',
      NEXT_TELEMETRY_DISABLED: '1',
    },
  },
});
