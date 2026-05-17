// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart'; // File model gabungan
import '../services/api_service.dart';
import '../utils/constants.dart';

// ─── USER PROVIDER ────────────────────────────────────────────────────────────
class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<UserModel> get pendingUsers =>
      _users.where((u) => u.status == 'pending').toList();
  List<UserModel> get verifiedUsers =>
      _users.where((u) => u.status == 'verified').toList();
  List<UserModel> get rejectedUsers =>
      _users.where((u) => u.status == 'rejected').toList();

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _api.get(AppConstants.usersUrl);
    
    if (res.isSuccess && res.data != null) {
      try {
        _users = (res.data as List).map((j) => UserModel.fromJson(j)).toList();
      } catch (e) {
        _error = "Gagal memproses data user dari server.";
      }
    } else {
      _error = res.message ?? "Terjadi kesalahan saat mengambil data user.";
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResponse> verifyUser(String uuid) async {
    final res = await _api.patch('${AppConstants.usersUrl}/$uuid/verify');
    if (res.isSuccess) {
      await fetchUsers();
    }
    return res;
  }

  Future<ApiResponse> rejectUser(String uuid) async {
    final res = await _api.patch('${AppConstants.usersUrl}/$uuid/reject');
    if (res.isSuccess) {
      await fetchUsers();
    }
    return res;
  }

  Future<ApiResponse> deleteUser(String uuid) async {
    final res = await _api.delete('${AppConstants.usersUrl}/$uuid');
    if (res.isSuccess) {
      await fetchUsers();
    }
    return res;
  }
}

// ─── KATEGORI PROVIDER ────────────────────────────────────────────────────────
class KategoriProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<KategoriModel> _kategoris = [];
  bool _isLoading = false;
  String? _error;

  List<KategoriModel> get kategoris => _kategoris;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchKategoris() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _api.get(AppConstants.kategoriUrl);
    
    if (res.isSuccess && res.data != null) {
      try {
        _kategoris = (res.data as List).map((j) => KategoriModel.fromJson(j)).toList();
      } catch (e) {
        _error = "Gagal memproses data kategori dari server.";
      }
    } else {
      _error = res.message ?? "Terjadi kesalahan saat mengambil data kategori.";
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResponse> createKategori(String nama) async {
    final res = await _api.post(AppConstants.kategoriUrl, {'nama_kategori': nama});
    if (res.isSuccess) {
      await fetchKategoris();
    }
    return res;
  }

  Future<ApiResponse> updateKategori(String uuid, String nama) async {
    final res = await _api.patch('${AppConstants.kategoriUrl}/$uuid', {'nama_kategori': nama});
    if (res.isSuccess) {
      await fetchKategoris();
    }
    return res;
  }

  Future<ApiResponse> deleteKategori(String uuid) async {
    final res = await _api.delete('${AppConstants.kategoriUrl}/$uuid');
    if (res.isSuccess) {
      await fetchKategoris();
    }
    return res;
  }
}

// ─── TAG PROVIDER ─────────────────────────────────────────────────────────────
class TagProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<TagModel> _tags = [];
  bool _isLoading = false;
  String? _error;

  List<TagModel> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTags() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _api.get(AppConstants.tagUrl);
    
    if (res.isSuccess && res.data != null) {
      try {
        _tags = (res.data as List).map((j) => TagModel.fromJson(j)).toList();
      } catch (e) {
        _error = "Gagal memproses data tag dari server.";
      }
    } else {
      _error = res.message ?? "Terjadi kesalahan saat mengambil data tag.";
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResponse> createTag(String nama) async {
    final res = await _api.post(AppConstants.tagUrl, {'nama_tag': nama});
    if (res.isSuccess) {
      await fetchTags();
    }
    return res;
  }

  Future<ApiResponse> updateTag(String uuid, String nama) async {
    final res = await _api.patch('${AppConstants.tagUrl}/$uuid', {'nama_tag': nama});
    if (res.isSuccess) {
      await fetchTags();
    }
    return res;
  }

  Future<ApiResponse> deleteTag(String uuid) async {
    final res = await _api.delete('${AppConstants.tagUrl}/$uuid');
    if (res.isSuccess) {
      await fetchTags();
    }
    return res;
  }
}