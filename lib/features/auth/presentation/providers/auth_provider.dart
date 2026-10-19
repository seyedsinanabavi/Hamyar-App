import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamyar/features/auth/data/auth_repository.dart';
import 'package:hamyar/shared/models/user_model.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AsyncValue.loading()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final loggedIn = await _repo.isLoggedIn();
      if (loggedIn) {
        final user = await _repo.getMe();
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> sendOtp(String phone) async {
    await _repo.sendOtp(phone);
  }

  Future<UserModel> verifyOtp(String phone, String code) async {
    final user = await _repo.verifyOtp(phone, code);
    state = AsyncValue.data(user);
    return user;
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repo.getMe();
      state = AsyncValue.data(user);
    } catch (_) {}
  }
}
