import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ابزارهای امنیتی سمت کلاینت
class SecurityUtils {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ---------- Secure Storage ----------
  static Future<void> saveSecure(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> readSecure(String key) async {
    return _storage.read(key: key);
  }

  static Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAllSecure() async {
    await _storage.deleteAll();
  }

  // ---------- Token ----------
  static const _tokenKey = 'auth_token';
  static const _phoneKey = 'user_phone';

  static Future<void> saveToken(String token) => saveSecure(_tokenKey, token);
  static Future<String?> getToken() => readSecure(_tokenKey);
  static Future<void> clearToken() => deleteSecure(_tokenKey);

  static Future<void> savePhone(String phone) => saveSecure(_phoneKey, phone);
  static Future<String?> getPhone() => readSecure(_phoneKey);

  // ---------- Input Sanitization ----------
  static String sanitizeText(String input, {int maxLength = 2000}) {
    var cleaned = input.trim();
    // حذف کاراکترهای کنترلی خطرناک
    cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
    if (cleaned.length > maxLength) {
      cleaned = cleaned.substring(0, maxLength);
    }
    return cleaned;
  }

  static String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool isValidIranianPhone(String phone) {
    final cleaned = sanitizePhone(phone);
    return RegExp(r'^09[0-9]{9}$').hasMatch(cleaned);
  }

  // ---------- Screenshot Protection (Android) ----------
  static Future<void> enableScreenshotProtection() async {
    if (Platform.isAndroid) {
      try {
        // FLAG_SECURE
        const channel = MethodChannel('hamyar/security');
        await channel.invokeMethod('setSecureFlag', true);
      } catch (_) {
        // در صورت عدم وجود native channel نادیده گرفته می‌شود
      }
    }
  }

  static Future<void> disableScreenshotProtection() async {
    if (Platform.isAndroid) {
      try {
        const channel = MethodChannel('hamyar/security');
        await channel.invokeMethod('setSecureFlag', false);
      } catch (_) {}
    }
  }

  // ---------- Debug / Logging Safety ----------
  static void safeLog(String message) {
    if (kDebugMode) {
      // هرگز توکن یا کد OTP را لاگ نکن
      final safe = message
          .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false), 'Bearer ***')
          .replaceAll(RegExp(r'"code"\s*:\s*"[0-9]{4,8}"'), '"code":"***"')
          .replaceAll(RegExp(r'"token"\s*:\s*"[^"]+"'), '"token":"***"');
      debugPrint('[Hamyar] $safe');
    }
  }

  // ---------- Root / Jailbreak Detection (basic) ----------
  static Future<bool> isDeviceCompromised() async {
    if (kDebugMode) return false; // در حالت دیباگ نادیده بگیر

    try {
      if (Platform.isAndroid) {
        // چک ساده وجود فایل‌های رایج root
        final suspiciousPaths = [
          '/system/app/Superuser.apk',
          '/sbin/su',
          '/system/bin/su',
          '/system/xbin/su',
          '/data/local/xbin/su',
          '/data/local/bin/su',
        ];
        for (final path in suspiciousPaths) {
          if (await File(path).exists()) return true;
        }
      }
      // iOS jailbreak detection نیاز به پکیج تخصصی دارد
    } catch (_) {}
    return false;
  }
}
