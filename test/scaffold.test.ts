import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const packageJsonUrl = new URL("../package.json", import.meta.url);
const pubspecUrl = new URL("../pubspec.yaml", import.meta.url);
const mainDartUrl = new URL("../lib/main.dart", import.meta.url);
const readmeUrl = new URL("../README.md", import.meta.url);
const envExampleUrl = new URL("../.env.example", import.meta.url);
const manualVerificationUrl = new URL(
  "../../task-reports/RDS-TASK-016/manual-verification.md",
  import.meta.url,
);

// Test: exposes the Flutter app shell and documented startup commands.
// Validates: RDS-AC-004 (RDS-REQ-016 - Provide a runnable application skeleton for app)
test("mobile scaffold declares a Flutter application shell", () => {
  const pubspec = readFileSync(pubspecUrl, "utf8");
  const mainDart = readFileSync(mainDartUrl, "utf8");

  assert.match(pubspec, /^name: app$/m);
  assert.match(pubspec, /flutter:\s*\n\s+sdk: flutter/);
  assert.match(mainDart, /MaterialApp/);
  assert.match(mainDart, /Radiosa Mobile App/);
});

// Test: publishes the required development entrypoints.
// Validates: RDS-AC-004 (RDS-REQ-016 - Provide a runnable application skeleton for app)
test("mobile scaffold documents the startup commands", () => {
  const packageJson = JSON.parse(readFileSync(packageJsonUrl, "utf8")) as {
    scripts: Record<string, string>;
  };
  const readme = readFileSync(readmeUrl, "utf8");

  assert.equal(packageJson.scripts.verify, "node --test --experimental-strip-types test/*.test.ts");
  assert.match(readme, /flutter run/);
  assert.match(readme, /flutter run -d chrome/);
  assert.match(readme, /npm run verify/);
});

// Test: documents the shared local configuration convention for Flutter startup.
// Validates: RDS-AC-005 (RDS-REQ-017 - Define a shared environment configuration convention)
test("mobile scaffold documents the shared environment convention", () => {
  const envExample = readFileSync(envExampleUrl, "utf8");
  const readme = readFileSync(readmeUrl, "utf8");
  const mainDart = readFileSync(mainDartUrl, "utf8");

  assert.match(envExample, /^RADIOSA_ENVIRONMENT=local$/m);
  assert.match(envExample, /^RADIOSA_APP_ID=app$/m);
  assert.match(envExample, /^RADIOSA_REALTIME_BASE_URL=http:\/\/localhost:5001$/m);
  assert.match(readme, /copy `\.env\.example` to `\.env\.local`/i);
  assert.match(readme, /--dart-define=RADIOSA_ENVIRONMENT=local/);
  assert.match(mainDart, /String\.fromEnvironment\('RADIOSA_ENVIRONMENT'\)/);
  assert.match(mainDart, /String\.fromEnvironment\('RADIOSA_REALTIME_BASE_URL'\)/);
});

// Test: renders an explicit setup error surface when required values are missing.
// Validates: RDS-AC-006 (RDS-REQ-018 - Report missing required configuration values)
test("mobile scaffold reports missing configuration keys in the UI", () => {
  const mainDart = readFileSync(mainDartUrl, "utf8");

  assert.match(mainDart, /ConfigurationErrorApp/);
  assert.match(mainDart, /Missing required configuration values/);
  assert.match(mainDart, /RADIOSA_APP_ID/);
  assert.match(mainDart, /RADIOSA_ENVIRONMENT/);
  assert.match(mainDart, /RADIOSA_REALTIME_BASE_URL/);
});

// Test: renders a placeholder participant stream list screen.
// Validates: RDS-AC-009 (RDS-REQ-021 - Provide a mobile placeholder stream list screen)
test("mobile scaffold defines a placeholder stream list screen", () => {
  const mainDart = readFileSync(mainDartUrl, "utf8");

  assert.match(mainDart, /home: initialStream == null\s*\? StreamListScreen/);
  assert.match(mainDart, /class StreamListScreen extends StatelessWidget/);
  assert.match(mainDart, /Mobile Placeholder Stream List/);
  assert.match(mainDart, /Choose a placeholder stream/);
  assert.match(mainDart, /const mockedStreams = <PlaceholderStream>\[/);
  assert.match(mainDart, /Smoke Flow Demo Stream/);
  assert.match(mainDart, /baseline-smoke-flow/);
  assert.match(mainDart, /quiz-smoke-demo/);
  assert.match(mainDart, /participant-smoke-demo/);
});

// Test: publishes the current task-local manual verification path for the mobile scaffold.
// Validates: RDS-AC-004 (RDS-REQ-016 - Provide a runnable application skeleton for app)
test("mobile scaffold links task-local manual verification instructions", () => {
  const readme = readFileSync(readmeUrl, "utf8");
  const manualVerification = readFileSync(manualVerificationUrl, "utf8");

  assert.match(readme, /RDS-TASK-016\/manual-verification\.md/);
  assert.match(manualVerification, /flutter run -d web-server --web-port 7357/);
  assert.match(manualVerification, /Mobile Placeholder Stream List/);
  assert.match(manualVerification, /Smoke Flow Demo Stream/);
  assert.match(manualVerification, /click or tap `Smoke Flow Demo Stream`/i);
  assert.match(manualVerification, /Smoke flow id: baseline-smoke-flow/);
});

// Test: opens a placeholder participant stream detail screen from the list.
// Validates: RDS-AC-010 (RDS-REQ-022 - Provide a mobile placeholder stream detail screen)
test("mobile scaffold defines placeholder stream detail navigation", () => {
  const mainDart = readFileSync(mainDartUrl, "utf8");

  assert.match(mainDart, /class StreamDetailScreen extends StatelessWidget/);
  assert.match(mainDart, /Navigator\.of\(context\)\.push/);
  assert.match(mainDart, /MaterialPageRoute<void>/);
  assert.match(mainDart, /Participant View Placeholder/);
  assert.match(
    mainDart,
    /Join actions are intentionally inactive until stream runtime behavior is implemented\./,
  );
});
