import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import test from "node:test";

const packageJsonUrl = new URL("../package.json", import.meta.url);
const pubspecUrl = new URL("../pubspec.yaml", import.meta.url);
const mainDartUrl = new URL("../lib/main.dart", import.meta.url);
const readmeUrl = new URL("../README.md", import.meta.url);
const sharedEnvUrl = new URL("../../.env", import.meta.url);
const manualVerificationUrl = new URL(
  "../../task-reports/RDS-TASK-016/manual-verification.md",
  import.meta.url,
);
const bootstrapUrl = new URL("../lib/app/bootstrap.dart", import.meta.url);
const bootstrapConfigUrl = new URL(
  "../lib/app/bootstrap_config.dart",
  import.meta.url,
);
const appShellUrl = new URL("../lib/app/radiosa_mobile_app.dart", import.meta.url);
const contractUrl = new URL(
  "../lib/shared/config/runtime_contract.dart",
  import.meta.url,
);
const motdRepositoryUrl = new URL(
  "../lib/shared/data/repositories/motd_repository.dart",
  import.meta.url,
);
const startupRepositoryUrl = new URL(
  "../lib/shared/data/repositories/application_event_repository.dart",
  import.meta.url,
);
const controllerUrl = new URL(
  "../lib/shared/state/baseline_participant_controller.dart",
  import.meta.url,
);
const streamListUrl = new URL(
  "../lib/features/streams/screens/stream_list_screen.dart",
  import.meta.url,
);
const motdCardUrl = new URL(
  "../lib/features/motd/widgets/motd_message_card.dart",
  import.meta.url,
);
const streamDetailUrl = new URL(
  "../lib/features/streams/screens/stream_detail_screen.dart",
  import.meta.url,
);
const widgetTestUrl = new URL(
  "../test/baseline_participant_widget_test.dart",
  import.meta.url,
);
const integrationTestUrl = new URL(
  "../integration_test/baseline_contract_test.dart",
  import.meta.url,
);
const mockStreamsUrl = new URL(
  "../lib/features/streams/model/mock_streams.dart",
  import.meta.url,
);

function read(url: URL): string {
  return readFileSync(url, "utf8");
}

// Test: exposes the Flutter app shell and EP-001 feature-oriented structure.
// Validates: RDS-AC-004, RDS-AC-046 (RDS-REQ-016 - Provide a runnable application skeleton for app, RDS-REQ-054 - Provide a baseline mobile screen in app)
test("mobile scaffold declares the baseline Flutter shell and structure", () => {
  const pubspec = read(pubspecUrl);
  const mainDart = read(mainDartUrl);
  const bootstrap = read(bootstrapUrl);
  const appShell = read(appShellUrl);
  const readme = read(readmeUrl);

  assert.match(pubspec, /^name: app$/m);
  assert.match(pubspec, /flutter:\s*\n\s+sdk: flutter/);
  assert.match(pubspec, /flutter_test:\s*\n\s+sdk: flutter/);
  assert.match(pubspec, /integration_test:\s*\n\s+sdk: flutter/);
  assert.match(mainDart, /bootstrapRadiosaMobileApp/);
  assert.match(bootstrap, /BaselineParticipantController/);
  assert.match(appShell, /class RadiosaMobileApp extends StatelessWidget/);
  assert.match(appShell, /StreamListScreen/);
  assert.match(appShell, /StreamDetailScreen/);
  assert.match(readme, /`lib\/app`/);
  assert.match(readme, /`lib\/features\/motd`/);
  assert.match(readme, /`lib\/features\/streams`/);
  assert.match(readme, /`lib\/entities\/stream`/);
  assert.match(readme, /`lib\/shared`/);
});

// Test: publishes the required development entrypoints.
// Validates: RDS-AC-004 (RDS-REQ-016 - Provide a runnable application skeleton for app)
test("mobile scaffold documents the startup commands", () => {
  const packageJson = JSON.parse(read(packageJsonUrl)) as {
    scripts: Record<string, string>;
  };
  const readme = read(readmeUrl);

  assert.equal(
    packageJson.scripts.verify,
    "node --test --experimental-strip-types test/*.test.ts",
  );
  assert.match(readme, /flutter run/);
  assert.match(readme, /flutter run -d chrome/);
  assert.match(readme, /npm run verify/);
});

