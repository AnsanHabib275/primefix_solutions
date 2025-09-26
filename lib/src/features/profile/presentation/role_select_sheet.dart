import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import 'worker_kyc_page.dart';
import 'package:go_router/go_router.dart';

class RoleSelectSheet extends ConsumerWidget {
  const RoleSelectSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your role')),
      body: Center(
        child: Wrap(spacing: 16, children: [
          ElevatedButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).updateRole('customer');
              if (context.mounted) context.go('/customer');
            },
            child: const Text('I am a Customer'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).updateRole('worker');
              if (context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkerKycPage()));
              }
            },
            child: const Text('I am a Worker'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).updateRole('admin');
              if (context.mounted) context.go('/admin');
            },
            child: const Text('I am Admin'),
          ),
        ]),
      ),
    );
  }
}
