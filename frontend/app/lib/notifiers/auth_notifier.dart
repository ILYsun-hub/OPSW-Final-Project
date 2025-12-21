import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthNotifier extends ChangeNotifier {
  final ApiService _apiService;

  AuthNotifier(this._apiService);

  String? _token;
  String? get token => _token;

  bool get isLoggedIn => _token != null;

  Future<void> login(String email, String password) async {
    try {
      _token = await _apiService.login(email, password);
      notifyListeners(); // 상태 변경을 알림
    } catch (e) {
      _token = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    notifyListeners(); // 상태 변경을 알림
  }
}
