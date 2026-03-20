import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_api.dart';
import '../config/app_config.dart';
import 'student_detail_page.dart';

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
    int maleCount = _students.where((s) => s.gender == 'Nam').length;
    int femaleCount = _students.where((s) => s.gender == 'Nữ').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FA),
      appBar: AppBar(
        title: const Text('Danh sách sinh viên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFEADDFF),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6750A4)))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF3EDF7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                    border: Border.all(color: const Color(0xFFEADDFF), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text('TỔNG SỐ SINH VIÊN', style: TextStyle(fontSize: 11, color: Color(0xFF6750A4), fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Text('${_students.length}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF21005D), height: 1)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _buildGenderStat('Nam', maleCount, Icons.male_rounded, const Color(0xFF2196F3))),
                          Container(width: 1, height: 40, color: const Color(0xFFEADDFF)),
                          Expanded(child: _buildGenderStat('Nữ', femaleCount, Icons.female_rounded, const Color(0xFFE91E63))),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.sort_by_alpha, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('DANH SÁCH CHI TIẾT (${_students.length})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchData,
                    color: const Color(0xFF6750A4),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _students.length,
                      itemBuilder: (context, i) {
                        final s = _students[i];
                        final isMale = s.gender == 'Nam';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Chuyển đến trang chi tiết khi nhấn vào
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentDetailPage(student: s),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: isMale ? const Color(0xFFE3F2FD) : const Color(0xFFFCE4EC),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Text(
                                            s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: isMale ? const Color(0xFF1976D2) : const Color(0xFFC2185B),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1C1B1F))),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF3EDF7),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(s.code ?? 'N/A', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6750A4))),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(s.gender ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(s.email ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGenderStat(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1C1B1F))),
          ],
        ),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1)),
      ],
    );
  }
}
