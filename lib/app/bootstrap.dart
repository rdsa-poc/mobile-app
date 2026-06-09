import 'package:flutter/material.dart';

import '../entities/stream/placeholder_stream.dart';
import '../features/streams/model/mock_streams.dart';
import '../shared/config/runtime_contract.dart';
import '../shared/data/repositories/application_event_repository.dart';
import '../shared/data/repositories/motd_repository.dart';
import '../shared/state/baseline_participant_controller.dart';
import 'bootstrap_config.dart';
import 'radiosa_mobile_app.dart';

void bootstrapRadiosaMobileApp() {
  final config = BootstrapConfig.fromEnvironment();
  final initialStream = resolveInitialStream(Uri.base);

  runApp(
    config.missingKeys.isEmpty
        ? RadiosaMobileApp(
            config: config,
            initialStream: initialStream,
            controller: BaselineParticipantController(
              startupEventPublisher: HttpApplicationEventPublisher(
                baseUrl: config.realtimeBaseUrl,
              ),
              motdRepository: LocalBaselineMotdRepository(
                baselineMessage: config.baselineMotdMessage,
              ),
            ),
          )
        : ConfigurationErrorApp(missingKeys: config.missingKeys),
  );
}

PlaceholderStream? resolveInitialStream(Uri currentUri) {
  final fragment = currentUri.fragment;
  if (fragment.isEmpty) {
    return null;
  }

  final normalizedFragment =
      fragment.startsWith('/') ? fragment.substring(1) : fragment;
  final segments = Uri(path: normalizedFragment).pathSegments;
  if (segments.length != 2 || segments.first != kStreamsRouteSegment) {
    return null;
  }

  return findPlaceholderStreamById(segments[1]);
}
