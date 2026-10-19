import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamyar/core/constants/api_constants.dart';
import 'package:hamyar/core/network/api_client.dart';
import 'package:hamyar/core/network/api_exception.dart';
import 'package:hamyar/core/security/security_utils.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.read(apiClientProvider));
});

class ReportRepository {
  final ApiClient _client;

  ReportRepository(this._client);

  /// reportableType: 'listing' یا 'user'
  Future<void> submitReport({
    required String reportableType,
    required int reportableId,
    required String reason,
    String? description,
  }) async {
    if (reportableType != 'listing' && reportableType != 'user') {
      throw ApiException(message: 'نوع گزارش نامعتبر است');
    }

    final cleanReason = SecurityUtils.sanitizeText(reason, maxLength: 100);
    if (cleanReason.isEmpty) {
      throw ApiException(message: 'دلیل گزارش الزامی است');
    }

    try {
      final response = await _client.post(ApiConstants.reports, data: {
        'reportable_type': reportableType,
        'reportable_id': reportableId,
        'reason': cleanReason,
        if (description != null && description.trim().isNotEmpty)
          'description': SecurityUtils.sanitizeText(description, maxLength: 1000),
      });

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ApiException(
          message: response.data['message']?.toString() ?? 'خطا در ثبت گزارش',
          statusCode: response.statusCode,
          errors: response.data is Map ? response.data['errors'] : null,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
