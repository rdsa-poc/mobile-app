import '../../config/runtime_contract.dart';

abstract class MotdRepository {
  Stream<String?> subscribeToMessage({
    required String path,
  });
}

class LocalBaselineMotdRepository implements MotdRepository {
  const LocalBaselineMotdRepository({
    required this.baselineMessage,
  });

  final String baselineMessage;

  @override
  Stream<String?> subscribeToMessage({
    required String path,
  }) {
    assert(path == kMotdMessagePath);
    final normalizedMessage = baselineMessage.trim();
    return Stream<String?>.value(
      normalizedMessage.isEmpty ? null : normalizedMessage,
    );
  }
}
