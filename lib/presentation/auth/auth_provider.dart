import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final authRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(const AsyncValue.data(null)) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        final user = await repository.getProfile();
        state = AsyncValue.data(user);
        // Re-send FCM token on every app start to keep server DB updated
        _sendFcmTokenAfterLogin();
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginWithGoogle(String idToken) async {
    state = const AsyncValue.loading();
    try {
      final token = await repository.loginWithGoogle(idToken);
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        final user = await repository.getProfile();
        state = AsyncValue.data(user);
        // Send FCM token immediately after login so server always has it
        _sendFcmTokenAfterLogin();
      } else {
        state = AsyncValue.error('Token not received', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _sendFcmTokenAfterLogin() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      if (authToken == null) return;
      await http.post(
        Uri.parse('http://188.245.212.240/api/users/update-fcm-token/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': fcmToken, 'device_type': 'android/ios'}),
      );
      debugPrint('FCM: Token sent after login successfully');
    } catch (e) {
      debugPrint('FCM: Failed to send token after login: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = const AsyncValue.data(null);
  }
}
