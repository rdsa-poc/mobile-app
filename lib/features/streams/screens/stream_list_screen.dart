import 'package:flutter/material.dart';

import '../../../app/bootstrap_config.dart';
import '../../../entities/stream/placeholder_stream.dart';
import '../../../shared/config/runtime_contract.dart';
import '../../../shared/data/repositories/application_event_repository.dart';
import '../../../shared/state/baseline_participant_controller.dart';
import '../../../shared/ui/status_badge.dart';
import '../../motd/widgets/motd_message_card.dart';
import 'stream_detail_screen.dart';

class StreamListScreen extends StatefulWidget {
  const StreamListScreen({
    super.key,
    required this.config,
    required this.controller,
    required this.streams,
  });

  final BootstrapConfig config;
  final BaselineParticipantController controller;
  final List<PlaceholderStream> streams;

  @override
  State<StreamListScreen> createState() => _StreamListScreenState();
}

class _StreamListScreenState extends State<StreamListScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.beginStartup();
  }

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
            environmentName: widget.config.environmentName,
            realtimeBaseUrl: widget.config.realtimeBaseUrl,
          ),
          const SizedBox(height: 16),
          StreamBuilder<String?>(
            stream: widget.controller.subscribeToMotd(),
            builder: (context, snapshot) {
              return MotdMessageCard(
                message: snapshot.data,
                path: kMotdMessagePath,
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              return _StartupEventCard(
                status: widget.controller.startupStatus,
              );
            },
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
          if (widget.streams.isEmpty)
            const _EmptyStateCard()
          else
            for (final stream in widget.streams) ...[
              _StreamListCard(config: widget.config, stream: stream),
              const SizedBox(height: 12),
            ],
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

class _StartupEventCard extends StatelessWidget {
  const _StartupEventCard({
    required this.status,
  });

  final StartupEventDispatchStatus status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Startup Event Handoff',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Function: onApplicationEvent'),
            Text('Status: ${status.label}'),
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
              builder: (context) =>
                  StreamDetailScreen(config: config, stream: stream),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(label: stream.status),
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
            Text(
              'No placeholder streams are available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
