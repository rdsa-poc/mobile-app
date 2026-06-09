import 'package:flutter/material.dart';

import '../entities/stream/placeholder_stream.dart';
import '../features/streams/model/mock_streams.dart';
import '../features/streams/screens/stream_detail_screen.dart';
import '../features/streams/screens/stream_list_screen.dart';
import '../shared/state/baseline_participant_controller.dart';
import 'bootstrap_config.dart';

class RadiosaMobileApp extends StatelessWidget {
  const RadiosaMobileApp({
    super.key,
    required this.config,
    required this.controller,
    required this.initialStream,
  });

  final BootstrapConfig config;
  final BaselineParticipantController controller;
  final PlaceholderStream? initialStream;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radiosa Mobile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B87)),
        useMaterial3: true,
      ),
      home: initialStream == null
          ? StreamListScreen(
              config: config,
              controller: controller,
              streams: mockedStreams,
            )
          : StreamDetailScreen(
              config: config,
              stream: initialStream!,
            ),
    );
  }
}

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({
    super.key,
    required this.missingKeys,
  });

  final List<String> missingKeys;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radiosa Mobile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8D2F2F)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Radiosa Mobile App Setup Error')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Missing required configuration values',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start the app with the missing shared .env values passed through --dart-define-from-file or --dart-define.',
            ),
            const SizedBox(height: 24),
            for (final missingKey in missingKeys)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  missingKey,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
