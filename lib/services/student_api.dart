import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';

class StudentApi {
  StudentApi({
    required this.baseUrl,
    required this.studentsPath,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String studentsPath;
  final http.Client _client;

  static const String _storageKey = 'cached_students';
  static const Duration _defaultTimeout = Duration(seconds: 8);

  // In-memory cache
  static final List<Student> _localStudents = [];
  static bool _isInitialized = false;

  Uri _resolve(String path) {
    final base = Uri.parse(baseUrl);
    final maybeAbsolute = Uri.tryParse(path);
    if (maybeAbsolute != null && maybeAbsolute.hasScheme) return maybeAbsolute;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return base.replace(path: '${base.path}$normalizedPath');
  }

  /// Ensures that data is loaded from local storage or API
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_storageKey);

    if (cachedData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedData);
        _localStudents.clear();
        _localStudents.addAll(decoded.map((item) => Student.fromJson(item)));
        _isInitialized = true;
        return;
      } catch (e) {
        print('Error decoding cached data: $e');
      }
    }

    // If no cache or error, fetch from API
    try {
      final remoteStudents = await _fetchFromApi();
      _localStudents.clear();
      _localStudents.addAll(remoteStudents);
      await _saveToDisk();
      _isInitialized = true;
    } catch (e) {
      // If API fails and no cache, we might still be uninitialized or have empty list
      print('Initial fetch failed: $e');
      _isInitialized = true; // Mark as initialized even if empty to prevent infinite retries
    }
  }

  Future<List<Student>> _fetchFromApi() async {
    final uri = _resolve(studentsPath);
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_defaultTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final list = _extractList(decoded);
        return list
            .whereType<Map<String, dynamic>>()
            .map(Student.fromJson)
            .toList();
      }
      throw StudentApiException('HTTP ${response.statusCode}');
    } catch (e) {
      throw StudentApiException('Request failed: $e');
    }
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_localStudents.map((s) => s.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      print('Failed to save to disk: $e');
    }
  }

  Future<List<Student>> fetchStudents() async {
    await _ensureInitialized();
    return List.unmodifiable(_localStudents);
  }

  Future<void> addStudent(Student student) async {
    await _ensureInitialized();
    _localStudents.insert(0, student);
    await _saveToDisk();
  }

  Future<void> updateStudent(Student student) async {
    await _ensureInitialized();
    final index = _localStudents.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _localStudents[index] = student;
      await _saveToDisk();
    }
  }

  Future<void> deleteStudent(String id) async {
    await _ensureInitialized();
    _localStudents.removeWhere((s) => s.id == id);
    await _saveToDisk();
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['data'],
        decoded['students'],
        decoded['items'],
        decoded['result'],
      ];
      for (final c in candidates) {
        if (c is List) return c;
      }
    }
    throw const StudentApiException('Unexpected JSON shape');
  }
}

class StudentApiException implements Exception {
  const StudentApiException(this.message, {this.statusCode, this.body});
  final String message;
  final int? statusCode;
  final String? body;
  @override
  String toString() => 'StudentApiException($message)';
}
