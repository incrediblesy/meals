import 'dart:async';

import 'package:flutter/foundation.dart';

class CookingTimerController extends ChangeNotifier {
  CookingTimerController({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  Timer? _ticker;
  DateTime? _deadline;

  Duration _configured = const Duration(minutes: 5);
  Duration _remaining = const Duration(minutes: 5);

  bool _finished = false;

  Duration get remaining => _remaining;

  Duration get configured => _configured;

  bool get isRunning => _deadline != null;

  bool get isFinished => _finished;

  void configure(Duration duration) {
    if (isRunning || duration <= Duration.zero) return;

    _configured = duration;
    _remaining = duration;
    _finished = false;

    notifyListeners();
  }

  void start() {
    if (isRunning) return;

    if (_remaining <= Duration.zero) {
      _remaining = _configured;
    }

    _finished = false;
    _deadline = _now().add(_remaining);

    _ticker = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => refresh(),
    );

    notifyListeners();
  }

  void refresh() {
    final deadline = _deadline;

    if (deadline == null) return;

    final difference = deadline.difference(_now());

    if (difference <= Duration.zero) {
      _remaining = Duration.zero;
      _finished = true;

      _stopTicker();
    } else {
      _remaining = difference;
    }

    notifyListeners();
  }

  void pause() {
    if (!isRunning) return;

    refresh();

    if (!isRunning) return;

    _stopTicker();

    notifyListeners();
  }

  void reset() {
    _stopTicker();

    _remaining = _configured;
    _finished = false;

    notifyListeners();
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _deadline = null;
  }

  @override
  void dispose() {
    _stopTicker();

    super.dispose();
  }
}
