# Mobile App

Participant-facing Flutter application shell for the live quiz experience.

## Scope

- subscribe to realtime quiz state
- render live quiz interactions
- submit participant answers and events

## Development

- Keep the shared `RADIOSA_*` configuration keys in `.env.example` as the source of truth for local values.
- For a local setup file, copy `.env.example` to `.env.local` and keep the same values ready for manual `--dart-define` usage.
- Start the app with matching `--dart-define` flags so the Flutter shell receives the same keys used by the other repos:
  `flutter run --dart-define=RADIOSA_ENVIRONMENT=local --dart-define=RADIOSA_APP_ID=app --dart-define=RADIOSA_REALTIME_BASE_URL=http://localhost:5001`
- For the reproducible web smoke artifact used by the scaffold review fix, start the development server from `mobile-app/` with:
  `../flutter/bin/flutter run -d web-server --web-port 7357 --dart-define=RADIOSA_ENVIRONMENT=local --dart-define=RADIOSA_APP_ID=app --dart-define=RADIOSA_REALTIME_BASE_URL=http://localhost:5001`
- `RADIOSA_ENVIRONMENT` identifies the local environment name shared across the PoC.
- `RADIOSA_APP_ID` must stay aligned with the repo identifier (`app` here).
- `RADIOSA_REALTIME_BASE_URL` points to the local realtime shell, which defaults to `http://localhost:5001`.
- `flutter run` starts the app on the selected device or emulator
- `flutter run -d chrome` starts the shell in a browser when web support is available
- `npm run verify` runs the scaffold checks for this repository

## Notes

- The checked-in Flutter files are intentionally minimal so the repo can be extended without generated noise.
- The Node-based verification entrypoint checks the scaffold shape without requiring a local Flutter SDK during repository setup.
- The shell renders an explicit setup error screen when any required `RADIOSA_*` value is missing.

## Smoke Flow

- The first placeholder entry is `Smoke Flow Demo Stream`, aligned with the scaffold bootstrap contract.
- The detail screen surfaces the smoke-flow, quiz, and participant identifiers together with the configured realtime base URL.
- During local web-server runs, `http://127.0.0.1:7357/#/streams/stream-smoke-demo` opens the smoke-flow detail surface directly so the manual smoke capture stays reproducible.
- The full bootstrap and smoke-flow steps are documented in `../docs/baseline-smoke-flow.md`.
- The current mobile smoke evidence is tracked in `../task-reports/RDS-TASK-009/mobile-smoke-evidence.md`.
