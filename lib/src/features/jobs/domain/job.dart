import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'job.freezed.dart';
part 'job.g.dart';

enum JobStatus { requested, accepted, in_progress, completed, cancelled }

class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();
  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    return null;
  }
  @override
  Object? toJson(DateTime? object) => object?.toIso8601String();
}

@freezed
class Job with _$Job {
  const factory Job({
    required String id,
    required String customerId,
    required String workerId,
    required String category,
    required String address,
    required double lat,
    required double lng,
    required int amount,
    required String pricingModel,
    @Default(JobStatus.requested) JobStatus status,
    @TimestampConverter() DateTime? scheduledAt,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}
