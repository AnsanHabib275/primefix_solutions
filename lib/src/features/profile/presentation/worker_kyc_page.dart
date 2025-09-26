import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/data/auth_repository.dart';
import 'package:go_router/go_router.dart';

class WorkerKycPage extends ConsumerStatefulWidget {
  const WorkerKycPage({super.key});
  @override
  ConsumerState<WorkerKycPage> createState() => _WorkerKycPageState();
}

class _WorkerKycPageState extends ConsumerState<WorkerKycPage> {
  final name = TextEditingController();
  final cnic = TextEditingController();
  final rate = TextEditingController();
  String category = 'electrician';
  File? cnicFront, cnicBack, selfie;
  bool loading = false;

  Future<String> _upload(File f, String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putFile(f);
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Worker KYC')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
          DropdownButton<String>(
            value: category,
            items: const [
              DropdownMenuItem(value: 'electrician', child: Text('Electrician')),
              DropdownMenuItem(value: 'plumber', child: Text('Plumber')),
              DropdownMenuItem(value: 'painter', child: Text('Painter')),
              DropdownMenuItem(value: 'carpenter', child: Text('Carpenter')),
            ],
            onChanged: (v) => setState(() => category = v!),
          ),
          TextField(controller: cnic, decoration: const InputDecoration(labelText: 'CNIC')),
          TextField(controller: rate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hourly rate (PKR)')),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            _pickBtn('CNIC Front', (f)=> setState(()=> cnicFront=f)),
            _pickBtn('CNIC Back', (f)=> setState(()=> cnicBack=f)),
            _pickBtn('Selfie', (f)=> setState(()=> selfie=f)),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loading ? null : () async {
              if (user == null || cnicFront == null || cnicBack == null || selfie == null) return;
              setState(() => loading = true);
              try {
                final uid = user.uid;
                final frontUrl = await _upload(cnicFront!, 'kyc/$uid/front.jpg');
                final backUrl = await _upload(cnicBack!, 'kyc/$uid/back.jpg');
                final selfieUrl = await _upload(selfie!, 'kyc/$uid/selfie.jpg');
                await FirebaseFirestore.instance.collection('workers').doc(uid).set({
                  'uid': uid,
                  'name': name.text,
                  'category': category,
                  'cnic': cnic.text,
                  'rate': int.tryParse(rate.text) ?? 0,
                  'pricingModel': 'hourly',
                  'kyc': {'front': frontUrl, 'back': backUrl, 'selfie': selfieUrl},
                  'approved': false,
                  'online': false,
                  'rating': 0.0,
                  'jobsCompleted': 0,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (context.mounted) context.go('/worker');
              } finally {
                setState(() => loading = false);
              }
            },
            child: loading ? const CircularProgressIndicator() : const Text('Submit for approval'),
          )
        ]),
      ),
    );
  }

  Widget _pickBtn(String label, void Function(File f) onPicked) {
    return ElevatedButton(
      onPressed: () async {
        final x = await ImagePicker().pickImage(source: ImageSource.camera);
        if (x != null) onPicked(File(x.path));
      },
      child: Text(label),
    );
  }
}
