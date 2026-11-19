import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/account_action_controller.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});
  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends ConsumerState<ChangePasswordDialog> {
  final current = TextEditingController();
  final replacement = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    current.dispose();
    replacement.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy) return;
    if (current.text.isEmpty ||
        replacement.text.length < 12 ||
        replacement.text == current.text) {
      setState(
        () => error =
            'Enter your current password and a different password of at least 12 characters.',
      );
      return;
    }
    setState(() => busy = true);
    final result = await ref.read(staffCredentialsProvider).submit(
      '/v1/auth/change-password',
      {'currentPassword': current.text, 'password': replacement.text},
    );
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        busy = false;
        error = result.failureOrNull?.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: const Text('Change password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              enabled: !busy,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: replacement,
              obscureText: true,
              enabled: !busy,
              maxLength: 128,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const Text('Other sessions will be signed out.'),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: const Text('Change password'),
        ),
      ],
    ),
  );
}
