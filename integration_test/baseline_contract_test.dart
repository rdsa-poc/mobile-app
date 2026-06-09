import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app/shared/config/runtime_contract.dart';
import 'package:app/shared/data/repositories/application_event_repository.dart';
import 'package:app/shared/data/repositories/motd_repository.dart';
import 'package:app/shared/state/baseline_participant_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Test: keeps the mobile runtime anchored to the EP-001 realtime and startup boundaries.
  // Validates: RDS-AC-047, RDS-AC-049, RDS-AC-056 (RDS-REQ-055 - Subscribe to the motd message from the baseline mobile screen, RDS-REQ-057 - Render no message when the motd path is absent or empty, RDS-REQ-064 - Invoke onApplicationEvent from app startup)
  testWidgets('anchors the baseline controller to the motd path and startup handoff', (
    tester,
  ) async {
    final startupPublisher = _RecordingStartupEventPublisher();
    final controller = BaselineParticipantController(
      motdRepository: const LocalBaselineMotdRepository(baselineMessage: ''),
      startupEventPublisher: startupPublisher,
    );

    expect(await controller.subscribeToMotd().first, isNull);
    await controller.beginStartup();

    expect(startupPublisher.lastStatus, StartupEventDispatchStatus.sent);
    expect(startupPublisher.invocationCount, 1);
    expect(kMotdMessagePath, '/motd/message');
    expect(kStartupEventFunctionPath, '/onApplicationEvent');
  });
}

class _RecordingStartupEventPublisher implements ApplicationEventPublisher {
  int invocationCount = 0;
  StartupEventDispatchStatus? lastStatus;

  @override
  Future<StartupEventDispatchStatus> dispatchStartupEvent() async {
    invocationCount += 1;
    lastStatus = StartupEventDispatchStatus.sent;
    return lastStatus!;
  }
}
