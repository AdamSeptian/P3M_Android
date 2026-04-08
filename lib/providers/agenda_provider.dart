// lib/providers/agenda_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
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

  List<AgendaModel> get pendingAgendas =>
      _agendas.where((a) => a.status == 'pending').toList();
  List<AgendaModel> get verifiedAgendas =>
      _agendas.where((a) => a.status == 'verified').toList();
  List<AgendaModel> get rejectedAgendas =>
      _agendas.where((a) => a.status == 'rejected').toList();

  Future<void> fetchAgendas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _api.get(AppConstants.agendasUrl);
    if (res.isSuccess && res.data is List) {
      _agendas = (res.data as List).map((j) => AgendaModel.fromJson(j)).toList();
    } else {
      _error = res.message;
    }
    _isLoading = false;
    notifyListeners();
  }

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
    if (res.isSuccess) await fetchAgendas();
    return res;
  }

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
    if (res.isSuccess) await fetchAgendas();
    return res;
  }

  Future<ApiResponse> deleteAgenda(String uuid) async {
    final res = await _api.delete('${AppConstants.agendasUrl}/$uuid');
    if (res.isSuccess) await fetchAgendas();
    return res;
  }

  Future<ApiResponse> verifyAgenda(String uuid) async {
    final res = await _api.patch('${AppConstants.agendasUrl}/$uuid/verify');
    if (res.isSuccess) await fetchAgendas();
    return res;
  }

  Future<ApiResponse> rejectAgenda(String uuid) async {
    final res = await _api.patch('${AppConstants.agendasUrl}/$uuid/reject');
    if (res.isSuccess) await fetchAgendas();
    return res;
  }

  Future<ApiResponse> cancelVerifyAgenda(String uuid) async {
    final res = await _api.patch('${AppConstants.agendasUrl}/$uuid/cancel-verify');
    if (res.isSuccess) await fetchAgendas();
    return res;
  }

  Future<ApiResponse> cancelRejectAgenda(String uuid) async {
    final res = await _api.patch('${AppConstants.agendasUrl}/$uuid/cancel-reject');
    if (res.isSuccess) await fetchAgendas();
    return res;
  }
}