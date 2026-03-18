import 'package:flutter/material.dart';

import 'student_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang phát triển'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TH5 - Nhóm 3 - Student Manager'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FeatureCard(
            title: 'Quản lý hồ sơ',
            subtitle: 'Thêm/sửa thông tin sinh viên',
            icon: Icons.person,
            onTap: () => _showComingSoon(context),
          ),
          _FeatureCard(
            title: 'Danh sách sinh viên',
            subtitle: 'Xem và quản lý danh sách',
            icon: Icons.list_alt,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudentListPage()),
              );
            },
          ),
          _FeatureCard(
            title: 'Thông tin học tập',
            subtitle: 'Điểm số, môn học, học kỳ',
            icon: Icons.school,
            onTap: () => _showComingSoon(context),
          ),
          _FeatureCard(
            title: 'Tìm kiếm / Phân loại',
            subtitle: 'Tìm nhanh và lọc theo tiêu chí',
            icon: Icons.search,
            onTap: () => _showComingSoon(context),
          ),
        ],
      ),
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
