import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/student_api.dart';
import '../config/app_config.dart';
import 'login_page.dart';
import 'student_list_page.dart';
import 'student_profile_page.dart';
import 'student_search_page.dart';
import 'study_info_screen.dart';
import 'study_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = "Người dùng";
  int _studentCount = 0;
  int _subjectCount = 0;
  int _classCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService.getCurrentUser();
    await StudyInfo.loadFromLocal();
    final api = StudentApi(baseUrl: AppConfig.apiBaseUrl, studentsPath: AppConfig.studentsPath);
    final students = await api.fetchStudents();

    if (mounted) {
      setState(() {
        if (user != null) _username = user;
        _studentCount = students.length;
        _subjectCount = StudyInfo.listStudy.length;
        _classCount = StudyInfo.listClass.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FA),
      appBar: AppBar(
        title: const Text('TH5 - G3_C4 - Student Manager', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Khung chào mừng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6750A4), Color(0xFF9581CD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6750A4).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chào mừng,',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          _username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.waving_hand_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Sinh viên', _studentCount.toString()),
                    _buildStatItem('Môn học', _subjectCount.toString()),
                    _buildStatItem('Lớp', _classCount.toString()),
                  ],
                ),
              ],
            ),
          ),
          
          _FeatureCard(
            title: 'Quản lý hồ sơ',
            subtitle: 'Thêm/sửa/xóa hồ sơ sinh viên',
            icon: Icons.person,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudentProfileManagementPage()),
              ).then((_) => _loadData());
            },
          ),
          _FeatureCard(
            title: 'Danh sách sinh viên',
            subtitle: 'Xem danh sách từ API',
            icon: Icons.list_alt,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudentListPage()),
              ).then((_) => _loadData());
            },
          ),
          _FeatureCard(
            title: 'Thông tin học tập',
            subtitle: 'Điểm số, môn học, học kỳ',
            icon: Icons.school,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudyInfoScreen()),
              ).then((_) => _loadData());
            },
          ),
          _FeatureCard(
            title: 'Tìm kiếm / Phân loại',
            subtitle: 'Tìm nhanh và lọc theo tiêu chí',
            icon: Icons.search,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudentSearchPage()),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEADDFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF21005D)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
