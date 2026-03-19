import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_api.dart';
import '../config/app_config.dart';

class StudentProfileManagementPage extends StatefulWidget {
  const StudentProfileManagementPage({super.key});

  @override
  State<StudentProfileManagementPage> createState() => _StudentProfileManagementPageState();
}

class _StudentProfileManagementPageState extends State<StudentProfileManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Nam';
  
  late final StudentApi _api;
  List<Student> _students = [];
  bool _isLoading = true;
  Student? _editingStudent;

  @override
  void initState() {
    super.initState();
    _api = StudentApi(baseUrl: AppConfig.apiBaseUrl, studentsPath: AppConfig.studentsPath);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.fetchStudents();
      setState(() => _students = data);
    } catch (e) {
      debugPrint("Lỗi tải danh sách: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final student = Student(
      id: _editingStudent?.id ?? '',
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      gender: _selectedGender,
    );

    try {
      if (_editingStudent == null) {
        await _api.createStudent(student);
      } else {
        await _api.updateStudent(student);
      }
      _clearForm();
      _loadData(); // Load lại danh sách sau khi lưu
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi API: $e')));
    }
  }

  Future<void> _confirmDelete(Student s) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn xóa sinh viên "${s.name}" khỏi hệ thống không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa ngay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // MockAPI cần ID để xóa: /students/:id
        await _api.deleteStudent(int.parse(s.id));
        _loadData(); // Tải lại danh sách sau khi xóa thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa dữ liệu thành công'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi khi xóa: Vui lòng thử lại'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _selectedGender = 'Nam';
    _editingStudent = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý hồ sơ')),
      body: Column(
        children: [
          // PHẦN FORM NHẬP
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(_editingStudent == null ? "THÊM MỚI" : "SỬA HỒ SƠ", 
                           style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Họ tên')),
                      TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại'))),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: _selectedGender,
                            onChanged: (v) => setState(() => _selectedGender = v!),
                            items: ['Nam', 'Nữ'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: _save, child: Text(_editingStudent == null ? 'THÊM' : 'CẬP NHẬT')),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          // PHẦN DANH SÁCH THAO TÁC
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, i) {
                      final s = _students[i];
                      return ListTile(
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${s.gender} - ${s.phone}\n${s.email}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.orange), 
                              onPressed: () => setState(() {
                                _editingStudent = s;
                                _nameController.text = s.name;
                                _emailController.text = s.email ?? '';
                                _phoneController.text = s.phone ?? '';
                                _selectedGender = s.gender ?? 'Nam';
                              })),
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), 
                              onPressed: () => _confirmDelete(s)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}