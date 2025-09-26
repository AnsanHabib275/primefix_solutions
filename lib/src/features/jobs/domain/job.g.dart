// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobImpl _$$JobImplFromJson(Map<String, dynamic> json) => _$JobImpl(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      workerId: json['workerId'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      amount: (json['amount'] as num).toInt(),
      pricingModel: json['pricingModel'] as String,
      status: $enumDecodeNullable(_$JobStatusEnumMap, json['status']) ??
          JobStatus.requested,
      scheduledAt: const TimestampConverter().fromJson(json['scheduledAt']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$JobImplToJson(_$JobImpl instance) => <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'workerId': instance.workerId,
      'category': instance.category,
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
      'amount': instance.amount,
      'pricingModel': instance.pricingModel,
      'status': _$JobStatusEnumMap[instance.status]!,
      'scheduledAt': const TimestampConverter().toJson(instance.scheduledAt),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$JobStatusEnumMap = {
  JobStatus.requested: 'requested',
  JobStatus.accepted: 'accepted',
  JobStatus.in_progress: 'in_progress',
  JobStatus.completed: 'completed',
  JobStatus.cancelled: 'cancelled',
};
