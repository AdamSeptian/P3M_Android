// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isHumas => _currentUser?.role == 'humas';
  bool get isAdminOrHumas => isAdmin || isHumas;

  // ─── Initialize ────────────────────────────────────────────────────────────
  Future<void> init() async {
    await _api.loadToken();
    if (_api.hasToken) {
      await fetchCurrentUser();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // ─── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _api.post(AppConstants.loginUrl, {
      'email': email,
      'password': password,
    });

    _isLoading = false;

    if (response.isSuccess) {
      // Ambil accessToken dari body respons dan simpan
      final token = response.data['accessToken'];
      if (token != null) {
        await _api.saveToken(token);
      }
      
      await fetchCurrentUser();
      return true;
    } else {
      _errorMessage = response.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ─── Fetch Current User ────────────────────────────────────────────────────
  Future<void> fetchCurrentUser() async {
    final response = await _api.get(AppConstants.meUrl);
    if (response.isSuccess && response.data is Map) {
      _currentUser = UserModel.fromJson(response.data);
      // Only allow admin or humas
      if (_currentUser!.role != 'admin' && _currentUser!.role != 'humas') {
        _errorMessage = 'Akses ditolak. Hanya admin dan humas yang dapat menggunakan aplikasi ini.';
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        await _api.clearToken();
      } else {
        _status = AuthStatus.authenticated;
        _errorMessage = null;
      }
    } else {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      await _api.clearToken();
    }
    notifyListeners();
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final response = await _api.delete(AppConstants.logoutUrl);
  
    if (response.isSuccess) {
      await _api.clearToken();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } else {
      print("Logout gagal di server: ${response.message}");
      await _api.clearToken();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
}