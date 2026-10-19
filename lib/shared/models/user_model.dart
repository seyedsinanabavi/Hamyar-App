class UserModel {
  final int id;
  final String phone;
  final String? name;
  final String? avatar;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;
  final int radius;
  final double rating;
  final int ratingCount;
  final bool isBanned;
  final int helpsGiven;
  final int helpsReceived;
  final bool isIdentityVerified;
  final bool isTrusted;
  final String trustBadge; // verified | trusted | none
  final String verificationStatus; // none | pending | approved | rejected

  UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.avatar,
    this.neighborhood,
    this.latitude,
    this.longitude,
    this.radius = 1000,
    this.rating = 0,
    this.ratingCount = 0,
    this.isBanned = false,
    this.helpsGiven = 0,
    this.helpsReceived = 0,
    this.isIdentityVerified = false,
    this.isTrusted = false,
    this.trustBadge = 'none',
    this.verificationStatus = 'none',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      neighborhood: json['neighborhood'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radius: json['radius'] as int? ?? 1000,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      isBanned: json['is_banned'] as bool? ?? false,
      helpsGiven: json['helps_given'] as int? ?? 0,
      helpsReceived: json['helps_received'] as int? ?? 0,
      isIdentityVerified: json['is_identity_verified'] as bool? ?? false,
      isTrusted: json['is_trusted'] as bool? ?? false,
      trustBadge: json['trust_badge'] as String? ?? 'none',
      verificationStatus: json['verification_status'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'avatar': avatar,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'rating': rating,
      'rating_count': ratingCount,
      'helps_given': helpsGiven,
      'helps_received': helpsReceived,
      'is_identity_verified': isIdentityVerified,
      'is_trusted': isTrusted,
      'trust_badge': trustBadge,
      'verification_status': verificationStatus,
    };
  }

  String get displayName =>
      name?.isNotEmpty == true ? name! : 'کاربر ${phone.length >= 4 ? phone.substring(phone.length - 4) : phone}';

  bool get hasVerifiedBadge => trustBadge == 'verified' || isIdentityVerified;
  bool get hasTrustedBadge => trustBadge == 'trusted' || isTrusted;
}
