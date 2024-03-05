import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/providers/totp/totp_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:otp/otp.dart';

@RoutePage()
class QRViewScreen extends ConsumerStatefulWidget {
  const QRViewScreen({super.key});

  @override
  ConsumerState<QRViewScreen> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends ConsumerState<QRViewScreen> {
  String? lastBarcode;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final qrBoxSize = size.width * 0.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: qrBoxSize,
              width: qrBoxSize,
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null &&
                        barcode.rawValue != lastBarcode) {
                      lastBarcode = barcode.rawValue;
                      // add the barcode value to firebase
                      ref
                          .read(totpProvider.notifier)
                          .addTOTP(barcode.rawValue!);

                      // go back to the home screen
                      context.router.back();

                      // show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Barcode added'),
                        ),
                      );

                      break;

                      // final totp = OTP.generateTOTPCodeString(
                      //   barcode.rawValue!,
                      //   DateTime.now().millisecondsSinceEpoch,
                      //   algorithm: Algorithm.SHA1,
                      //   length: 6,
                      //   interval: 30,
                      //   isGoogle: false,
                      // );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Scan the QR code to add a new account.'),
          ],
        ),
      ),
    );
  }
}
