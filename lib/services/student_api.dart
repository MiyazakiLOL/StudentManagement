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

  static const Duration _timeout = Duration(seconds: 5);

  Uri _resolve(String path) {
    final base = Uri.parse(baseUrl);
    final uri = Uri.parse(path);
    if (uri.hasScheme) return uri;
    return base.resolve(path);
  }

  // Lấy dữ liệu từ SharedPreferences
  Future<List<Student>> getLocalStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString(_storageKey);
    if (cachedData != null) {
      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.map((e) => Student.fromJson(e)).toList();
    }
    return [];
  }

  // Lưu dữ liệu vào SharedPreferences
  Future<void> saveLocalStudents(List<Student> students) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(students.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<List<Student>> fetchStudents() async {
    try {
      final uri = _resolve(studentsPath);
      final res = await _client.get(uri).timeout(_timeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<Student> students = [];
        if (data is List) {
          students = data.map((e) => Student.fromJson(e)).toList();
        } else if (data['data'] != null) {
          students = (data['data'] as List).map((e) => Student.fromJson(e)).toList();
        }
        await saveLocalStudents(students); // Lưu lại bản mới nhất
        return students;
      }
    } catch (e) {
      print("Lỗi kết nối API, sử dụng dữ liệu offline: $e");
    }
    return await getLocalStudents(); // Trả về dữ liệu offline nếu lỗi
  }

  Future<void> createStudent(Student s) async {
    try {
      final uri = _resolve(studentsPath);
      await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(s.toJson()),
      ).timeout(_timeout);
    } catch (e) {
      print("Lỗi thêm API, sẽ chỉ lưu local: $e");
    }
    
    // Cập nhật local ngay lập tức
    final local = await getLocalStudents();
    local.add(s);
    await saveLocalStudents(local);
  }

  Future<void> updateStudent(Student s) async {
    try {
      final uri = _resolve('$studentsPath/${s.id}');
      await _client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(s.toJson()),
      ).timeout(_timeout);
    } catch (e) {
      print("Lỗi cập nhật API: $e");
    }

    final local = await getLocalStudents();
    final index = local.indexWhere((item) => item.id == s.id);
    if (index != -1) {
      local[index] = s;
      await saveLocalStudents(local);
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      final uri = _resolve('$studentsPath/$id');
      await _client.delete(uri).timeout(_timeout);
    } catch (e) {
      print("Lỗi xóa API: $e");
    }

    final local = await getLocalStudents();
    local.removeWhere((s) => s.id == id);
    await saveLocalStudents(local);
  }
}
