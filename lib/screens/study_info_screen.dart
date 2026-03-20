import 'package:flutter/material.dart';
import 'study_info.dart';

class StudyInfoScreen extends StatefulWidget {
  const StudyInfoScreen({super.key});

  @override
  State<StudyInfoScreen> createState() => _StudyInfoScreenState();
}

class _StudyInfoScreenState extends State<StudyInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu từ local khi vào màn hình
    _initData();
  }

  Future<void> _initData() async {
    await StudyInfo.loadFromLocal();
    setState(() {});
  }

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
            onPressed: () async {
              setState(() {
                StudyInfo.listStudy.add(StudyInfo(
                  subjectName: nameController.text,
                  semester: semesterController.text,
                  score: scoreController.text,
                ));
              });
              await StudyInfo.saveToLocal(); // Lưu offline
              nameController.clear();
              semesterController.clear();
              scoreController.clear();
              if (mounted) Navigator.pop(context);
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
        title: const Text("Thông tin học tập", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFFEADDFF),
        centerTitle: true,
        elevation: 0,
      ),
      body: StudyInfo.listStudy.isEmpty 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: StudyInfo.listStudy.length,
            itemBuilder: (context, index) {
              final item = StudyInfo.listStudy[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black12, width: 0.5)
                ),
                child: ListTile(
                  title: Text(item.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.semester),
                  trailing: Text(item.score, style: const TextStyle(fontSize: 18, color: Color(0xFF6750A4), fontWeight: FontWeight.bold)),
                  onLongPress: () async {
                    setState(() { StudyInfo.listStudy.removeAt(index); });
                    await StudyInfo.saveToLocal(); // Lưu offline sau khi xóa
                  },
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFEADDFF),
        child: const Icon(Icons.add, color: Color(0xFF21005D)),
      ),
    );
  }
}
