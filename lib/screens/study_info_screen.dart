import 'package:flutter/material.dart';
import 'study_info.dart';

class StudyInfoScreen extends StatefulWidget {
  const StudyInfoScreen({super.key});

  @override
  State<StudyInfoScreen> createState() => _StudyInfoScreenState();
}

class _StudyInfoScreenState extends State<StudyInfoScreen> {
  // Danh sách ban đầu (có thể thay đổi được)
  final List<StudyInfo> listStudy = [
    StudyInfo(subjectName: "Lập trình Flutter", semester: "Học kỳ 1 - 2026", score: "8.5"),
  ];

  // Các Controller để lấy dữ liệu từ ô nhập
  final TextEditingController nameController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();

  // Hàm hiển thị hộp thoại để thêm môn học
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm/Sửa môn học"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên môn học")),
            TextField(controller: semesterController, decoration: const InputDecoration(labelText: "Học kỳ")),
            TextField(controller: scoreController, decoration: const InputDecoration(labelText: "Điểm số"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                listStudy.add(StudyInfo(
                  subjectName: nameController.text,
                  semester: semesterController.text,
                  score: scoreController.text,
                ));
              });
              nameController.clear();
              semesterController.clear();
              scoreController.clear();
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin học tập"),
        backgroundColor: const Color(0xFFEADDFF),
        centerTitle: true,
      ),
      body: listStudy.isEmpty 
        ? const Center(child: Text("Chưa có môn học nào. Nhấn + để thêm."))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listStudy.length,
            itemBuilder: (context, index) {
              final item = listStudy[index];
              return Card(
                child: ListTile(
                  title: Text(item.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.semester),
                  trailing: Text(item.score, style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
                  onLongPress: () {
                    // Nhấn giữ lâu để xóa
                    setState(() { listStudy.removeAt(index); });
                  },
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}