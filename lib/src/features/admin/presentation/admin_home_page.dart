import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingStream = FirebaseFirestore.instance.collection('workers').where('approved', isEqualTo: false).snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: pendingStream,
        builder: (c, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = s.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No pending approvals.'));
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final w = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(w['name'] ?? 'Unnamed'),
                subtitle: Text('${w['category'] ?? ''} — ${w['rate'] ?? 0} PKR/hr'),
                trailing: Wrap(spacing: 8, children: [
                  TextButton(
                    onPressed: () => docs[i].reference.update({'approved': true}),
                    child: const Text('Approve'),
                  ),
                  TextButton(
                    onPressed: () => docs[i].reference.delete(),
                    child: const Text('Reject'),
                  ),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
