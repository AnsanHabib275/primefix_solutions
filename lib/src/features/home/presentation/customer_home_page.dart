import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';

class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer'),
        actions: [
          IconButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Welcome ${user?.name ?? ''}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text('Quick actions'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment demo'),
              subtitle: const Text('Stripe / JazzCash / Easypaisa'),
              onTap: () => context.push('/payment'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Live tracking map demo'),
              subtitle: const Text('Track a worker’s live location'),
              onTap: () => context.push('/tracking'),
            ),
          ),
        ],
      ),
    );
  }
}
