import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:app/app/bootstrap_config.dart';
import 'package:app/app/radiosa_mobile_app.dart';
import 'package:app/entities/stream/published_stream.dart';
import 'package:app/shared/data/repositories/application_event_repository.dart';
import 'package:app/shared/data/repositories/motd_repository.dart';
import 'package:app/shared/data/repositories/stream_repository.dart';
import 'package:app/shared/state/baseline_participant_controller.dart';

void main() {
  const config = BootstrapConfig(
    appId: 'app',
    baselineMotdMessage: '',
    databaseNamespace: 'radiosa-poc-default-rtdb',
    databaseUrl: 'http://127.0.0.1:9000',
    environmentName: 'local',
    missingKeys: <String>[],
    realtimeBaseUrl: 'http://localhost:5001',
  );

  // Test: renders the baseline mobile screen and realtime MOTD message text.
  // Validates: RDS-AC-019, RDS-AC-046, RDS-AC-047, RDS-AC-048 (RDS-REQ-031 - Load published stream discovery data in mobile, RDS-REQ-054 - Provide a baseline mobile screen in app, RDS-REQ-055 - Subscribe to the motd message from the baseline mobile screen, RDS-REQ-056 - Render the motd value on the baseline mobile screen)
  testWidgets(
      'renders the baseline mobile screen with the realtime MOTD message', (
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
        initialStreamId: null,
        streamRepository: _FakeStreamRepository.discovery(
          const StreamDiscoveryState.loaded([
            PublishedStream(
              imageUrl: 'https://cdn.example.com/streams/night-jazz.jpg',
              streamId: 'stream-night-jazz',
              streamUrl: 'https://radio.example.com/night-jazz.m3u8',
              summary: 'Late-night jazz programming with host-led transitions.',
              title: 'Night Jazz',
            ),
          ]),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Discover'), findsWidgets);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Subscribed path: /motd/message'), findsOneWidget);
    expect(find.text('Hello world!'), findsOneWidget);
    expect(find.text('Night Jazz'), findsWidgets);
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  // Test: renders no message text when the baseline MOTD path is empty and still sends one startup event.
  // Validates: RDS-AC-021, RDS-AC-049, RDS-AC-056 (RDS-REQ-033 - Show explicit loading, empty, and error states for stream discovery, RDS-REQ-057 - Render no message when the motd path is absent or empty, RDS-REQ-064 - Invoke onApplicationEvent from app startup)
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
        initialStreamId: null,
        streamRepository: _FakeStreamRepository.discovery(
          const StreamDiscoveryState.empty(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Subscribed path: /motd/message'), findsOneWidget);
    expect(find.text('Hello world!'), findsNothing);
    expect(startupPublisher.invocationCount, 1);
    expect(find.text('Status: sent'), findsOneWidget);
    expect(find.text('No streams available at the moment'), findsOneWidget);
  });

  // Test: keeps the discovery screen explicit when realtime discovery fails.
  // Validates: RDS-AC-021 (RDS-REQ-033 - Show explicit loading, empty, and error states for stream discovery)
  testWidgets('renders an explicit fallback message when discovery fails', (
    tester,
  ) async {
    final controller = BaselineParticipantController(
      motdRepository: const _FakeMotdRepository(null),
      startupEventPublisher: _FakeStartupEventPublisher(),
    );

    await tester.pumpWidget(
      RadiosaMobileApp(
        config: config,
        controller: controller,
        initialStreamId: null,
        streamRepository: _FakeStreamRepository.discovery(
          const StreamDiscoveryState.error(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No streams available at the moment'), findsOneWidget);
    expect(
      find.text(
        'We could not refresh live discovery right now, so the screen stays explicit instead of going blank.',
      ),
      findsOneWidget,
    );
  });

  // Test: opens stream detail from discovery and renders the approved detail structure.
  // Validates: RDS-AC-020 (RDS-REQ-032 - Open published stream detail screens in mobile)
  testWidgets('opens stream detail from discovery with the full detail layout',
      (
    tester,
  ) async {
    final controller = BaselineParticipantController(
      motdRepository: const _FakeMotdRepository(null),
      startupEventPublisher: _FakeStartupEventPublisher(),
    );
    final repository = _ControlledStreamRepository();

    await tester.pumpWidget(
      RadiosaMobileApp(
        config: config,
        controller: controller,
        initialStreamId: null,
        streamRepository: repository,
      ),
    );
    await tester.pump();

    repository.emitDetail(
      const StreamDetailState.loaded(
        PublishedStream(
          imageUrl: 'https://cdn.example.com/streams/night-jazz.jpg',
          streamId: 'stream-night-jazz',
          streamUrl: 'https://radio.example.com/night-jazz.m3u8',
          summary: 'Late-night jazz programming with host-led transitions.',
          title: 'Night Jazz',
        ),
      ),
    );

    await tester.tap(find.text('Night Jazz'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Now Playing'), 200);

    expect(find.text('Night Jazz'), findsWidgets);
    expect(
      find.text('Late-night jazz programming with host-led transitions.'),
      findsOneWidget,
    );
    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Listeners'), findsOneWidget);
    expect(find.text('Play Stream'), findsOneWidget);
  });

  // Test: returns to discovery and shows a toast when the selected stream disappears.
  // Validates: RDS-AC-064 (RDS-REQ-032 - Return to discovery if the selected published stream is removed)
  testWidgets(
      'returns to discovery with a toast when the detail stream disappears', (
    tester,
  ) async {
    final controller = BaselineParticipantController(
      motdRepository: const _FakeMotdRepository(null),
      startupEventPublisher: _FakeStartupEventPublisher(),
    );
    final repository = _ControlledStreamRepository();

    await tester.pumpWidget(
      RadiosaMobileApp(
        config: config,
        controller: controller,
        initialStreamId: null,
        streamRepository: repository,
      ),
    );
    await tester.pump();

    repository.emitDetail(
      const StreamDetailState.loaded(
        PublishedStream(
          imageUrl: 'https://cdn.example.com/streams/night-jazz.jpg',
          streamId: 'stream-night-jazz',
          streamUrl: 'https://radio.example.com/night-jazz.m3u8',
          summary: 'Late-night jazz programming with host-led transitions.',
          title: 'Night Jazz',
        ),
      ),
    );

    await tester.tap(find.text('Night Jazz'));
    await tester.pumpAndSettle();

    repository.emitDetail(const StreamDetailState.removed());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('This stream is no longer available.'), findsOneWidget);
    expect(find.text('Discover'), findsWidgets);
    expect(find.text('Play Stream'), findsNothing);
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

class _FakeStreamRepository implements StreamRepository {
  const _FakeStreamRepository.discovery(this.discoveryState);

  final StreamDiscoveryState? discoveryState;

  @override
  Stream<StreamDiscoveryState> watchDiscovery() {
    return Stream<StreamDiscoveryState>.value(
      discoveryState ?? const StreamDiscoveryState.empty(),
    );
  }

  @override
  Stream<StreamDetailState> watchStreamDetail(String streamId) {
    return Stream<StreamDetailState>.value(const StreamDetailState.removed());
  }
}

class _ControlledStreamRepository implements StreamRepository {
  _ControlledStreamRepository({
    StreamDetailState initialDetailState =
        const StreamDetailState.loaded(_nightJazz),
  }) : _currentDetailState = initialDetailState;

  static const PublishedStream _nightJazz = PublishedStream(
    imageUrl: 'https://cdn.example.com/streams/night-jazz.jpg',
    streamId: 'stream-night-jazz',
    streamUrl: 'https://radio.example.com/night-jazz.m3u8',
    summary: 'Late-night jazz programming with host-led transitions.',
    title: 'Night Jazz',
  );

  final StreamController<StreamDetailState> _detailController =
      StreamController<StreamDetailState>.broadcast();
  StreamDetailState _currentDetailState;

  void emitDetail(StreamDetailState state) {
    _currentDetailState = state;
    _detailController.add(state);
  }

  @override
  Stream<StreamDiscoveryState> watchDiscovery() {
    return Stream<StreamDiscoveryState>.value(
      const StreamDiscoveryState.loaded([_nightJazz]),
    );
  }

  @override
  Stream<StreamDetailState> watchStreamDetail(String streamId) async* {
    yield const StreamDetailState.loading();
    yield _currentDetailState;
    yield* _detailController.stream;
  }
}
