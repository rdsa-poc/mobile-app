import 'package:flutter/material.dart';

import '../shared/config/runtime_contract.dart';
import '../shared/data/repositories/application_event_repository.dart';
import '../shared/data/repositories/motd_repository.dart';
import '../shared/data/repositories/stream_repository.dart';
import '../shared/state/baseline_participant_controller.dart';
import 'bootstrap_config.dart';
import 'radiosa_mobile_app.dart';

void bootstrapRadiosaMobileApp() {
  final config = BootstrapConfig.fromEnvironment();
  final initialStreamId = resolveInitialStreamId(Uri.base);

  runApp(
    config.missingKeys.isEmpty
        ? RadiosaMobileApp(
            config: config,
            initialStreamId: initialStreamId,
            controller: BaselineParticipantController(
              startupEventPublisher: HttpApplicationEventPublisher(
                baseUrl: config.realtimeBaseUrl,
              ),
              motdRepository: LocalBaselineMotdRepository(
                baselineMessage: config.baselineMotdMessage,
              ),
            ),
            streamRepository: RealtimeStreamRepository(
              databaseUrl: config.databaseUrl,
              namespace: config.databaseNamespace,
            ),
          )
        : ConfigurationErrorApp(missingKeys: config.missingKeys),
  );
}

String? resolveInitialStreamId(Uri currentUri) {
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

  return segments[1];
}
