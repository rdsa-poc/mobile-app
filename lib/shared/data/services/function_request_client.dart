import 'function_request_client_base.dart';
import 'function_request_client_stub.dart'
    if (dart.library.html) 'function_request_client_web.dart'
    if (dart.library.io) 'function_request_client_io.dart';

FunctionRequestClient createFunctionRequestClient() {
  return createPlatformFunctionRequestClient();
}
