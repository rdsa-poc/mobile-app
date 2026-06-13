import 'package:flutter/material.dart';

import '../../../app/bootstrap_config.dart';
import '../../../entities/stream/published_stream.dart';
import '../../../shared/data/repositories/stream_repository.dart';
import '../../../shared/ui/status_badge.dart';

const kRemovedStreamMessage = 'This stream is no longer available.';

class StreamDetailScreen extends StatefulWidget {
  StreamDetailScreen({
    super.key,
    required this.config,
    required this.discoveryScreenBuilder,
    required this.streamId,
    required this.streamRepository,
  });

  final BootstrapConfig config;
  final Widget Function(bool showRemovalToast) discoveryScreenBuilder;
  final String streamId;
  final StreamRepository streamRepository;

  @override
  State<StreamDetailScreen> createState() => _StreamDetailScreenState();
}

class _StreamDetailScreenState extends State<StreamDetailScreen> {
  bool _handledRemoval = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StreamDetailState>(
      stream: widget.streamRepository.watchStreamDetail(widget.streamId),
      builder: (context, snapshot) {
        final detailState = snapshot.data ?? const StreamDetailState.loading();

        switch (detailState.status) {
          case StreamDetailStatus.loading:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case StreamDetailStatus.error:
            return _DetailPlaceholderScaffold(
              actionLabel: 'Back to Discovery',
              message:
                  'We could not refresh this stream from the live projection right now.',
              onPressed: () => _navigateToDiscovery(context),
              title: 'Stream detail unavailable',
            );
          case StreamDetailStatus.removed:
            _navigateBackAfterRemoval(context);
            return _DetailPlaceholderScaffold(
              actionLabel: 'Back to Discovery',
              message:
                  'This stream was removed from the published discovery projection.',
              onPressed: () => _navigateToDiscovery(context),
              title: 'Stream no longer available',
            );
          case StreamDetailStatus.loaded:
            return _LoadedStreamDetailScreen(
              config: widget.config,
              stream: detailState.stream!,
            );
        }
      },
    );
  }

  void _navigateBackAfterRemoval(BuildContext context) {
    if (_handledRemoval) {
      return;
    }

    _handledRemoval = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _navigateToDiscovery(context, showRemovalToast: true);
    });
  }

  void _navigateToDiscovery(
    BuildContext context, {
    bool showRemovalToast = false,
  }) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(showRemovalToast);
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => widget.discoveryScreenBuilder(showRemovalToast),
      ),
    );
  }
}

class _LoadedStreamDetailScreen extends StatelessWidget {
  const _LoadedStreamDetailScreen({
    required this.config,
    required this.stream,
  });

  final BootstrapConfig config;
  final PublishedStream stream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final factRows = _buildFactRows();

    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Play Stream'),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const _DetailTopBar(),
            const SizedBox(height: 18),
            Stack(
              children: [
                _DetailStreamImage(imageUrl: stream.imageUrl, height: 238),
                const Positioned(
                  right: 16,
                  bottom: 16,
                  child: StatusBadge(label: 'LIVE'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stream.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Published stream • Realtime projection',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              stream.summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.55,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 20),
            Text(
              'Now Playing',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _NowPlayingCard(stream: stream),
            const SizedBox(height: 24),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  children: [
                    for (var index = 0; index < factRows.length; index++) ...[
                      _DetailFactRow(fact: factRows[index]),
                      if (index != factRows.length - 1)
                        Divider(height: 1, color: colorScheme.outlineVariant),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_DetailFact> _buildFactRows() {
    return <_DetailFact>[
      const _DetailFact(
        label: 'Listeners',
        value: 'Live audience',
      ),
      _DetailFact(
        label: 'Stream ID',
        value: stream.streamId,
      ),
      _DetailFact(
        label: 'Stream URL',
        value: stream.streamUrl,
      ),
      _DetailFact(
        label: 'Projection',
        value: '/mobile/streams/${stream.streamId}',
      ),
      _DetailFact(
        label: 'Realtime shell',
        value: config.realtimeBaseUrl,
      ),
    ];
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TopBarButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const Spacer(),
        _TopBarButton(
          icon: Icons.more_horiz_rounded,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({
    required this.stream,
  });

  final PublishedStream stream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _DetailStreamImage(
              imageUrl: stream.imageUrl,
              height: 56,
              width: 56,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Live from the published projection',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.graphic_eq_rounded,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailFactRow extends StatelessWidget {
  const _DetailFactRow({
    required this.fact,
  });

  final _DetailFact fact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              fact.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              fact.value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailFact {
  const _DetailFact({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _DetailPlaceholderScaffold extends StatelessWidget {
  const _DetailPlaceholderScaffold({
    required this.actionLabel,
    required this.message,
    required this.onPressed,
    required this.title,
  });

  final String actionLabel;
  final String message;
  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(actionLabel),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const _DetailTopBar(),
            const SizedBox(height: 18),
            Container(
              height: 238,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.surfaceContainerHighest,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.radio_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discovery updates in realtime, so unavailable streams return you to the published list.',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStreamImage extends StatelessWidget {
  const _DetailStreamImage({
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
      borderRadius: BorderRadius.circular(28),
      child: Image.network(
        imageUrl,
        errorBuilder: (_, __, ___) {
          return Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            height: height,
            width: width,
            child: const Icon(Icons.radio, size: 32),
          );
        },
        fit: BoxFit.cover,
        height: height,
        width: width,
      ),
    );
  }
}
