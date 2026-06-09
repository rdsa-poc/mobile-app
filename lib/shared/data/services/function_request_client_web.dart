import 'dart:convert';
import 'dart:html' as html;

import 'function_request_client_base.dart';

class WebFunctionRequestClient implements FunctionRequestClient {
  @override
  Future<int> postJson(Uri uri, Object payload) async {
    final response = await html.HttpRequest.request(
      uri.toString(),
      method: 'POST',
      requestHeaders: const {
        'content-type': 'application/json',
      },
      sendData: jsonEncode(payload),
    );

    return response.status ?? 0;
  }
}

FunctionRequestClient createPlatformFunctionRequestClient() {
  return WebFunctionRequestClient();
}
