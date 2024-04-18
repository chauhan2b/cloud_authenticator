import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/providers/totp/secret_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

                      // check if the barcode is a URL
                      if (!barcode.rawValue!.startsWith('otpauth://')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid QR code'),
                          ),
                        );
                        return;
                      }

                      // add the barcode value to firebase
                      ref
                          .read(secretProvider.notifier)
                          .addSecret(barcode.rawValue!);

                      // go back to the home screen
                      context.router.back();

                      // show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Barcode added'),
                        ),
                      );

                      break;
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
