import 'dart:async';

import 'package:cloud_authenticator/providers/totp/totp_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_state_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerState extends _$TimerState {
  Timer? _timer;

  @override
  int build() {
    // dispose the timer when the provider is disposed
    ref.onDispose(() {
      _timer?.cancel();
    });

    // calculate the remaining seconds in the current minute
    final now = DateTime.now();
    final remainingSeconds = 30 - (now.second % 30);

    // start the timer
    startTimer();

    return remainingSeconds > 0 ? remainingSeconds : 30;
  }

  void startTimer() {
    // cancel existing timers
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 1) {
        state--;
      } else {
        state = 30;
        ref.invalidate(totpProvider);
      }
    });
  }
}
