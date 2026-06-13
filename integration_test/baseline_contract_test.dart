import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app/app/bootstrap_config.dart';
import 'package:app/app/radiosa_mobile_app.dart';
import 'package:app/entities/stream/published_stream.dart';
import 'package:app/shared/config/runtime_contract.dart';
import 'package:app/shared/data/repositories/application_event_repository.dart';
import 'package:app/shared/data/repositories/motd_repository.dart';
import 'package:app/shared/data/repositories/stream_repository.dart';
import 'package:app/shared/state/baseline_participant_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const config = BootstrapConfig(
    appId: 'app',
    baselineMotdMessage: '',
    databaseNamespace: 'radiosa-poc-default-rtdb',
    databaseUrl: 'http://127.0.0.1:9000',
    environmentName: 'local',
    missingKeys: <String>[],
    realtimeBaseUrl: 'http://localhost:5001',
  );

  // Test: keeps the mobile runtime anchored to the EP-001 realtime and startup boundaries.
  // Validates: RDS-AC-047, RDS-AC-049, RDS-AC-056 (RDS-REQ-055 - Subscribe to the motd message from the baseline mobile screen, RDS-REQ-057 - Render no message when the motd path is absent or empty, RDS-REQ-064 - Invoke onApplicationEvent from app startup)
  testWidgets(
      'anchors the baseline controller to the motd path and startup handoff', (
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

  // Test: exercises realtime discovery loading and detail navigation from the participant shell.
  // Validates: RDS-AC-019, RDS-AC-020 (RDS-REQ-031 - Load published stream discovery data in mobile, RDS-REQ-032 - Open published stream detail screens in mobile)
  testWidgets('shows realtime discovery rows and opens the detail screen', (
    tester,
  ) async {
    final repository = _ControlledStreamRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      _IntegrationHarness(
        config: config,
        streamRepository: repository,
      ),
    );

    expect(find.text('Loading streams...'), findsOneWidget);

    repository.emitDiscovery(
      const StreamDiscoveryState.loaded([
        _ControlledStreamRepository.nightJazz,
      ]),
    );
    await tester.pump();

    expect(find.text('Night Jazz'), findsOneWidget);
    expect(
      find.text('Late-night jazz programming with host-led transitions.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Night Jazz'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Now Playing'), 200);

    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Listeners'), findsOneWidget);
    expect(find.text('Play Stream'), findsOneWidget);
  });

  // Test: keeps stream discovery explicit for both empty and failed realtime responses.
  // Validates: RDS-AC-021 (RDS-REQ-033 - Show explicit loading, empty, and error states for stream discovery)
  testWidgets(
      'shows the approved placeholder when discovery is empty or unavailable', (
    tester,
  ) async {
    final emptyRepository = _ControlledStreamRepository();
    addTearDown(emptyRepository.dispose);

    await tester.pumpWidget(
      _IntegrationHarness(
        config: config,
        streamRepository: emptyRepository,
      ),
    );

    emptyRepository.emitDiscovery(const StreamDiscoveryState.empty());
    await tester.pump();

    expect(find.text('No streams available at the moment'), findsOneWidget);
    expect(
      find.text(
        'Published streams will appear here as soon as the realtime discovery projection is available.',
      ),
      findsOneWidget,
    );

    final errorRepository = _ControlledStreamRepository();
    addTearDown(errorRepository.dispose);

    await tester.pumpWidget(
      _IntegrationHarness(
        config: config,
        streamRepository: errorRepository,
      ),
    );
    errorRepository.emitDiscovery(const StreamDiscoveryState.error());
    await tester.pump();

    expect(find.text('No streams available at the moment'), findsOneWidget);
    expect(
      find.text(
        'We could not refresh live discovery right now, so the screen stays explicit instead of going blank.',
      ),
      findsOneWidget,
    );
  });

  // Test: returns to discovery with a toast when the selected stream is removed from realtime.
  // Validates: RDS-AC-064 (RDS-REQ-032 - Return to discovery if the selected published stream is removed)
  testWidgets(
      'shows a removal toast and returns to discovery after a realtime delete',
      (
    tester,
  ) async {
    final repository = _ControlledStreamRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      _IntegrationHarness(
        config: config,
        streamRepository: repository,
      ),
    );

    repository.emitDiscovery(
      const StreamDiscoveryState.loaded([
        _ControlledStreamRepository.nightJazz,
      ]),
    );
    await tester.pump();

    await tester.tap(find.text('Night Jazz'));
    await tester.pumpAndSettle();

    repository.emitDetail(const StreamDetailState.removed());
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('This stream is no longer available.'), findsOneWidget);
    expect(find.text('Discover'), findsWidgets);
    expect(find.text('Play Stream'), findsNothing);
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

class _IntegrationHarness extends StatelessWidget {
  const _IntegrationHarness({
    required this.config,
    required this.streamRepository,
  });

  final BootstrapConfig config;
  final StreamRepository streamRepository;

  @override
  Widget build(BuildContext context) {
    return RadiosaMobileApp(
      config: config,
      controller: BaselineParticipantController(
        motdRepository: const LocalBaselineMotdRepository(baselineMessage: ''),
        startupEventPublisher: _RecordingStartupEventPublisher(),
      ),
      initialStreamId: null,
      streamRepository: streamRepository,
    );
  }
}

class _ControlledStreamRepository implements StreamRepository {
  static const PublishedStream nightJazz = PublishedStream(
    imageUrl: 'https://cdn.example.com/streams/night-jazz.jpg',
    streamId: 'stream-night-jazz',
    streamUrl: 'https://radio.example.com/night-jazz.m3u8',
    summary: 'Late-night jazz programming with host-led transitions.',
    title: 'Night Jazz',
  );

  final StreamController<StreamDiscoveryState> _discoveryController =
      StreamController<StreamDiscoveryState>.broadcast();
  final StreamController<StreamDetailState> _detailController =
      StreamController<StreamDetailState>.broadcast();
  StreamDetailState _currentDetailState = const StreamDetailState.loaded(
    nightJazz,
  );

  void emitDetail(StreamDetailState state) {
    _currentDetailState = state;
    _detailController.add(state);
  }

  void emitDiscovery(StreamDiscoveryState state) {
    _discoveryController.add(state);
  }

  Future<void> dispose() async {
    await _discoveryController.close();
    await _detailController.close();
  }

  @override
  Stream<StreamDiscoveryState> watchDiscovery() async* {
    yield const StreamDiscoveryState.loading();
    yield* _discoveryController.stream;
  }

  @override
  Stream<StreamDetailState> watchStreamDetail(String streamId) async* {
    yield const StreamDetailState.loading();
    yield _currentDetailState;
    yield* _detailController.stream;
  }
}
