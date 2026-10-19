import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamyar/core/constants/api_constants.dart';
import 'package:hamyar/core/network/api_client.dart';
import 'package:hamyar/core/network/api_exception.dart';
import 'package:hamyar/core/security/security_utils.dart';
import 'package:hamyar/shared/models/listing_model.dart';

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository(ref.read(apiClientProvider));
});

class ListingRepository {
  final ApiClient _client;

  ListingRepository(this._client);

  Future<List<ListingModel>> getListings({
    String? type,
    int? categoryId,
    double? lat,
    double? lng,
    int? radius,
    String? search,
    int page = 1,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        if (type != null) 'type': type,
        if (categoryId != null) 'category_id': categoryId,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (radius != null) 'radius': radius,
        if (search != null && search.isNotEmpty) 'search': SecurityUtils.sanitizeText(search, maxLength: 100),
      };

      final response = await _client.get(ApiConstants.listings, queryParameters: query);

      if (response.statusCode != 200) {
        throw ApiException(message: 'خطا در دریافت آگهی‌ها');
      }

      final data = response.data['data'] as List? ?? response.data as List? ?? [];
      return data.map((e) => ListingModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ListingModel> getListing(int id) async {
    try {
      final response = await _client.get('${ApiConstants.listings}/$id');
      if (response.statusCode != 200) {
        throw ApiException(message: 'آگهی یافت نشد', statusCode: response.statusCode);
      }
      return ListingModel.fromJson(response.data['listing'] ?? response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ListingModel> createListing({
    required int categoryId,
    required String type,
    required String title,
    String? description,
    String? neighborhood,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _client.post(ApiConstants.listings, data: {
        'category_id': categoryId,
        'type': type,
        'title': SecurityUtils.sanitizeText(title, maxLength: 120),
        if (description != null) 'description': SecurityUtils.sanitizeText(description),
        if (neighborhood != null) 'neighborhood': SecurityUtils.sanitizeText(neighborhood, maxLength: 100),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      });

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ApiException(
          message: response.data['message'] ?? 'خطا در ثبت آگهی',
          statusCode: response.statusCode,
          errors: response.data['errors'],
        );
      }

      return ListingModel.fromJson(response.data['listing'] ?? response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteListing(int id) async {
    try {
      final response = await _client.delete('${ApiConstants.listings}/$id');
      if (response.statusCode != 200) {
        throw ApiException(message: response.data['message'] ?? 'خطا در حذف');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> completeListing(int id) async {
    try {
      final response = await _client.post('${ApiConstants.listings}/$id/complete');
      if (response.statusCode != 200) {
        throw ApiException(message: response.data['message'] ?? 'خطا');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.get(ApiConstants.categories);
      if (response.statusCode != 200) {
        throw ApiException(message: 'خطا در دریافت دسته‌بندی‌ها');
      }
      final list = response.data['categories'] as List? ?? [];
      return list.map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
