import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(DioException error) {
    String message = 'خطایی رخ داد. لطفاً دوباره تلاش کنید.';
    int? statusCode = error.response?.statusCode;
    Map<String, dynamic>? errors;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'زمان ارتباط به پایان رسید. اینترنت خود را بررسی کنید.';
        break;
      case DioExceptionType.connectionError:
        message = 'ارتباط با سرور برقرار نشد. اینترنت را چک کنید.';
        break;
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map) {
          message = data['message']?.toString() ?? message;
          if (data['errors'] is Map) {
            errors = Map<String, dynamic>.from(data['errors']);
            // اولین خطا را به عنوان پیام اصلی نشان بده
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            }
          }
        }
        if (statusCode == 401) message = 'لطفاً دوباره وارد شوید.';
        if (statusCode == 403) message = 'دسترسی غیرمجاز یا حساب مسدود شده.';
        if (statusCode == 422) message = message; // validation
        if (statusCode == 429) message = 'تعداد درخواست‌ها بیش از حد مجاز است. کمی صبر کنید.';
        break;
      default:
        message = 'خطای ناشناخته رخ داد.';
    }

    return ApiException(message: message, statusCode: statusCode, errors: errors);
  }

  @override
  String toString() => message;
}
