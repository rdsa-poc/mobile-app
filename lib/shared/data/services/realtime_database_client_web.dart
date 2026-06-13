import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'realtime_database_client_base.dart';

class WebRealtimeDatabaseClient implements RealtimeDatabaseClient {
  @override
  Stream<Object?> watchJson(Uri uri) {
    late final StreamController<Object?> controller;
    html.EventSource? eventSource;

    void addJsonEvent(html.Event event) {
      if (event is! html.MessageEvent) {
        return;
      }

      final data = event.data;
      if (data is! String || data.isEmpty || controller.isClosed) {
        return;
      }

      controller.add(jsonDecode(data));
    }

    controller = StreamController<Object?>(
      onCancel: () async {
        eventSource?.close();
      },
      onListen: () {
        eventSource = html.EventSource(uri.toString());
        eventSource!.addEventListener('put', addJsonEvent);
        eventSource!.addEventListener('patch', addJsonEvent);
        eventSource!.addEventListener('keep-alive', (_) {});
        eventSource!.addEventListener('cancel', (_) {
          controller.addError(
            StateError(
                'Realtime Database stream terminated with event cancel.'),
          );
        });
        eventSource!.addEventListener('auth_revoked', (_) {
          controller.addError(
            StateError(
              'Realtime Database stream terminated with event auth_revoked.',
            ),
          );
        });
        eventSource!.onError.listen((_) {
          if (!controller.isClosed) {
            controller.addError(
              StateError('Realtime Database web stream connection failed.'),
            );
          }
        });
      },
    );

    return controller.stream;
  }
}

RealtimeDatabaseClient createPlatformRealtimeDatabaseClient() {
  return WebRealtimeDatabaseClient();
}
