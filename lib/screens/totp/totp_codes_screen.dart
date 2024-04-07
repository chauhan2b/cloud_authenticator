import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/providers/totp/timer_state_provider.dart';
import 'package:cloud_authenticator/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final secret = secrets[index];
                  final totp = ref.read(totpProvider(secret.key));

                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete secret'),
                            content: Text(
                                'Are you sure you want to delete ${totp.issuer}?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(secretProvider.notifier)
                                      .removeSecret(secret.key);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  child: Icon(Icons.security),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      totp.issuer,
                                      style: const TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      totp.email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  remainingTime,
                                  style: const TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  totp.code,
                                  style: TextStyle(
                                    fontSize: 28,
                                    letterSpacing: 28,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  onPressed: () {
                                    // copy the code to the clipboard
                                    Clipboard.setData(
                                        ClipboardData(text: totp.code));
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content: Text('Copied to clipboard'),
                                    //   ),
                                    // );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
        spaceBetweenChildren: 16,
        childPadding: const EdgeInsets.all(0),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera_alt),
            label: 'Scan QR Code',
            onTap: () {
              context.router.push(const QRViewRoute());
            },
          ),
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
        ],
      ),
    );
  }
}
