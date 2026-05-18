import 'package:flutter/material.dart';

const mockedStreams = <PlaceholderStream>[
  PlaceholderStream(
    streamId: 'stream-smoke-demo',
    title: 'Smoke Flow Demo Stream',
    status: 'Ready for bootstrap',
    summary:
        'Matches the scaffold smoke-flow bootstrap contract served by bof-be and rt-fn.',
    scheduleLabel: 'Use the documented baseline smoke flow',
    smokeFlowId: 'baseline-smoke-flow',
    quizId: 'quiz-smoke-demo',
    participantId: 'participant-smoke-demo',
  ),
  PlaceholderStream(
    streamId: 'stream-night-quiz',
    title: 'Night Quiz Warmup',
    status: 'Open lobby',
    summary: 'Static stream entry used to preview the participant join experience.',
    scheduleLabel: 'Lobby available now',
    smokeFlowId: 'night-quiz-placeholder',
    quizId: 'quiz-night-placeholder',
    participantId: 'participant-night-placeholder',
  ),
  PlaceholderStream(
    streamId: 'stream-recap',
    title: 'Results Recap',
    status: 'Archived placeholder',
    summary: 'Shows where replay and recap details will be surfaced later.',
    scheduleLabel: 'Read-only placeholder state',
    smokeFlowId: 'results-recap-placeholder',
    quizId: 'quiz-results-placeholder',
    participantId: 'participant-results-placeholder',
  ),
];

void main() {
  final config = BootstrapConfig.fromEnvironment();
  final initialStream = resolveInitialStream(Uri.base);
  runApp(
    config.missingKeys.isEmpty
        ? RadiosaMobileApp(config: config, initialStream: initialStream)
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
  if (segments.length != 2 || segments.first != 'streams') {
    return null;
  }

  final requestedStreamId = segments[1];
  for (final stream in mockedStreams) {
    if (stream.streamId == requestedStreamId) {
      return stream;
    }
  }

  return null;
}

class BootstrapConfig {
  const BootstrapConfig({
    required this.appId,
    required this.environmentName,
    required this.missingKeys,
    required this.realtimeBaseUrl,
  });

  factory BootstrapConfig.fromEnvironment() {
    const appId = String.fromEnvironment('RADIOSA_APP_ID');
    const environmentName = String.fromEnvironment('RADIOSA_ENVIRONMENT');
    const realtimeBaseUrl =
        String.fromEnvironment('RADIOSA_REALTIME_BASE_URL');

    final missingKeys = <String>[
      if (appId.isEmpty) 'RADIOSA_APP_ID',
      if (environmentName.isEmpty) 'RADIOSA_ENVIRONMENT',
      if (realtimeBaseUrl.isEmpty) 'RADIOSA_REALTIME_BASE_URL',
    ];

    return BootstrapConfig(
      appId: appId,
      environmentName: environmentName,
      missingKeys: missingKeys,
      realtimeBaseUrl: realtimeBaseUrl,
    );
  }

  final String appId;
  final String environmentName;
  final List<String> missingKeys;
  final String realtimeBaseUrl;
}

class RadiosaMobileApp extends StatelessWidget {
  const RadiosaMobileApp({
    super.key,
    required this.config,
    required this.initialStream,
  });

  final BootstrapConfig config;
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
              'Start the app with the missing RADIOSA_* values passed through --dart-define.',
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

class PlaceholderStream {
  const PlaceholderStream({
    required this.participantId,
    required this.quizId,
    required this.smokeFlowId,
    required this.streamId,
    required this.title,
    required this.status,
    required this.summary,
    required this.scheduleLabel,
  });

  final String participantId;
  final String quizId;
  final String smokeFlowId;
  final String streamId;
  final String title;
  final String status;
  final String summary;
  final String scheduleLabel;
}

class StreamListScreen extends StatelessWidget {
  const StreamListScreen({
    super.key,
    required this.config,
    required this.streams,
  });

  final BootstrapConfig config;
  final List<PlaceholderStream> streams;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radiosa Streams'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _HeroCard(
            environmentName: config.environmentName,
            realtimeBaseUrl: config.realtimeBaseUrl,
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose a placeholder stream',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'This list is static for the PoC scaffold. Selecting an item opens the future participant stream detail surface.',
          ),
          const SizedBox(height: 20),
          if (streams.isEmpty)
            const _EmptyStateCard()
          else
            for (final stream in streams) ...[
              _StreamListCard(config: config, stream: stream),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class StreamDetailScreen extends StatelessWidget {
  const StreamDetailScreen({
    super.key,
    required this.config,
    required this.stream,
  });

  final BootstrapConfig config;
  final PlaceholderStream stream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Detail'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            stream.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          _StatusBadge(label: stream.status),
          const SizedBox(height: 16),
          Text(
            stream.summary,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Participant View Placeholder', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(stream.scheduleLabel),
                  const SizedBox(height: 12),
                  const Text(
                    'Future live quiz, answer entry, and realtime updates will be rendered here.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Baseline Smoke Flow', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Smoke flow id: ${stream.smokeFlowId}'),
                  Text('Quiz id: ${stream.quizId}'),
                  Text('Participant id: ${stream.participantId}'),
                  Text('Realtime shell: ${config.realtimeBaseUrl}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Placeholder State', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Join actions are intentionally inactive until stream runtime behavior is implemented.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.environmentName,
    required this.realtimeBaseUrl,
  });

  final String environmentName;
  final String realtimeBaseUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mobile Placeholder Stream List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Environment $environmentName is pointed at $realtimeBaseUrl with mocked participant stream data.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamListCard extends StatelessWidget {
  const _StreamListCard({
    required this.config,
    required this.stream,
  });

  final BootstrapConfig config;
  final PlaceholderStream stream;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => StreamDetailScreen(config: config, stream: stream),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBadge(label: stream.status),
              const SizedBox(height: 12),
              Text(stream.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(stream.summary),
              const SizedBox(height: 12),
              Text(
                stream.scheduleLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No placeholder streams are available', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Keep the participant app explicit about missing stream data instead of showing a silent blank state.',
            ),
          ],
        ),
      ),
    );
  }
}
