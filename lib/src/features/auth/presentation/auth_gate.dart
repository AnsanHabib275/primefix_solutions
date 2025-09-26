import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/presentation/role_select_sheet.dart';
import '../data/auth_repository.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    return auth.when(
      data: (u) => u == null ? const PhoneAuthPage() : const RoleSelectSheet(),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
    );
  }
}

class PhoneAuthPage extends ConsumerStatefulWidget {
  const PhoneAuthPage({super.key});
  @override
  ConsumerState<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends ConsumerState<PhoneAuthPage> {
  String verId = '';
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  bool sending = false;

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(authRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone (+92...)'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: sending
                  ? null
                  : () async {
                      setState(() => sending = true);
                      try {
                        await repo.startPhoneAuth(phoneCtrl.text, onCodeSent: (id) => setState(() => verId = id));
                      } finally {
                        setState(() => sending = false);
                      }
                    },
              child: const Text('Send OTP')),
          if (verId.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextField(controller: otpCtrl, decoration: const InputDecoration(labelText: 'OTP')),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: () async {
                  await repo.confirmOtp(verId, otpCtrl.text);
                },
                child: const Text('Verify'))
          ]
        ]),
      ),
    );
  }
}
