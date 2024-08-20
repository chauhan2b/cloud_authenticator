import 'dart:async';

import 'package:cloud_authenticator/providers/totp/totp_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_state_provider.g.dart';

@riverpod
class TimerState extends _$TimerState {
  @override
  int build() {
    // calculate the remaining seconds in the current minute
    final now = DateTime.now();
    final remainingSeconds = 30 - (now.second % 30);
    return remainingSeconds > 0 ? remainingSeconds : 30;
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 1) {
        state--;
      } else {
        // refresh totp provider and reset the timer
        ref.invalidate(totpProvider);
        state = 30;
      }
    });
  }
}
