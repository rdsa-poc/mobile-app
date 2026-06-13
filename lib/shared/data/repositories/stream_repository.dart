import '../../../entities/stream/published_stream.dart';
import '../services/realtime_database_client.dart';
import '../services/realtime_database_client_base.dart';

abstract class StreamRepository {
  Stream<StreamDiscoveryState> watchDiscovery();
  Stream<StreamDetailState> watchStreamDetail(String streamId);
}

class RealtimeStreamRepository implements StreamRepository {
  RealtimeStreamRepository({
    required this.databaseUrl,
    required this.namespace,
    RealtimeDatabaseClient? databaseClient,
  }) : _databaseClient = databaseClient ?? createRealtimeDatabaseClient();

  final RealtimeDatabaseClient _databaseClient;
  final String databaseUrl;
  final String namespace;

  @override
  Stream<StreamDiscoveryState> watchDiscovery() async* {
    yield const StreamDiscoveryState.loading();

    try {
      var currentSnapshot = <String, Object?>{};

      await for (final event
          in _databaseClient.watchJson(_resolveDiscoveryUri())) {
        currentSnapshot = _applyRealtimeEvent(currentSnapshot, event);
        yield _buildDiscoveryState(currentSnapshot);
      }
    } catch (_) {
      yield const StreamDiscoveryState.error();
    }
  }

  @override
  Stream<StreamDetailState> watchStreamDetail(String streamId) async* {
    await for (final discoveryState in watchDiscovery()) {
      switch (discoveryState.status) {
        case StreamDiscoveryStatus.loading:
          yield const StreamDetailState.loading();
        case StreamDiscoveryStatus.error:
          yield const StreamDetailState.error();
        case StreamDiscoveryStatus.empty:
          yield const StreamDetailState.removed();
        case StreamDiscoveryStatus.loaded:
          final stream = _findById(discoveryState.streams, streamId);
          if (stream == null) {
            yield const StreamDetailState.removed();
            continue;
          }

          yield StreamDetailState.loaded(stream);
      }
    }
  }

  Uri _resolveDiscoveryUri() {
    final normalizedBaseUrl = databaseUrl.endsWith('/')
        ? databaseUrl.substring(0, databaseUrl.length - 1)
        : databaseUrl;
    final uri = Uri.parse('$normalizedBaseUrl/mobile/streams.json');
    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        'ns': namespace,
      },
    );
  }

  StreamDiscoveryState _buildDiscoveryState(Map<String, Object?> snapshot) {
    final streams = <PublishedStream>[];

    for (final entry in snapshot.entries) {
      final value = entry.value;
      if (value is! Map<Object?, Object?>) {
        return const StreamDiscoveryState.error();
      }

      try {
        streams.add(
          PublishedStream.fromJson(
            value.map((key, value) => MapEntry('$key', value)),
          ),
        );
      } on FormatException {
        return const StreamDiscoveryState.error();
      }
    }

    streams.sort((left, right) => left.title.compareTo(right.title));

    if (streams.isEmpty) {
      return const StreamDiscoveryState.empty();
    }

    return StreamDiscoveryState.loaded(streams);
  }

  Map<String, Object?> _applyRealtimeEvent(
    Map<String, Object?> currentSnapshot,
    Object? event,
  ) {
    if (event is! Map<Object?, Object?>) {
      throw const FormatException(
          'Realtime Database event payload must be a map.');
    }

    final normalizedEvent = event.map((key, value) => MapEntry('$key', value));
    final path = normalizedEvent['path'];
    if (path is! String) {
      throw const FormatException('Realtime Database event is missing path.');
    }

    return _applyPathMutation(
      currentSnapshot,
      Uri(path: path).pathSegments,
      normalizedEvent['data'],
    );
  }

  Map<String, Object?> _applyPathMutation(
    Map<String, Object?> currentSnapshot,
    List<String> pathSegments,
    Object? data,
  ) {
    if (pathSegments.isEmpty) {
      if (data == null) {
        return <String, Object?>{};
      }

      if (data is! Map<Object?, Object?>) {
        throw const FormatException(
            'Realtime Database root payload must be a map.');
      }

      return data.map((key, value) => MapEntry('$key', value));
    }

    final nextSnapshot = Map<String, Object?>.from(currentSnapshot);
    final key = pathSegments.first;

    if (pathSegments.length == 1) {
      if (data == null) {
        nextSnapshot.remove(key);
      } else {
        nextSnapshot[key] = data;
      }

      return nextSnapshot;
    }

    final child = nextSnapshot[key];
    final childMap = child is Map<Object?, Object?>
        ? child.map((childKey, childValue) => MapEntry('$childKey', childValue))
        : <String, Object?>{};

    nextSnapshot[key] = _applyPathMutation(
      childMap,
      pathSegments.sublist(1),
      data,
    );
    return nextSnapshot;
  }

  PublishedStream? _findById(List<PublishedStream> streams, String streamId) {
    for (final stream in streams) {
      if (stream.streamId == streamId) {
        return stream;
      }
    }

    return null;
  }
}

enum StreamDiscoveryStatus {
  loading,
  loaded,
  empty,
  error,
}

class StreamDiscoveryState {
  const StreamDiscoveryState._({
    required this.status,
    this.streams = const <PublishedStream>[],
  });

  const StreamDiscoveryState.loading()
      : this._(status: StreamDiscoveryStatus.loading);

  const StreamDiscoveryState.empty()
      : this._(status: StreamDiscoveryStatus.empty);

  const StreamDiscoveryState.error()
      : this._(status: StreamDiscoveryStatus.error);

  const StreamDiscoveryState.loaded(List<PublishedStream> streams)
      : this._(
          status: StreamDiscoveryStatus.loaded,
          streams: streams,
        );

  final StreamDiscoveryStatus status;
  final List<PublishedStream> streams;
}

enum StreamDetailStatus {
  loading,
  loaded,
  removed,
  error,
}

class StreamDetailState {
  const StreamDetailState._({
    required this.status,
    this.stream,
  });

  const StreamDetailState.loading()
      : this._(status: StreamDetailStatus.loading);

  const StreamDetailState.removed()
      : this._(status: StreamDetailStatus.removed);

  const StreamDetailState.error() : this._(status: StreamDetailStatus.error);

  const StreamDetailState.loaded(PublishedStream stream)
      : this._(
          status: StreamDetailStatus.loaded,
          stream: stream,
        );

  final StreamDetailStatus status;
  final PublishedStream? stream;
}
