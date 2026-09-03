import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/models/models.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._client, this._api);

  final ApiClient _client;
  final ApiService _api;

  UserModel? user;
  bool loading = true;
  bool onboardingDone = false;
  String? error;

  Future<void> bootstrap() async {
    loading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final token = await _client.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        user = await _api.me();
      } catch (_) {
        await _client.clearToken();
        user = null;
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    onboardingDone = true;
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    error = null;
    try {
      final data = await _api.login(phone, password);
      await _client.saveToken(data['token'] as String);
      user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (e) {
      error = _client.extractError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String countryCode,
  }) async {
    error = null;
    try {
      final data = await _api.register({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'password': password,
        'country_code': countryCode,
      });
      await _client.saveToken(data['token'] as String);
      user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (e) {
      error = _client.extractError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      user = await _api.me();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    await _client.clearToken();
    user = null;
    notifyListeners();
  }
}
