class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String? profileImage;
  final Address? address;
  final DateTime createdAt;
  final bool isActive;
  final double rating;
  final List<String> bookingHistory;
  final UserSubscription? subscription;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.profileImage,
    this.address,
    required this.createdAt,
    this.isActive = true,
    this.rating = 0.0,
    this.bookingHistory = const [],
    this.subscription,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.user,
      ),
      profileImage: json['profile_image'],
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['is_active'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      bookingHistory: List<String>.from(json['booking_history'] ?? []),
      subscription:
          json['subscription'] != null
              ? UserSubscription.fromJson(json['subscription'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.toString().split('.').last,
      'profile_image': profileImage,
      'address': address?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'rating': rating,
      'booking_history': bookingHistory,
      'subscription': subscription?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? profileImage,
    Address? address,
    DateTime? createdAt,
    bool? isActive,
    double? rating,
    List<String>? bookingHistory,
    UserSubscription? subscription,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      bookingHistory: bookingHistory ?? this.bookingHistory,
      subscription: subscription ?? this.subscription,
    );
  }
}

enum UserRole { user, worker, admin }

class Address {
  final String street;
  final String city;
  final String state;
  final String country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  Address({
    required this.street,
    required this.city,
    required this.state,
    this.country = 'Pakistan',
    this.postalCode,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? 'Pakistan',
      postalCode: json['postal_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullAddress {
    return '$street, $city, $state, $country';
  }
}

class UserSubscription {
  final String id;
  final String planId;
  final String planName;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  UserSubscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.price,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] ?? '',
      planId: json['plan_id'] ?? '',
      planName: json['plan_name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'plan_name': planName,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
}
