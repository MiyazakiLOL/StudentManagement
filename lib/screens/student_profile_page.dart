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
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedGender = 'Nam';
  String _selectedClass = 'DCT1211';
  
  final List<String> _classList = ['DCT1211', 'DCT1212', 'DCT1213', 'DCT1214', 'DCT1215'];
  final List<String> _genderList = ['Nam', 'Nữ'];

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
    final data = await _api.fetchStudents();
    setState(() {
      _students = data;
      _isLoading = false;
    });
  }

  void _onStudentTap(Student s) {
    setState(() {
      _editingStudent = s;
      _codeController.text = s.code ?? '';
      _nameController.text = s.name;
      _emailController.text = s.email ?? '';
      _phoneController.text = s.phone ?? '';
      _selectedGender = s.gender ?? 'Nam';
      _selectedClass = _classList.contains(s.className) ? s.className! : _classList[0];
    });
  }

  Future<void> _save(bool isUpdate) async {
    if (!_formKey.currentState!.validate()) return;

    final student = Student(
      id: isUpdate ? (_editingStudent?.id ?? DateTime.now().millisecondsSinceEpoch.toString()) : DateTime.now().millisecondsSinceEpoch.toString(),
      code: _codeController.text,
      name: _nameController.text,
      className: _selectedClass,
      email: _emailController.text,
      phone: _phoneController.text,
      gender: _selectedGender,
    );

    try {
      if (isUpdate) {
        await _api.updateStudent(student);
      } else {
        await _api.createStudent(student);
      }
      _clearForm();
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUpdate ? 'Cập nhật thành công!' : 'Thêm thành công!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _delete() async {
    if (_editingStudent == null) return;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Xóa sinh viên ${_editingStudent!.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      // Đảm bảo truyền vào String id
      await _api.deleteStudent(_editingStudent!.id.toString());
      _clearForm();
      _loadData();
    }
  }

  void _clearForm() {
    _codeController.clear();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    setState(() {
      _selectedGender = 'Nam';
      _selectedClass = _classList[0];
      _editingStudent = null;
    });
  }

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.grey)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(title: const Text('Quản lý hồ sơ'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(controller: _codeController, decoration: _inputStyle('MSSV')),
                    const SizedBox(height: 12),
                    TextFormField(controller: _nameController, decoration: _inputStyle('Họ tên')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: _inputStyle('Lớp'),
                      items: _classList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedClass = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(controller: _emailController, decoration: _inputStyle('Email')),
                    const SizedBox(height: 12),
                    TextFormField(controller: _phoneController, decoration: _inputStyle('SĐT')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: _inputStyle('Giới tính'),
                      items: _genderList.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _selectedGender = v!),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _save(false),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Thêm"),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _editingStudent != null ? () => _save(true) : null,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("Sửa"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _editingStudent != null ? _delete : null,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text("Xóa"),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFEBEE), foregroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _clearForm,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text("Reset"),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF6750A4)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text("Danh sách sinh viên", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 10),
            _isLoading 
              ? const CircularProgressIndicator()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _students.length,
                  itemBuilder: (context, i) {
                    final s = _students[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _onStudentTap(s),
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${s.code} - ${s.className}'),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
