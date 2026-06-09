import 'dart:convert';
import 'dart:io';

import 'function_request_client_base.dart';

class IoFunctionRequestClient implements FunctionRequestClient {
  @override
  Future<int> postJson(Uri uri, Object payload) async {
    final client = HttpClient();

    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));
      final response = await request.close();
      await response.drain<void>();
      return response.statusCode;
    } finally {
      client.close(force: true);
    }
  }
}

FunctionRequestClient createPlatformFunctionRequestClient() {
  return IoFunctionRequestClient();
}
