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

  static const Duration _timeout = Duration(seconds: 8);

  Uri _resolve(String path) {
    final base = Uri.parse(baseUrl);
    final uri = Uri.parse(path);

    if (uri.hasScheme) return uri;
    return base.resolve(path);
  }

  Future<List<Student>> fetchStudents() async {
    final uri = _resolve(studentsPath);

    final res = await _client.get(uri).timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('Lỗi load dữ liệu');
    }

    final data = jsonDecode(res.body);

    if (data is List) {
      return data.map((e) => Student.fromJson(e)).toList();
    }

    if (data['data'] != null) {
      return (data['data'] as List)
          .map((e) => Student.fromJson(e))
          .toList();
    }

    throw Exception('Sai format JSON');
  }

  Future<void> createStudent(Student s) async {
    final uri = _resolve(studentsPath);

    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(s.toJson()),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Thêm thất bại');
    }
  }

  Future<void> updateStudent(Student s) async {
    final uri = _resolve('$studentsPath/${s.id}');

    final res = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(s.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('Cập nhật thất bại');
    }
  }

  Future<void> deleteStudent(int id) async {
    final uri = _resolve('$studentsPath/$id');

    final res = await _client.delete(uri);

    if (res.statusCode != 200) {
      throw Exception('Xóa thất bại');
    }
  }
}