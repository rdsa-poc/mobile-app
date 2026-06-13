import 'package:flutter/material.dart';

import '../../../app/bootstrap_config.dart';
import '../../../entities/stream/published_stream.dart';
import '../../../shared/config/runtime_contract.dart';
import '../../../shared/data/repositories/application_event_repository.dart';
import '../../../shared/data/repositories/stream_repository.dart';
import '../../../shared/state/baseline_participant_controller.dart';
import '../../../shared/ui/status_badge.dart';
import '../../motd/widgets/motd_message_card.dart';
import 'stream_detail_screen.dart';

class StreamListScreen extends StatefulWidget {
  const StreamListScreen({
    super.key,
    required this.config,
    required this.controller,
    this.showRemovalToastOnStart = false,
    required this.streamRepository,
  });

  final BootstrapConfig config;
  final BaselineParticipantController controller;
  final bool showRemovalToastOnStart;
  final StreamRepository streamRepository;

  @override
  State<StreamListScreen> createState() => _StreamListScreenState();
}

class _StreamListScreenState extends State<StreamListScreen> {
  bool _didShowRemovalToast = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    widget.controller.beginStartup();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRemovalToastIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        bottomNavigationBar: const _DiscoveryBottomNavigationBar(),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              return StreamBuilder<String?>(
                stream: widget.controller.subscribeToMotd(),
                builder: (context, motdSnapshot) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    children: [
                      const _BrandedHeader(),
                      const SizedBox(height: 28),
                      Text(
                        'Discover',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find the right stream for every moment.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 20),
                      const SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _CategoryChip(label: 'All', selected: true),
                            SizedBox(width: 10),
                            _CategoryChip(label: 'Music'),
                            SizedBox(width: 10),
                            _CategoryChip(label: 'Talk'),
                            SizedBox(width: 10),
                            _CategoryChip(label: 'Sports'),
                            SizedBox(width: 10),
                            _CategoryChip(label: 'Chill'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder<StreamDiscoveryState>(
                        stream: widget.streamRepository.watchDiscovery(),
                        builder: (context, snapshot) {
                          final discoveryState = snapshot.data ??
                              const StreamDiscoveryState.loading();

                          switch (discoveryState.status) {
                            case StreamDiscoveryStatus.loading:
                              return const _LoadingStateCard();
                            case StreamDiscoveryStatus.empty:
                              return const _DiscoveryStateCard(
                                icon: Icons.graphic_eq_rounded,
                                title: kEmptyStreamsMessage,
                                description:
                                    'Published streams will appear here as soon as the realtime discovery projection is available.',
                              );
                            case StreamDiscoveryStatus.error:
                              return const _DiscoveryStateCard(
                                icon: Icons.wifi_tethering_error_rounded,
                                title: kEmptyStreamsMessage,
                                description:
                                    'We could not refresh live discovery right now, so the screen stays explicit instead of going blank.',
                              );
                            case StreamDiscoveryStatus.loaded:
                              return Column(
                                children: [
                                  for (final stream
                                      in discoveryState.streams) ...[
                                    _StreamListCard(
                                      onPressed: () =>
                                          _openStreamDetail(stream),
                                      stream: stream,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ],
                              );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _RealtimeSupportPanel(
                        motdMessage: motdSnapshot.data,
                        startupStatus: widget.controller.startupStatus,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRemovalToastIfNeeded() {
    if (!mounted || !widget.showRemovalToastOnStart || _didShowRemovalToast) {
      return;
    }

    _didShowRemovalToast = true;
    _showRemovedStreamToast();
  }

  Future<void> _openStreamDetail(PublishedStream stream) async {
    final shouldShowRemovalToast = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => StreamDetailScreen(
          config: widget.config,
          discoveryScreenBuilder: (showRemovalToast) => StreamListScreen(
            config: widget.config,
            controller: widget.controller,
            showRemovalToastOnStart: showRemovalToast,
            streamRepository: widget.streamRepository,
          ),
          streamId: stream.streamId,
          streamRepository: widget.streamRepository,
        ),
      ),
    );

    if (!mounted || shouldShowRemovalToast != true) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _showRemovedStreamToast();
    });
  }

  void _showRemovedStreamToast() {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(kRemovedStreamMessage),
        ),
      );
  }
}

class _BrandedHeader extends StatelessWidget {
  const _BrandedHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.graphic_eq_rounded,
                  color: colorScheme.onPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'radiosa',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: null,
          icon: const Icon(Icons.search_rounded),
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surface,
            disabledBackgroundColor: colorScheme.surface,
            disabledForegroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? colorScheme.primary : colorScheme.surface,
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _StreamListCard extends StatelessWidget {
  const _StreamListCard({
    required this.onPressed,
    required this.stream,
  });

  final VoidCallback onPressed;
  final PublishedStream stream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StreamImage(
                  imageUrl: stream.imageUrl,
                  height: 82,
                  width: 82,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              stream.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const StatusBadge(label: 'LIVE'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Published stream • Available now',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stream.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _RealtimeSupportPanel extends StatelessWidget {
  const _RealtimeSupportPanel({
    required this.motdMessage,
    required this.startupStatus,
  });

  final String? motdMessage;
  final StartupEventDispatchStatus startupStatus;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Realtime support',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${startupStatus.label}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            MotdMessageCard(
              message: motdMessage,
              path: kMotdMessagePath,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryStateCard extends StatelessWidget {
  const _DiscoveryStateCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingStateCard extends StatelessWidget {
  const _LoadingStateCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loading streams...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connecting to the published discovery projection.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryBottomNavigationBar extends StatelessWidget {
  const _DiscoveryBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 74,
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border_rounded),
          selectedIcon: Icon(Icons.favorite_rounded),
          label: 'Favorites',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today_rounded),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _StreamImage extends StatelessWidget {
  const _StreamImage({
    required this.imageUrl,
    required this.height,
    this.width = double.infinity,
  });

  final String imageUrl;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        errorBuilder: (_, __, ___) {
          return Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            height: height,
            width: width,
            child: const Icon(Icons.radio),
          );
        },
        fit: BoxFit.cover,
        height: height,
        width: width,
      ),
    );
  }
}