// Test: documents the shared local configuration convention for Flutter startup.
// Validates: RDS-AC-005, RDS-AC-006 (RDS-REQ-017 - Define a shared environment configuration convention, RDS-REQ-018 - Report missing required configuration values)
test("mobile scaffold documents and reads the shared environment convention", () => {
  const sharedEnv = read(sharedEnvUrl);
  const readme = read(readmeUrl);
  const bootstrapConfig = read(bootstrapConfigUrl);
  const appShell = read(appShellUrl);

  assert.match(sharedEnv, /^RADIOSA_ENVIRONMENT=local$/m);
  assert.match(sharedEnv, /^RT_FN_BASE_URL=http:\/\/localhost:5001$/m);
  assert.match(readme, /shared root `\.env` file/i);
  assert.match(readme, /--dart-define-from-file=\.\.\/\.env/);
  assert.match(
    readme,
    /`RADIOSA_BASELINE_MOTD_MESSAGE` is optional for the local baseline shell/i,
  );
  assert.match(
    bootstrapConfig,
    /String\.fromEnvironment\('RADIOSA_ENVIRONMENT'\)/,
  );
  assert.match(bootstrapConfig, /String\.fromEnvironment\('RT_FN_BASE_URL'\)/);
  assert.match(
    bootstrapConfig,
    /String\.fromEnvironment\(\s*'RADIOSA_BASELINE_MOTD_MESSAGE'/,
  );
  assert.match(appShell, /ConfigurationErrorApp/);
  assert.match(appShell, /Missing required configuration values/);
  assert.match(bootstrapConfig, /RADIOSA_ENVIRONMENT/);
  assert.match(bootstrapConfig, /RT_FN_BASE_URL/);
});

// Test: keeps the placeholder stream list/detail flow in the refactored structure.
// Validates: RDS-AC-009, RDS-AC-010 (RDS-REQ-021 - Provide a mobile placeholder stream list screen, RDS-REQ-022 - Provide a mobile placeholder stream detail screen)
test("mobile scaffold keeps the placeholder stream list and detail surfaces", () => {
  const mockStreams = read(mockStreamsUrl);
  const streamList = read(streamListUrl);
  const streamDetail = read(streamDetailUrl);
  const manualVerification = read(manualVerificationUrl);

  assert.match(mockStreams, /const mockedStreams = <PlaceholderStream>\[/);
  assert.match(mockStreams, /Smoke Flow Demo Stream/);
  assert.match(mockStreams, /baseline-smoke-flow/);
  assert.match(streamList, /Mobile Placeholder Stream List/);
  assert.match(streamList, /Choose a placeholder stream/);
  assert.match(streamList, /Navigator\.of\(context\)\.push/);
  assert.match(streamDetail, /Participant View Placeholder/);
  assert.match(
    streamDetail,
    /Join actions are intentionally inactive until stream runtime behavior is implemented\./,
  );
  assert.match(read(readmeUrl), /RDS-TASK-016\/manual-verification\.md/);
  assert.match(
    manualVerification,
    /http:\/\/127\.0\.0\.1:7357\/#\/streams\/stream-smoke-demo/,
  );
});

// Test: expresses the baseline MOTD subscription contract and explicit empty-state behavior.
// Validates: RDS-AC-047, RDS-AC-048, RDS-AC-049 (RDS-REQ-055 - Subscribe to the motd message from the baseline mobile screen, RDS-REQ-056 - Render the motd value on the baseline mobile screen, RDS-REQ-057 - Render no message when the motd path is absent or empty)
test("mobile scaffold expresses the motd subscription contract", () => {
  const contract = read(contractUrl);
  const repository = read(motdRepositoryUrl);
  const controller = read(controllerUrl);
  const streamList = read(streamListUrl);
  const motdCard = read(motdCardUrl);
  const widgetTest = read(widgetTestUrl);

  assert.match(contract, /const kMotdMessagePath = '\/motd\/message';/);
  assert.match(repository, /class LocalBaselineMotdRepository implements MotdRepository/);
  assert.match(repository, /assert\(path == kMotdMessagePath\)/);
  assert.match(repository, /normalizedMessage\.isEmpty \? null : normalizedMessage/);
  assert.match(controller, /subscribeToMessage\(path: kMotdMessagePath\)/);
  assert.match(streamList, /StreamBuilder<String\?>/);
  assert.match(streamList, /MotdMessageCard/);
  assert.match(motdCard, /Subscribed path: \$path/);
  assert.match(widgetTest, /find\.text\('Hello world!'\), findsOneWidget/);
  assert.match(widgetTest, /find\.text\('Hello world!'\), findsNothing/);
});

// Test: invokes the rt-fn startup handoff through onApplicationEvent exactly once on startup.
// Validates: RDS-AC-056, RDS-AC-057 (RDS-REQ-064 - Invoke onApplicationEvent from app startup, RDS-REQ-065 - Accept the app startup Event from onApplicationEvent)
test("mobile scaffold wires the startup event handoff to rt-fn", () => {
  const contract = read(contractUrl);
  const startupRepository = read(startupRepositoryUrl);
  const controller = read(controllerUrl);
  const streamList = read(streamListUrl);
  const readme = read(readmeUrl);
  const integrationTest = read(integrationTestUrl);

  assert.match(contract, /const kStartupEventFunctionPath = '\/onApplicationEvent';/);
  assert.match(contract, /const kStartupEventName = 'app\.startup';/);
  assert.match(startupRepository, /class HttpApplicationEventPublisher implements ApplicationEventPublisher/);
  assert.match(startupRepository, /'eventName': kStartupEventName/);
  assert.match(startupRepository, /'source': 'app'/);
  assert.match(startupRepository, /StartupEventDispatchStatus\.sent/);
  assert.match(controller, /if \(_startupAttempted\) {\s*return;\s*}/);
  assert.match(streamList, /widget\.controller\.beginStartup\(\);/);
  assert.match(readme, /POST \$\{RT_FN_BASE_URL\}\/onApplicationEvent/);
  assert.match(integrationTest, /expect\(startupPublisher\.invocationCount, 1\)/);
  assert.match(integrationTest, /expect\(kStartupEventFunctionPath, '\/onApplicationEvent'\)/);
});

// Test: checks in widget and integration verification artifacts for the realtime boundary.
// Validates: RDS-AC-046, RDS-AC-048, RDS-AC-049, RDS-AC-056
test("mobile scaffold includes widget and integration verification artifacts", () => {
  assert.equal(existsSync(widgetTestUrl), true);
  assert.equal(existsSync(integrationTestUrl), true);
  assert.match(read(widgetTestUrl), /testWidgets\('renders the baseline mobile screen with the realtime MOTD message'/);
  assert.match(read(widgetTestUrl), /testWidgets\('renders no motd message text when the baseline path is empty'/);
  assert.match(read(integrationTestUrl), /IntegrationTestWidgetsFlutterBinding\.ensureInitialized/);
  assert.match(read(integrationTestUrl), /anchors the baseline controller to the motd path and startup handoff/);
});
