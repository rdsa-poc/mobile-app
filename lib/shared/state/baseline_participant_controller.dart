import 'package:flutter/foundation.dart';

import '../config/runtime_contract.dart';
import '../data/repositories/application_event_repository.dart';
import '../data/repositories/motd_repository.dart';

class BaselineParticipantController extends ChangeNotifier {
  BaselineParticipantController({
    required MotdRepository motdRepository,
    required ApplicationEventPublisher startupEventPublisher,
  })  : _motdRepository = motdRepository,
        _startupEventPublisher = startupEventPublisher;

  final MotdRepository _motdRepository;
  final ApplicationEventPublisher _startupEventPublisher;

  bool _startupAttempted = false;
  StartupEventDispatchStatus _startupStatus = StartupEventDispatchStatus.idle;

  StartupEventDispatchStatus get startupStatus => _startupStatus;

  Future<void> beginStartup() async {
    if (_startupAttempted) {
      return;
    }

    _startupAttempted = true;
    _startupStatus = StartupEventDispatchStatus.pending;
    notifyListeners();

    try {
      _startupStatus = await _startupEventPublisher.dispatchStartupEvent();
    } catch (_) {
      _startupStatus = StartupEventDispatchStatus.failed;
    }

    notifyListeners();
  }

  Stream<String?> subscribeToMotd() {
    return _motdRepository.subscribeToMessage(path: kMotdMessagePath);
  }
}
