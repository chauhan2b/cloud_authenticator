import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/providers/totp/timer_state_provider.dart';
import 'package:cloud_authenticator/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../providers/totp/secret_provider.dart';
import '../../providers/totp/totp_provider.dart';

@RoutePage()
class TOTPCodesScreen extends ConsumerStatefulWidget {
  const TOTPCodesScreen({super.key});

  @override
  ConsumerState<TOTPCodesScreen> createState() => _TOTPCodesState();
}

class _TOTPCodesState extends ConsumerState<TOTPCodesScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(timerStateProvider.notifier).startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final secretsFuture = ref.watch(secretProvider);
    final remainingTime = ref.watch(timerStateProvider).toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Authenticator'),
      ),
      body: secretsFuture.when(
        data: (secrets) => secrets.isEmpty
            ? const Center(
                child: Text('Your authentication codes will appear here'),
              )
            : ListView.builder(
                itemCount: secrets.length,
                itemBuilder: (context, index) {
                  final secret = secrets[index];
                  final totp = ref.read(totpProvider(secret.key));

                  return ListTile(
                    title: Text(totp.code),
                    subtitle: Text(totp.issuer),
                    leading: Text(remainingTime),
                    trailing: IconButton(
                      onPressed: () {
                        ref
                            .read(secretProvider.notifier)
                            .removeSecret(secret.id);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  );
                },
              ),
        error: (error, stackTrace) => Center(
          child: Text(error.toString()),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Manually Add',
            onTap: () {
              // open a dialog box with a text field
              showDialog(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();
                  return AlertDialog(
                    title: const Text('Add a new secret'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter the secret',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          ref
                              .read(secretProvider.notifier)
                              .addSecret(controller.text);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.camera_alt),
            label: 'Scan QR Code',
            onTap: () {
              context.router.push(const QRViewRoute());
            },
          ),
        ],
      ),
    );
  }
}
