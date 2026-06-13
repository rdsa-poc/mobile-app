import 'package:flutter/material.dart';

import '../features/streams/screens/stream_detail_screen.dart';
import '../features/streams/screens/stream_list_screen.dart';
import '../shared/data/repositories/stream_repository.dart';
import '../shared/state/baseline_participant_controller.dart';
import 'bootstrap_config.dart';

class RadiosaMobileApp extends StatelessWidget {
  const RadiosaMobileApp({
    super.key,
    required this.config,
    required this.controller,
    required this.initialStreamId,
    required this.streamRepository,
  });

  final BootstrapConfig config;
  final BaselineParticipantController controller;
  final String? initialStreamId;
  final StreamRepository streamRepository;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0E6F4B),
      brightness: Brightness.light,
    ).copyWith(surface: const Color(0xFFFFFBF6));

    return MaterialApp(
      title: 'Radiosa Mobile App',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF8F2EA),
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: colorScheme.surface,
          indicatorColor: colorScheme.primaryContainer,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color:
                  selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
        useMaterial3: true,
      ),
      home: initialStreamId == null
          ? StreamListScreen(
              config: config,
              controller: controller,
              streamRepository: streamRepository,
            )
          : StreamDetailScreen(
              config: config,
              discoveryScreenBuilder: (showRemovalToast) => StreamListScreen(
                config: config,
                controller: controller,
                showRemovalToastOnStart: showRemovalToast,
                streamRepository: streamRepository,
              ),
              streamId: initialStreamId!,
              streamRepository: streamRepository,
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
