// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async'; // Tambahkan ini untuk TimeoutException
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _sessionCookie;
  
  // Gunakan durasi yang lebih masuk akal (30 - 60 detik)
  final Duration _timeoutDuration = const Duration(seconds: 30);

  // ─── Cookie Management ────────────────────────────────────────────────────
  Future<void> loadCookie() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionCookie = prefs.getString(AppConstants.sessionCookieKey);
  }

  Future<void> saveCookie(String cookie) async {
    _sessionCookie = cookie;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.sessionCookieKey, cookie);
  }

  Future<void> clearCookie() async {
    _sessionCookie = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.sessionCookieKey);
  }

  String? get sessionCookie => _sessionCookie;
  bool get hasSession => _sessionCookie != null && _sessionCookie!.isNotEmpty;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_sessionCookie != null) 'Cookie': _sessionCookie!,
  };

  Map<String, String> get _headersForm => {
    if (_sessionCookie != null) 'Cookie': _sessionCookie!,
  };

  void _extractCookie(http.Response response) {
  final setCookie = response.headers['set-cookie'];
  print("Header Set-Cookie: $setCookie"); // Cek apakah header ini muncul di console

  if (setCookie != null && setCookie.isNotEmpty) {
    final sessionMatch = RegExp(r'connect\.sid=[^;]+').firstMatch(setCookie);
    if (sessionMatch != null) {
      final cookieValue = sessionMatch.group(0)!;
      print("Cookie ditemukan: $cookieValue");
      saveCookie(cookieValue);
    }
  }
}

  // ─── GET ──────────────────────────────────────────────────────────────────
  Future<ApiResponse> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(_timeoutDuration);
      
      _extractCookie(response);
      return ApiResponse(
        statusCode: response.statusCode,
        data: _parseBody(response.body),
        rawBody: response.body,
      );
    } on TimeoutException {
      return ApiResponse.error('Server terlalu lama merespon (Timeout 30s).');
    } on SocketException {
      return ApiResponse.error('Tidak dapat terhubung ke server. Periksa koneksi/IP Anda.');
    } catch (e) {
      return ApiResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // ─── POST JSON ────────────────────────────────────────────────────────────
  Future<ApiResponse> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(_timeoutDuration);
      
      _extractCookie(response);
      return ApiResponse(
        statusCode: response.statusCode,
        data: _parseBody(response.body),
        rawBody: response.body,
      );
    } on TimeoutException {
      return ApiResponse.error('Waktu pengiriman data habis (Timeout).');
    } on SocketException {
      return ApiResponse.error('Koneksi terputus. Pastikan server menyala.');
    } catch (e) {
      return ApiResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // ─── POST MULTIPART (with file) ──────────────────────────────────────────
  Future<ApiResponse> postMultipart(
    String url,
    Map<String, String> fields, {
    File? imageFile,
    String imageField = 'file',
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(_headersForm);
      request.fields.addAll(fields);
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(imageField, imageFile.path));
      }
      
      // Menaikkan timeout khusus upload file karena biasanya lebih berat
      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      
      _extractCookie(response);
      return ApiResponse(
        statusCode: response.statusCode,
        data: _parseBody(response.body),
        rawBody: response.body,
      );
    } catch (e) {
      return ApiResponse.error('Gagal upload: ${e.toString()}');
    }
  }

  // ─── PATCH JSON ───────────────────────────────────────────────────────────
  Future<ApiResponse> patch(String url, [Map<String, dynamic>? body]) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeoutDuration);
      
      _extractCookie(response);
      return ApiResponse(
        statusCode: response.statusCode,
        data: _parseBody(response.body),
        rawBody: response.body,
      );
    } catch (e) {
      return ApiResponse.error('Gagal update data: ${e.toString()}');
    }
  }

  // ─── PATCH MULTIPART ─────────────────────────────────────────────────────
  Future<ApiResponse> patchMultipart(
    String url,
    Map<String, String> fields, {
    File? imageFile,
    String imageField = 'file',
  }) async {
    try {
      final request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(_headersForm);
      request.fields.addAll(fields);
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(imageField, imageFile.path));
      }
      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      _extractCookie(response);
      return ApiResponse(
        statusCode: response.statusCode,
        data: _parseBody(response.body),
        rawBody: response.body,
      );
    } catch (e) {
      return ApiResponse.error('Gagal update (Multipart): ${e.toString()}');
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────
  Future<ApiResponse> delete(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      ).timeout(_timeoutDuration);
      
      _extractCookie(response);
      return ApiResponse(
        statusCode: response.statusCode,
        data: _parseBody(response.body),
        rawBody: response.body,
      );
    } catch (e) {
      return ApiResponse.error('Gagal menghapus: ${e.toString()}');
    }
  }

  dynamic _parseBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}

class ApiResponse {
  final int statusCode;
  final dynamic data;
  final String rawBody;
  final String? errorMessage;

  ApiResponse({
    required this.statusCode,
    required this.data,
    required this.rawBody,
    this.errorMessage,
  });

  factory ApiResponse.error(String message) => ApiResponse(
    statusCode: 0,
    data: null,
    rawBody: '',
    errorMessage: message,
  );

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isError => !isSuccess;
  bool get isConnectionError => statusCode == 0;

  String get message {
    if (errorMessage != null) return errorMessage!;
    if (data is Map) return data['msg'] ?? data['message'] ?? 'Berhasil';
    return rawBody.isNotEmpty ? rawBody : 'Terjadi kesalahan sistem';
  }
}