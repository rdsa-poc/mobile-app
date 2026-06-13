import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'realtime_database_client_base.dart';

class IoRealtimeDatabaseClient implements RealtimeDatabaseClient {
  @override
  Stream<Object?> watchJson(Uri uri) {
    late final StreamController<Object?> controller;
    HttpClient? client;

    Future<void> listen() async {
      client = HttpClient();

      try {
        final request = await client!.getUrl(uri);
        request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
        final response = await request.close();

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException(
            'Realtime Database watch failed with status ${response.statusCode}.',
            uri: uri,
          );
        }

        final dataBuffer = StringBuffer();
        String? eventType;

        await for (final line in response
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
          if (line.isEmpty) {
            _dispatchEvent(
              controller: controller,
              data: dataBuffer.toString(),
              eventType: eventType,
            );
            dataBuffer.clear();
            eventType = null;
            continue;
          }

          if (line.startsWith('event:')) {
            eventType = line.substring('event:'.length).trim();
            continue;
          }

          if (line.startsWith('data:')) {
            if (dataBuffer.isNotEmpty) {
              dataBuffer.writeln();
            }
            dataBuffer.write(line.substring('data:'.length).trim());
          }
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      } finally {
        await controller.close();
        client?.close(force: true);
      }
    }

    controller = StreamController<Object?>(
      onCancel: () async {
        client?.close(force: true);
      },
      onListen: () {
        unawaited(listen());
      },
    );

    return controller.stream;
  }

  void _dispatchEvent({
    required StreamController<Object?> controller,
    required String data,
    required String? eventType,
  }) {
    if (data.isEmpty || controller.isClosed) {
      return;
    }

    if (eventType == 'keep-alive') {
      return;
    }

    if (eventType == 'cancel' || eventType == 'auth_revoked') {
      controller.addError(
        StateError(
            'Realtime Database stream terminated with event $eventType.'),
      );
      return;
    }

    controller.add(jsonDecode(data));
  }
}

RealtimeDatabaseClient createPlatformRealtimeDatabaseClient() {
  return IoRealtimeDatabaseClient();
}
