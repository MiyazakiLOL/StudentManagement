import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/student.dart';
import '../services/student_api.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  late final StudentApi _api;
  late Future<List<Student>> _future;

  @override
  void initState() {
    super.initState();
    _api = StudentApi(
      baseUrl: AppConfig.apiBaseUrl,
      studentsPath: AppConfig.studentsPath,
    );
    _future = _fetchCombinedStudents();
  }

  Future<List<Student>> _fetchCombinedStudents() async {
    try {
      // 1. Lấy sinh viên từ API
      final apiStudents = await _api.fetchStudents();

      // 2. Lấy sinh viên lưu local từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? localJson = prefs.getString('local_students');
      
      List<Student> localStudents = [];
      if (localJson != null) {
        final List<dynamic> decoded = jsonDecode(localJson);
        localStudents = decoded.map((item) {
          return Student(
            id: item['id'] ?? '',
            name: item['fullName'] ?? 'Không tên',
            email: item['email'],
            className: "Local - ${item['gender'] ?? 'Chưa rõ'}",
            code: item['phone'], // Tạm dùng phone làm code để hiển thị
          );
        }).toList();
      }

      // Gộp 2 danh sách (Ưu tiên local lên đầu)
      return [...localStudents, ...apiStudents];
    } catch (e) {
      debugPrint("Lỗi khi lấy danh sách: $e");
      // Nếu API lỗi, vẫn cố gắng trả về local students nếu có
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? localJson = prefs.getString('local_students');
        if (localJson != null) {
           final List<dynamic> decoded = jsonDecode(localJson);
           return decoded.map((item) => Student(
             id: item['id'] ?? '',
             name: item['fullName'] ?? 'Không tên',
             email: item['email'],
             className: "Offline Mode",
           )).toList();
        }
      } catch (_) {}
      rethrow;
    }
  }

  void _retry() {
    setState(() {
      _future = _fetchCombinedStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sinh viên'),
        actions: [
          IconButton(onPressed: _retry, icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(errorText: snapshot.error.toString(), onRetry: _retry);
          }

          final students = snapshot.data ?? const <Student>[];
          if (students.isEmpty) {
            return _EmptyState(onRetry: _retry);
          }

          return ListView.separated(
            itemCount: students.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final s = students[index];
              final isLocal = s.className?.contains("Local") ?? false;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isLocal ? Colors.orange.shade100 : null,
                  child: Text(
                    s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                    style: TextStyle(color: isLocal ? Colors.orange.shade900 : null),
                  ),
                ),
                title: Text(s.name),
                subtitle: Text(
                  "${s.className ?? ''} ${s.email != null ? '• ${s.email}' : ''}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: isLocal 
                  ? const Icon(Icons.cloud_off, size: 16, color: Colors.grey)
                  : const Icon(Icons.cloud_done, size: 16, color: Colors.blue),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.errorText, required this.onRetry});
  final String errorText;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorText, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text("Thử lại")),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Danh sách trống"),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text("Tải lại")),
        ],
      ),
    );
  }
}
