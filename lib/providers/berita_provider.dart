// lib/providers/berita_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class BeritaProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<BeritaModel> _beritas = [];
  bool _isLoading = false;
  String? _error;

  List<BeritaModel> get beritas => _beritas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BeritaModel> get pendingBeritas =>
      _beritas.where((b) => b.status == 'pending').toList();
  List<BeritaModel> get verifiedBeritas =>
      _beritas.where((b) => b.status == 'verified').toList();
  List<BeritaModel> get rejectedBeritas =>
      _beritas.where((b) => b.status == 'rejected').toList();

  Future<void> fetchBeritas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _api.get(AppConstants.beritasUrl);
    if (res.isSuccess && res.data is List) {
      _beritas = (res.data as List).map((j) => BeritaModel.fromJson(j)).toList();
    } else {
      _error = res.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResponse> createBerita({
    required String judul,
    required String isi,
    required File imageFile,
    required List<String> kategoriUuids,
    required List<String> tagUuids,
  }) async {
    final fields = <String, String>{
      'judul_berita': judul,
      'isi_berita': isi,
    };
    for (int i = 0; i < kategoriUuids.length; i++) {
      fields['kategori_uuid[$i]'] = kategoriUuids[i];
    }
    for (int i = 0; i < tagUuids.length; i++) {
      fields['tag_uuid[$i]'] = tagUuids[i];
    }

    final res = await _api.postMultipart(
      AppConstants.beritasUrl,
      fields,
      imageFile: imageFile,
    );
    if (res.isSuccess) await fetchBeritas();
    return res;
  }

  Future<ApiResponse> updateBerita({
    required String uuid,
    required String judul,
    required String isi,
    File? imageFile,
    required List<String> kategoriUuids,
    required List<String> tagUuids,
  }) async {
    final fields = <String, String>{
      'judul_berita': judul,
      'isi_berita': isi,
    };
    for (int i = 0; i < kategoriUuids.length; i++) {
      fields['kategori_uuid[$i]'] = kategoriUuids[i];
    }
    for (int i = 0; i < tagUuids.length; i++) {
      fields['tag_uuid[$i]'] = tagUuids[i];
    }

    final res = await _api.patchMultipart(
      '${AppConstants.beritasUrl}/$uuid',
      fields,
      imageFile: imageFile,
    );
    if (res.isSuccess) await fetchBeritas();
    return res;
  }

  Future<ApiResponse> deleteBerita(String uuid) async {
    final res = await _api.delete('${AppConstants.beritasUrl}/$uuid');
    if (res.isSuccess) await fetchBeritas();
    return res;
  }

  Future<ApiResponse> verifyBerita(String uuid) async {
    final res = await _api.patch('${AppConstants.beritasUrl}/$uuid/verify');
    if (res.isSuccess) await fetchBeritas();
    return res;
  }

  Future<ApiResponse> rejectBerita(String uuid) async {
    final res = await _api.patch('${AppConstants.beritasUrl}/$uuid/reject');
    if (res.isSuccess) await fetchBeritas();
    return res;
  }

  Future<ApiResponse> cancelVerifyBerita(String uuid) async {
    final res = await _api.patch('${AppConstants.beritasUrl}/$uuid/cancel-verify');
    if (res.isSuccess) await fetchBeritas();
    return res;
  }

  Future<ApiResponse> cancelRejectBerita(String uuid) async {
    final res = await _api.patch('${AppConstants.beritasUrl}/$uuid/cancel-reject');
    if (res.isSuccess) await fetchBeritas();
    return res;
  }
}