import 'dart:convert';

import 'package:http/http.dart' as http;

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

  static const Duration _defaultTimeout = Duration(seconds: 8);

  Uri _resolve(String path) {
    final base = Uri.parse(baseUrl);

    // If path is already absolute (e.g. https://host/api/students), use it.
    final maybeAbsolute = Uri.tryParse(path);
    if (maybeAbsolute != null && maybeAbsolute.hasScheme) return maybeAbsolute;

    // Otherwise join with base.
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return base.replace(path: '${base.path}$normalizedPath');
  }

  Future<List<Student>> fetchStudents() async {
    final uri = _resolve(studentsPath);

    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_defaultTimeout);
    } on StudentApiException {
      rethrow;
    } catch (e) {
      throw StudentApiException('Request failed when GET $uri: $e');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StudentApiException(
        'HTTP ${response.statusCode} when GET $uri',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    late final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      throw StudentApiException('Invalid JSON when GET $uri: $e');
    }

    final list = _extractList(decoded);

    return list
        .whereType<Map<String, dynamic>>()
        .map(Student.fromJson)
        .toList(growable: false);
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
    throw const StudentApiException('Unexpected JSON shape for students list');
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
