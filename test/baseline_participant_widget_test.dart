import 'package:flutter_test/flutter_test.dart';

import 'package:app/app/bootstrap_config.dart';
import 'package:app/app/radiosa_mobile_app.dart';
import 'package:app/shared/data/repositories/application_event_repository.dart';
import 'package:app/shared/data/repositories/motd_repository.dart';
import 'package:app/shared/state/baseline_participant_controller.dart';

void main() {
  const config = BootstrapConfig(
    appId: 'app',
    baselineMotdMessage: '',
    environmentName: 'local',
    missingKeys: <String>[],
    realtimeBaseUrl: 'http://localhost:5001',
  );

  // Test: renders the baseline mobile screen and realtime MOTD message text.
  // Validates: RDS-AC-046, RDS-AC-047, RDS-AC-048 (RDS-REQ-054 - Provide a baseline mobile screen in app, RDS-REQ-055 - Subscribe to the motd message from the baseline mobile screen, RDS-REQ-056 - Render the motd value on the baseline mobile screen)
  testWidgets('renders the baseline mobile screen with the realtime MOTD message', (
    tester,
  ) async {
    final controller = BaselineParticipantController(
      motdRepository: const _FakeMotdRepository('Hello world!'),
      startupEventPublisher: _FakeStartupEventPublisher(),
    );

    await tester.pumpWidget(
      RadiosaMobileApp(
        config: config,
        controller: controller,
        initialStream: null,
      ),
    );
    await tester.pump();

    expect(find.text('Mobile Placeholder Stream List'), findsOneWidget);
    expect(find.text('Subscribed path: /motd/message'), findsOneWidget);
    expect(find.text('Hello world!'), findsOneWidget);
  });

  // Test: renders no message text when the baseline MOTD path is empty and still sends one startup event.
  // Validates: RDS-AC-049, RDS-AC-056 (RDS-REQ-057 - Render no message when the motd path is absent or empty, RDS-REQ-064 - Invoke onApplicationEvent from app startup)
  testWidgets('renders no motd message text when the baseline path is empty', (
    tester,
  ) async {
    final startupPublisher = _FakeStartupEventPublisher();
    final controller = BaselineParticipantController(
      motdRepository: const _FakeMotdRepository(null),
      startupEventPublisher: startupPublisher,
    );

    await tester.pumpWidget(
      RadiosaMobileApp(
        config: config,
        controller: controller,
        initialStream: null,
      ),
    );
    await tester.pump();

    expect(find.text('Subscribed path: /motd/message'), findsOneWidget);
    expect(find.text('Hello world!'), findsNothing);
    expect(startupPublisher.invocationCount, 1);
    expect(find.text('Status: sent'), findsOneWidget);
  });
}

class _FakeMotdRepository implements MotdRepository {
  const _FakeMotdRepository(this.message);

  final String? message;

  @override
  Stream<String?> subscribeToMessage({
    required String path,
  }) {
    return Stream<String?>.value(message);
  }
}

class _FakeStartupEventPublisher implements ApplicationEventPublisher {
  int invocationCount = 0;

  @override
  Future<StartupEventDispatchStatus> dispatchStartupEvent() async {
    invocationCount += 1;
    return StartupEventDispatchStatus.sent;
  }
}
