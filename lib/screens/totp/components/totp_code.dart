import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/totp/totp_provider.dart';

class TotpCode extends ConsumerStatefulWidget {
  const TotpCode({
    super.key,
    required this.secret,
  });

  final String secret;

  @override
  ConsumerState<TotpCode> createState() => _TotpCodeState();
}

class _TotpCodeState extends ConsumerState<TotpCode> {
  @override
  Widget build(BuildContext context) {
    final code = ref.watch(totpProvider(widget.secret));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      child: _buildCodeRow(code),
    );
  }

  Widget _buildCodeRow(String code) {
    return Row(
      key: ValueKey<String>(code),
      mainAxisSize: MainAxisSize.min,
      children: code.split('').map((digit) => _buildDigit(digit)).toList(),
    );
  }

  Widget _buildDigit(String digit) {
    return SizedBox(
      width: 45,
      child: Center(
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 28,
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
