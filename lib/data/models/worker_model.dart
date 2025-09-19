import 'user_model.dart';

class Worker {
  final String id;
  final String userId;
  final String category;
  final List<String> skills;
  final double hourlyRate;
  final double dailyRate;
  final String experience;
  final List<String> certifications;
  final String? cnic;
  final WorkerStatus status;
  final Location currentLocation;
  final bool isOnline;
  final WorkingHours workingHours;
  final BankDetails? bankDetails;
  final double totalEarnings;
  final int completedJobs;
  final int cancelledJobs;
  final double rating;
  final int reviewCount;
  final DateTime lastSeen;
  final User? userDetails;

  Worker({
    required this.id,
    required this.userId,
    required this.category,
    this.skills = const [],
    required this.hourlyRate,
    required this.dailyRate,
    this.experience = '',
    this.certifications = const [],
    this.cnic,
    this.status = WorkerStatus.pending,
    required this.currentLocation,
    this.isOnline = false,
    required this.workingHours,
    this.bankDetails,
    this.totalEarnings = 0.0,
    this.completedJobs = 0,
    this.cancelledJobs = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.lastSeen,
    this.userDetails,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      category: json['category'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      hourlyRate: (json['hourly_rate'] ?? 0.0).toDouble(),
      dailyRate: (json['daily_rate'] ?? 0.0).toDouble(),
      experience: json['experience'] ?? '',
      certifications: List<String>.from(json['certifications'] ?? []),
      cnic: json['cnic'],
      status: WorkerStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => WorkerStatus.pending,
      ),
      currentLocation: Location.fromJson(json['current_location'] ?? {}),
      isOnline: json['is_online'] ?? false,
      workingHours: WorkingHours.fromJson(json['working_hours'] ?? {}),
      bankDetails:
          json['bank_details'] != null
              ? BankDetails.fromJson(json['bank_details'])
              : null,
      totalEarnings: (json['total_earnings'] ?? 0.0).toDouble(),
      completedJobs: json['completed_jobs'] ?? 0,
      cancelledJobs: json['cancelled_jobs'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      lastSeen: DateTime.parse(
        json['last_seen'] ?? DateTime.now().toIso8601String(),
      ),
      userDetails:
          json['user_details'] != null
              ? User.fromJson(json['user_details'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'skills': skills,
      'hourly_rate': hourlyRate,
      'daily_rate': dailyRate,
      'experience': experience,
      'certifications': certifications,
      'cnic': cnic,
      'status': status.toString().split('.').last,
      'current_location': currentLocation.toJson(),
      'is_online': isOnline,
      'working_hours': workingHours.toJson(),
      'bank_details': bankDetails?.toJson(),
      'total_earnings': totalEarnings,
      'completed_jobs': completedJobs,
      'cancelled_jobs': cancelledJobs,
      'rating': rating,
      'review_count': reviewCount,
      'last_seen': lastSeen.toIso8601String(),
      'user_details': userDetails?.toJson(),
    };
  }

  // Computed properties
  String get name => userDetails?.name ?? 'Unknown Worker';
  String get profileImage => userDetails?.profileImage ?? '';
  double get completionRate {
    final total = completedJobs + cancelledJobs;
    return total > 0 ? completedJobs / total : 0.0;
  }

  bool get isVerified => status == WorkerStatus.approved;
  bool get isAvailable => isOnline && status == WorkerStatus.approved;

  String get experienceLevel {
    if (experience.isEmpty) return 'Beginner';
    final years = int.tryParse(experience.split(' ').first) ?? 0;
    if (years < 2) return 'Beginner';
    if (years < 5) return 'Intermediate';
    return 'Expert';
  }
}

enum WorkerStatus { pending, approved, rejected, suspended }

class Location {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime? timestamp;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.timestamp,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'],
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

class DaySchedule {
  final String day;
  final String openTime; // Example: "09:00"
  final String closeTime; // Example: "18:00"
  final bool isClosed;

  DaySchedule({
    required this.day,
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      day: json['day'] ?? '',
      openTime: json['openTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      isClosed: json['isClosed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }
}

class WorkingHours {
  final Map<String, DaySchedule> schedule;
  final bool isFlexible;
  final String? notes;

  WorkingHours({this.schedule = const {}, this.isFlexible = true, this.notes});

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    final scheduleJson = json['schedule'] as Map<String, dynamic>? ?? {};
    final schedule = scheduleJson.map((key, value) {
      return MapEntry(key, DaySchedule.fromJson(value));
    });

    return WorkingHours(
      schedule: schedule,
      isFlexible: json['isFlexible'] ?? true,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule': schedule.map((key, value) => MapEntry(key, value.toJson())),
      'isFlexible': isFlexible,
      'notes': notes,
    };
  }
}

class BankDetails {
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String iban;
  final String? branchCode;
  final String? swiftCode;
  final String? notes;

  BankDetails({
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.iban,
    this.branchCode,
    this.swiftCode,
    this.notes,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      accountHolderName: json['accountHolderName'] ?? '',
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      iban: json['iban'] ?? '',
      branchCode: json['branchCode'],
      swiftCode: json['swiftCode'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'iban': iban,
      'branchCode': branchCode,
      'swiftCode': swiftCode,
      'notes': notes,
    };
  }
}
