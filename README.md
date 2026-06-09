# Mobile App

Participant-facing Flutter application shell for the live quiz experience.

## Scope

- subscribe to realtime quiz state
- render live quiz interactions
- submit participant answers and events

## Structure

- `lib/app` bootstraps the Flutter shell, configuration, and top-level app runtime.
- `lib/features/motd` renders the baseline `/motd/message` subscription surface.
- `lib/features/streams` keeps the placeholder list/detail participant shape required by EP-001.
- `lib/entities/stream` contains the placeholder participant stream model.
- `lib/shared` holds baseline contract constants, local repositories, request clients, state, and reusable UI.

## Development

- Use the shared root `.env` file at `../.env` as the local discovery source for the Flutter shell.
- Start the app with `--dart-define-from-file=../.env` so Flutter derives the shared contract directly from the root file. Prefer the bundled SDK to avoid relying on a global Flutter installation:
  `../flutter/bin/flutter run --dart-define-from-file=../.env`
- For the reproducible web smoke artifact used by the scaffold review fix, start the development server from `mobile-app/` with:
  `../flutter/bin/flutter run -d web-server --web-port 7357 --dart-define-from-file=../.env`
- `RADIOSA_ENVIRONMENT` identifies the local environment name shared across the PoC.
- `RT_FN_BASE_URL` points to the local realtime shell, which defaults to `http://localhost:5001`.
- `RADIOSA_APP_ID` defaults to `app`, so the shared root contract does not need a mobile-only app id entry.
- `RADIOSA_BASELINE_MOTD_MESSAGE` is optional for the local baseline shell; when present, the app emits it through the checked-in `/motd/message` repository surface and when absent the baseline message area renders no message text.
- `../flutter/bin/flutter run` starts the app on the selected device or emulator
- `../flutter/bin/flutter run -d chrome` starts the shell in a browser when web support is available
- `../flutter/bin/flutter build apk --debug --dart-define-from-file=../.env` builds a device-installable Android APK from the shared root contract
- `npm run verify` runs the scaffold checks for this repository

For the full local stack bootstrap from the workspace root, use `../scripts/start-local-stack.sh`. It writes the shared `.env`, starts the Node shells on `0.0.0.0`, and builds the Android APK with the bundled Flutter SDK.

## Notes

- The checked-in Flutter files are intentionally minimal so the repo can be extended without generated noise.
- The Node-based verification entrypoint checks the scaffold shape without requiring a local Flutter SDK during repository setup.
- The shell renders an explicit setup error screen when any required shared root `.env` value is missing.
- The startup runtime invokes `POST ${RT_FN_BASE_URL}/onApplicationEvent` with one `app.startup` event during list-screen initialization.
- The baseline `/motd/message` read path is expressed in `lib/shared/data/repositories/motd_repository.dart` and rendered through the list-screen MOTD card.
- Checked-in Flutter widget and integration tests cover the realtime message path and startup handoff, while `npm run verify` audits their presence and traceability from the repository-level entrypoint.
- Full iOS and macOS Flutter development also requires full Xcode plus CocoaPods on the local machine.

## Smoke Flow

- The first placeholder entry is `Smoke Flow Demo Stream`, aligned with the scaffold bootstrap contract.
- The detail screen surfaces the smoke-flow, quiz, and participant identifiers together with the configured realtime base URL.
- During local web-server runs, `http://127.0.0.1:7357/#/streams/stream-smoke-demo` opens the smoke-flow detail surface directly so the manual smoke capture stays reproducible.
- The full bootstrap and smoke-flow steps are documented in `../docs/baseline-smoke-flow.md`.
- The current task-local manual verification path is tracked in `../task-reports/RDS-TASK-016/manual-verification.md`.
