import 'realtime_database_client_base.dart';
import 'realtime_database_client_stub.dart'
    if (dart.library.html) 'realtime_database_client_web.dart'
    if (dart.library.io) 'realtime_database_client_io.dart';

RealtimeDatabaseClient createRealtimeDatabaseClient() {
  return createPlatformRealtimeDatabaseClient();
}
