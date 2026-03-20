import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_api.dart';
import '../config/app_config.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  late final StudentApi _api;
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _api = StudentApi(baseUrl: AppConfig.apiBaseUrl, studentsPath: AppConfig.studentsPath);
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _api.fetchStudents();
      setState(() {
        _students = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Lỗi API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Danh sách sinh viên'), centerTitle: true),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _students.length,
                itemBuilder: (context, i) {
                  final s = _students[i];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(s.name[0].toUpperCase())),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${s.gender} • ${s.phone ?? "N/A"}\n${s.email ?? ""}'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
