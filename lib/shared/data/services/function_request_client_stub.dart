import 'function_request_client_base.dart';

class UnsupportedFunctionRequestClient implements FunctionRequestClient {
  @override
  Future<int> postJson(Uri uri, Object payload) {
    throw UnsupportedError(
      'No platform request client is available for $uri.',
    );
  }
}

FunctionRequestClient createPlatformFunctionRequestClient() {
  return UnsupportedFunctionRequestClient();
}
