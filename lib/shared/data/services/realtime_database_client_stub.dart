import 'realtime_database_client_base.dart';

class UnsupportedRealtimeDatabaseClient implements RealtimeDatabaseClient {
  @override
  Stream<Object?> watchJson(Uri uri) {
    return Stream<Object?>.error(
      UnsupportedError(
        'No platform realtime database client is available for $uri.',
      ),
    );
  }
}

RealtimeDatabaseClient createPlatformRealtimeDatabaseClient() {
  return UnsupportedRealtimeDatabaseClient();
}
