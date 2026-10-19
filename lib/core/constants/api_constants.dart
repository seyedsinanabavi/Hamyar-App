class ApiConstants {
  // تغییر بده به آدرس سرور واقعی
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // برای امولاتور اندروید
  // static const String baseUrl = 'http://localhost:8000/api'; // برای iOS سیمولاتور
  // static const String baseUrl = 'https://api.hamyar.app/api'; // پروداکشن

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Profile
  static const String profile = '/profile';
  static const String avatar = '/profile/avatar';
  static const String requestVerification = '/profile/request-verification';

  // Categories & Listings
  static const String categories = '/categories';
  static const String listings = '/listings';

  // Conversations
  static const String conversations = '/conversations';

  // Reviews & Reports
  static const String reviews = '/reviews';
  static const String reports = '/reports';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
