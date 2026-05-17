// lib/providers/agenda_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart'; // Pastikan file model ini ada
import '../services/api_service.dart';
import '../utils/constants.dart';

class AgendaProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<AgendaModel> _agendas = [];
  bool _isLoading = false;
  String? _error;

  List<AgendaModel> get agendas => _agendas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getter untuk memfilter status agenda
  List<AgendaModel> get pendingAgendas =>
      _agendas.where((a) => a.status == 'pending').toList();
  List<AgendaModel> get verifiedAgendas =>
      _agendas.where((a) => a.status == 'verified').toList();
  List<AgendaModel> get rejectedAgendas =>
      _agendas.where((a) => a.status == 'rejected').toList();

  // ─── Fetch Agendas ──────────────────────────────────────────────────────────
  Future<void> fetchAgendas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _api.get(AppConstants.agendasUrl);
    
    if (res.isSuccess && res.data != null) {
      try {
        _agendas = (res.data as List).map((j) => AgendaModel.fromJson(j)).toList();
      } catch (e) {
        _error = "Gagal memproses data dari server.";
      }
    } else {
      // Tangkap pesan error dari response (misal: "Token Expired" atau 401 Unauthorized)
      _error = res.message ?? "Terjadi kesalahan saat mengambil data agenda.";
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // ─── Create Agenda ──────────────────────────────────────────────────────────
  Future<ApiResponse> createAgenda({
    required String namaKegiatan,
    required String tuanRumah,
    required String jadwal,
    required File pdfFile,
  }) async {
    final res = await _api.postMultipart(
      AppConstants.agendasUrl,
      {'nama_kegiatan': namaKegiatan, 'tuan_rumah': tuanRumah, 'jadwal': jadwal},
      imageFile: pdfFile,
    );
    
    // Refresh data jika berhasil
    if (res.isSuccess) {
      await fetchAgendas();
    }
    return res;
  }

  // ─── Update Agenda ──────────────────────────────────────────────────────────
  Future<ApiResponse> updateAgenda({
    required String uuid,
    required String namaKegiatan,
    required String tuanRumah,
    required String jadwal,
    File? pdfFile,
  }) async {
    final res = await _api.patchMultipart(
      '${AppConstants.agendasUrl}/$uuid',
      {'nama_kegiatan': namaKegiatan, 'tuan_rumah': tuanRumah, 'jadwal': jadwal},
      imageFile: pdfFile,
    );
    
    if (res.isSuccess) {
      await fetchAgendas();
    }
    return res;
  }

  // ─── Delete Agenda ──────────────────────────────────────────────────────────
  Future<ApiResponse> deleteAgenda(String uuid) async {
    final res = await _api.delete('${AppConstants.agendasUrl}/$uuid');
    
    if (res.isSuccess) {
      await fetchAgendas();
    }
    return res;
  }

  // ─── Verify Agenda ──────────────────────────────────────────────────────────
  Future<ApiResponse> verifyAgenda(String uuid) async {
    final res = await _api.patch('${AppConstants.agendasUrl}/$uuid/verify');
    
    if (res.isSuccess) {
      await fetchAgendas();
    }
    return res;
  }

  // ─── Reject Agenda ──────────────────────────────────────────────────────────
  Future<ApiResponse> rejectAgenda(String uuid) async {
    final res = await _api.patch('${AppConstants.agendasUrl}/$uuid/reject');
    
    if (res.isSuccess) {
      await fetchAgendas();
    }
    return res;
  }

  // ─── Cancel Verify ──────────────────────────────────────────────────────────
  Future<ApiResponse> cancelVerifyAgenda(String uuid) async {
    final res = await _api.patch('${AppConstants.agendasUrl}/$uuid/cancel-verify');
    
    if (res.isSuccess) {
      await fetchAgendas();
    }
    return res;
  }

  // ─── Cancel Reject ──────────────────────────────────────────────────────────
  Future<ApiResponse> cancelRejectAgenda(String uuid) async {
    final res = await _api.patch('${AppConstants.agendasUrl}/$uuid/cancel-reject');
    
    if (res.isSuccess) {
      await fetchAgendas();
    }
    return res;
  }
}