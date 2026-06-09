import 'package:flutter/material.dart';

import '../../../app/bootstrap_config.dart';
import '../../../entities/stream/placeholder_stream.dart';
import '../../../shared/ui/status_badge.dart';

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
          StatusBadge(label: stream.status),
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
                  Text(
                    'Participant View Placeholder',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
                  Text(
                    'Baseline Smoke Flow',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
                  Text(
                    'Current Placeholder State',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
