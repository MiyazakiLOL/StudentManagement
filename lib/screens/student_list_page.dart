import 'package:flutter/material.dart';

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
    _future = _api.fetchStudents();
  }

  void _retry() {
    setState(() {
      _future = _api.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách sinh viên')),
      body: FutureBuilder<List<Student>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final err = snapshot.error;
            return _ErrorState(errorText: err.toString(), onRetry: _retry);
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
              final title = s.name;
              final subtitleParts = <String>[];
              if (s.code != null && s.code!.trim().isNotEmpty) {
                subtitleParts.add('MSSV: ${s.code}');
              }
              if (s.className != null && s.className!.trim().isNotEmpty) {
                subtitleParts.add('Lớp: ${s.className}');
              }
              if (s.email != null && s.email!.trim().isNotEmpty) {
                subtitleParts.add(s.email!);
              }

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    title.isNotEmpty
                        ? title.characters.first.toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(title),
                subtitle: subtitleParts.isEmpty
                    ? null
                    : Text(subtitleParts.join(' • ')),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Không tải được danh sách sinh viên',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(errorText),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Chưa có sinh viên nào trong danh sách',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Tải lại')),
        ],
      ),
    );
  }
}
