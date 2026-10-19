import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamyar/core/constants/api_constants.dart';
import 'package:hamyar/core/network/api_client.dart';
import 'package:hamyar/core/network/api_exception.dart';
import 'package:hamyar/core/security/security_utils.dart';
import 'package:hamyar/shared/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  Future<void> sendOtp(String phone) async {
    final cleaned = SecurityUtils.sanitizePhone(phone);
    if (!SecurityUtils.isValidIranianPhone(cleaned)) {
      throw ApiException(message: 'شماره موبایل معتبر نیست');
    }

    try {
      final response = await _client.post(ApiConstants.sendOtp, data: {
        'phone': cleaned,
      });

      if (response.statusCode != 200) {
        throw ApiException(
          message: response.data['message'] ?? 'خطا در ارسال کد',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> verifyOtp(String phone, String code) async {
    final cleanedPhone = SecurityUtils.sanitizePhone(phone);
    final cleanedCode = code.trim();

    if (cleanedCode.length != 6) {
      throw ApiException(message: 'کد باید ۶ رقم باشد');
    }

    try {
      final response = await _client.post(ApiConstants.verifyOtp, data: {
        'phone': cleanedPhone,
        'code': cleanedCode,
      });

      if (response.statusCode != 200) {
        throw ApiException(
          message: response.data['message'] ?? 'کد نامعتبر است',
          statusCode: response.statusCode,
          errors: response.data['errors'],
        );
      }

      final token = response.data['token'] as String;
      await SecurityUtils.saveToken(token);
      await SecurityUtils.savePhone(cleanedPhone);

      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _client.get(ApiConstants.me);
      if (response.statusCode != 200) {
        throw ApiException(message: 'خطا در دریافت اطلاعات کاربر');
      }
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {
      // حتی اگر سرور خطا داد، توکن محلی پاک شود
    } finally {
      await SecurityUtils.clearAllSecure();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await SecurityUtils.getToken();
    return token != null && token.isNotEmpty;
  }
}
