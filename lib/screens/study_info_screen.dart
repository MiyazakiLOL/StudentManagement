import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_info.dart';
import '../models/student.dart';
import '../services/student_api.dart';
import '../config/app_config.dart';

class StudentScore {
  final String studentId;
  final String studentName;
  final String studentCode;
  final String subjectName;
  final String score;

  StudentScore({
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.subjectName,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'studentName': studentName,
    'studentCode': studentCode,
    'subjectName': subjectName,
    'score': score,
  };

  factory StudentScore.fromJson(Map<String, dynamic> json) => StudentScore(
    studentId: json['studentId'],
    studentName: json['studentName'],
    studentCode: json['studentCode'],
    subjectName: json['subjectName'],
    score: json['score'],
  );
}

class StudyInfoScreen extends StatefulWidget {
  const StudyInfoScreen({super.key});

  @override
  State<StudyInfoScreen> createState() => _StudyInfoScreenState();
}

class _StudyInfoScreenState extends State<StudyInfoScreen> {
  int _selectedTab = 0; // 0 for Student, 1 for Subject, 2 for Class
  
  // Subject Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();
  
  // Class Controllers
  final TextEditingController classCodeController = TextEditingController();
  final TextEditingController classNameController = TextEditingController();
  
  List<Student> _students = [];
  List<StudentScore> _studentScores = [];
  Student? _selectedStudent;
  String? _selectedSubject;
  final TextEditingController _studentScoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await StudyInfo.loadFromLocal();
    final api = StudentApi(baseUrl: AppConfig.apiBaseUrl, studentsPath: AppConfig.studentsPath);
    _students = await api.fetchStudents();
    await _loadStudentScores();
    setState(() {});
  }

  Future<void> _loadStudentScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('cached_student_scores');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _studentScores = decoded.map((e) => StudentScore.fromJson(e)).toList();
    }
  }

  Future<void> _saveStudentScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_studentScores.map((e) => e.toJson()).toList());
    await prefs.setString('cached_student_scores', encoded);
  }

  void _showAddSubjectDialog() {
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
              await StudyInfo.saveToLocal();
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

  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm lớp mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: classCodeController, decoration: const InputDecoration(labelText: "Mã lớp")),
            TextField(controller: classNameController, decoration: const InputDecoration(labelText: "Tên lớp")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (classCodeController.text.isNotEmpty && classNameController.text.isNotEmpty) {
                setState(() {
                  StudyInfo.listClass.add(ClassInfo(
                    classCode: classCodeController.text,
                    className: classNameController.text,
                  ));
                });
                await StudyInfo.saveToLocal();
                classCodeController.clear();
                classNameController.clear();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  void _showAddStudentScoreDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Thêm điểm sinh viên"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Student>(
                value: _selectedStudent,
                decoration: const InputDecoration(labelText: "Sinh viên"),
                items: _students.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (v) => setDialogState(() => _selectedStudent = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(labelText: "Môn học"),
                items: StudyInfo.listStudy.map((s) => DropdownMenuItem(value: s.subjectName, child: Text(s.subjectName))).toList(),
                onChanged: (v) => setDialogState(() => _selectedSubject = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _studentScoreController,
                decoration: const InputDecoration(labelText: "Điểm số"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () async {
                if (_selectedStudent != null && _selectedSubject != null && _studentScoreController.text.isNotEmpty) {
                  setState(() {
                    _studentScores.add(StudentScore(
                      studentId: _selectedStudent!.id,
                      studentName: _selectedStudent!.name,
                      studentCode: _selectedStudent!.code ?? 'N/A',
                      subjectName: _selectedSubject!,
                      score: _studentScoreController.text,
                    ));
                  });
                  await _saveStudentScores();
                  _studentScoreController.clear();
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text("Thêm"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FA),
      appBar: AppBar(
        title: const Text("Thông tin học tập", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFEADDFF),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 16),
                  _tabButton("Sinh viên", 0),
                  const SizedBox(width: 12),
                  _tabButton("Môn", 1),
                  const SizedBox(width: 12),
                  _tabButton("Lớp", 2),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedTab == 0) _showAddStudentScoreDialog();
          else if (_selectedTab == 1) _showAddSubjectDialog();
          else _showAddClassDialog();
        },
        backgroundColor: const Color(0xFFEADDFF),
        child: const Icon(Icons.add, color: Color(0xFF21005D)),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0: return _buildStudentList();
      case 1: return _buildSubjectList();
      case 2: return _buildClassList();
      default: return const SizedBox();
    }
  }

  Widget _tabButton(String text, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6750A4) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF6750A4)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6750A4),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (_studentScores.isEmpty) {
      return const Center(child: Text("Chưa có thông tin điểm sinh viên"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _studentScores.length,
      itemBuilder: (context, index) {
        final item = _studentScores[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black12, width: 0.5)
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("MSSV: ${item.studentCode}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    Text("Môn: ${item.subjectName}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                Text(
                  item.score,
                  style: const TextStyle(fontSize: 22, color: Color(0xFF6750A4), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: StudyInfo.listStudy.length,
      itemBuilder: (context, index) {
        final item = StudyInfo.listStudy[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
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
              await StudyInfo.saveToLocal();
            },
          ),
        );
      },
    );
  }

  Widget _buildClassList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: StudyInfo.listClass.length,
      itemBuilder: (context, index) {
        final item = StudyInfo.listClass[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black12, width: 0.5)
          ),
          child: ListTile(
            title: Text(item.className, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Mã lớp: ${item.classCode}"),
            trailing: const Icon(Icons.class_outlined, color: Color(0xFF6750A4)),
            onLongPress: () async {
              setState(() { StudyInfo.listClass.removeAt(index); });
              await StudyInfo.saveToLocal();
            },
          ),
        );
      },
    );
  }
}
