import 'package:hamyar/shared/models/user_model.dart';

class ListingModel {
  final int id;
  final int userId;
  final int categoryId;
  final String type; // offer | request
  final String title;
  final String? description;
  final String status;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;
  final DateTime? expiresAt;
  final int viewCount;
  final DateTime createdAt;
  final UserModel? user;
  final CategoryModel? category;
  final double? distance;

  ListingModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.type,
    required this.title,
    this.description,
    required this.status,
    this.neighborhood,
    this.latitude,
    this.longitude,
    this.expiresAt,
    this.viewCount = 0,
    required this.createdAt,
    this.user,
    this.category,
    this.distance,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? (json['user']?['id'] as int? ?? 0),
      categoryId: json['category_id'] as int? ?? (json['category']?['id'] as int? ?? 0),
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      neighborhood: json['neighborhood'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at']) : null,
      viewCount: json['view_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  bool get isOffer => type == 'offer';
  bool get isRequest => type == 'request';
  bool get isActive => status == 'active';
}

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
