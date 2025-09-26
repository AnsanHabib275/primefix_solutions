import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../location/worker_location_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerHomePage extends ConsumerStatefulWidget {
  const WorkerHomePage({super.key});
  @override
  ConsumerState<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends ConsumerState<WorkerHomePage> {
  final _loc = WorkerLocationService();
  bool online = false;
  bool approved = false;

  @override
  void initState() {
    super.initState();
    _loadApproval();
  }

  Future<void> _loadApproval() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance.collection('workers').doc(uid).get();
    setState(() => approved = snap.data()?['approved'] == true);
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker'),
        actions: [
          IconButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(
            children: [
              const Text('Status:'),
              const SizedBox(width: 8),
              Chip(
                label: Text(approved ? 'Approved' : 'Pending'),
                backgroundColor: approved ? Colors.green.shade100 : Colors.orange.shade100,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Online (share live location)'),
            value: online,
            onChanged: (v) async {
              setState(() => online = v);
              final uid = firebaseUser?.uid;
              if (uid == null) return;
              if (v) {
                await _loc.start(uid);
                await FirebaseFirestore.instance.collection('workers').doc(uid).set({'online': true}, SetOptions(merge: true));
              } else {
                _loc.stop();
                await FirebaseFirestore.instance.collection('workers').doc(uid).set({'online': false}, SetOptions(merge: true));
              }
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Edit/Complete KYC'),
              onTap: () => Navigator.of(context).pushNamed('/auth'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Text(
                'Job list & chat UI placeholder.\nConnect watchWorkerJobs() here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        ]),
      ),
    );
  }
}
