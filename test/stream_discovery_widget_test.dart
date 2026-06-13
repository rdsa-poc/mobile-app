import 'dart:async';

import 'package:flutter/material.dart';
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
    environmentName: 'test',
    missingKeys: <String>[],
    realtimeBaseUrl: 'http://127.0.0.1:5001',
  );

  final controller = BaselineParticipantController(
    motdRepository: const _StaticMotdRepository(),
    startupEventPublisher: _NoopStartupEventPublisher(),
  );

  // Test: renders published streams after an explicit loading state.
  // Validates: RDS-AC-019 (RDS-REQ-031 - Load published stream discovery data in mobile)
  testWidgets('renders loading first and then shows published discovery rows', (
    tester,
  ) async {
    final repository = _ControlledStreamRepository();

    await tester.pumpWidget(
      RadiosaMobileApp(
        config: config,
        controller: controller,
        initialStreamId: null,
        streamRepository: repository,
      ),
    );

    expect(find.text('Loading streams...'), findsOneWidget);

    repository.emitDiscovery(
      const StreamDiscoveryState.loaded([
        PublishedStream(
          imageUrl: 'https://cdn.example.com/streams/night-jazz.jpg',
          streamId: 'stream-night-jazz',
          streamUrl: 'https://radio.example.com/night-jazz.m3u8',
          summary: 'Late-night jazz programming with host-led transitions.',
          title: 'Night Jazz',
        ),
      ]),
    );
    await tester.pump();

    expect(find.text('Night Jazz'), findsOneWidget);
    expect(
      find.text('Late-night jazz programming with host-led transitions.'),
      findsOneWidget,
    );
  });

  // Test: keeps the discovery screen explicit when no published streams exist.
  // Validates: RDS-AC-021 (RDS-REQ-033 - Show explicit loading, empty, and error states for stream discovery)
  testWidgets('shows the empty placeholder when no published streams exist', (
    tester,
  ) async {
    final repository = _ControlledStreamRepository();

    await tester.pumpWidget(
      RadiosaMobileApp(
        config: config,
        controller: controller,
        initialStreamId: null,
        streamRepository: repository,
      ),
    );

    repository.emitDiscovery(const StreamDiscoveryState.empty());
    await tester.pump();

    expect(find.text('No streams available at the moment'), findsOneWidget);
  });

  // Test: opens the published detail screen and renders the larger image, title, and summary.
  // Validates: RDS-AC-020 (RDS-REQ-032 - Open published stream detail screens in mobile)
  testWidgets('renders published stream detail content from the repository', (
    tester,
  ) async {
    final repository = _ControlledStreamRepository();

    await tester.pumpWidget(
      RadiosaMobileApp(
        config: config,
        controller: controller,
        initialStreamId: 'stream-night-jazz',
        streamRepository: repository,
      ),
    );

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
    await tester.pump();

    expect(find.text('Night Jazz'), findsOneWidget);
    expect(
      find.text('Late-night jazz programming with host-led transitions.'),
      findsOneWidget,
    );
    expect(find.text('Stream URL', skipOffstage: false), findsOneWidget);
    expect(
      find.text(
        'https://radio.example.com/night-jazz.m3u8',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
  });

  // Test: shows a removal toast and returns to discovery when the selected stream disappears.
  // Validates: RDS-AC-064 (RDS-REQ-032 - Return to discovery if the selected published stream is removed)
  testWidgets('returns to discovery and shows a removal toast when the selected stream disappears', (
    tester,
  ) async {
    final repository = _ControlledStreamRepository();

    await tester.pumpWidget(
      RadiosaMobileApp(
        config: config,
        controller: controller,
        initialStreamId: 'stream-night-jazz',
        streamRepository: repository,
      ),
    );

    repository.emitDetail(const StreamDetailState.removed());
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Find the right stream for every moment.'), findsOneWidget);
    expect(find.text('This stream is no longer available.'), findsOneWidget);
  });
}

class _ControlledStreamRepository implements StreamRepository {
  final StreamController<StreamDiscoveryState> _discoveryController =
      StreamController<StreamDiscoveryState>.broadcast();
  final StreamController<StreamDetailState> _detailController =
      StreamController<StreamDetailState>.broadcast();

  void emitDetail(StreamDetailState state) {
    _detailController.add(state);
  }

  void emitDiscovery(StreamDiscoveryState state) {
    _discoveryController.add(state);
  }

  @override
  Stream<StreamDiscoveryState> watchDiscovery() async* {
    yield const StreamDiscoveryState.loading();
    yield* _discoveryController.stream;
  }

  @override
  Stream<StreamDetailState> watchStreamDetail(String streamId) async* {
    yield const StreamDetailState.loading();
    yield* _detailController.stream;
  }
}

class _StaticMotdRepository implements MotdRepository {
  const _StaticMotdRepository();

  @override
  Stream<String?> subscribeToMessage({required String path}) {
    return Stream<String?>.value(null);
  }
}

class _NoopStartupEventPublisher implements ApplicationEventPublisher {
  @override
  Future<StartupEventDispatchStatus> dispatchStartupEvent() async {
    return StartupEventDispatchStatus.sent;
  }
}
