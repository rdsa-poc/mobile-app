import '../../config/runtime_contract.dart';
import '../services/function_request_client_base.dart';
import '../services/function_request_client.dart';

abstract class ApplicationEventPublisher {
  Future<StartupEventDispatchStatus> dispatchStartupEvent();
}

class HttpApplicationEventPublisher implements ApplicationEventPublisher {
  HttpApplicationEventPublisher({
    required this.baseUrl,
    FunctionRequestClient? requestClient,
  }) : _requestClient = requestClient ?? createFunctionRequestClient();

  final String baseUrl;
  final FunctionRequestClient _requestClient;

  @override
  Future<StartupEventDispatchStatus> dispatchStartupEvent() async {
    final statusCode = await _requestClient.postJson(
      _resolveStartupUri(),
      const {
        'Event': {
          'eventName': kStartupEventName,
          'source': 'app',
        },
      },
    );

    if (statusCode >= 200 && statusCode < 300) {
      return StartupEventDispatchStatus.sent;
    }

    return StartupEventDispatchStatus.failed;
  }

  Uri _resolveStartupUri() {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalizedBaseUrl$kStartupEventFunctionPath');
  }
}

enum StartupEventDispatchStatus {
  idle('idle'),
  pending('pending'),
  sent('sent'),
  failed('failed');

  const StartupEventDispatchStatus(this.label);

  final String label;
}
