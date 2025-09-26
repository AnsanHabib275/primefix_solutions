import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/job.dart';

final jobsRepositoryProvider = Provider((ref) => JobsRepository());

class JobsRepository {
  final _db = FirebaseFirestore.instance;

  Future<String> createJob(Job job) async {
    final doc = _db.collection('jobs').doc();
    await doc.set({
      'id': doc.id,
      'customerId': job.customerId,
      'workerId': job.workerId,
      'category': job.category,
      'address': job.address,
      'lat': job.lat,
      'lng': job.lng,
      'amount': job.amount,
      'pricingModel': job.pricingModel,
      'status': job.status.name,
      'scheduledAt': job.scheduledAt,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<List<Job>> watchCustomerJobs(String uid) {
    return _db.collection('jobs')
      .where('customerId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Job.fromJson(d.data())).toList());
  }

  Stream<List<Job>> watchWorkerJobs(String uid) {
    return _db.collection('jobs')
      .where('workerId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Job.fromJson(d.data())).toList());
  }

  Future<void> updateStatus(String jobId, JobStatus status) async {
    await _db.collection('jobs').doc(jobId).update({'status': status.name, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
