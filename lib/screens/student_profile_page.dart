import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_api.dart';
import '../config/app_config.dart';
import 'study_info.dart'; 

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
  String? _selectedClass;
  
  List<String> get _classList => StudyInfo.listStudy.map((e) => e.subjectName).toSet().toList();
  final List<String> _genderList = ['Nam', 'Nữ'];

  late final StudentApi _api;
  List<Student> _students = [];
  bool _isLoading = true;
  Student? _editingStudent;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // Đảm bảo load dữ liệu học tập offline trước
    await StudyInfo.loadFromLocal();
    if (_classList.isNotEmpty) {
      _selectedClass = _classList[0];
    }
    _api = StudentApi(baseUrl: AppConfig.apiBaseUrl, studentsPath: AppConfig.studentsPath);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _api.fetchStudents();
    if (mounted) {
      setState(() {
        _students = data;
        _isLoading = false;
      });
    }
  }

  void _onStudentTap(Student s) {
    setState(() {
      _editingStudent = s;
      _codeController.text = s.code ?? '';
      _nameController.text = s.name;
      _emailController.text = s.email ?? '';
      _phoneController.text = s.phone ?? '';
      _selectedGender = s.gender ?? 'Nam';
      _selectedClass = _classList.contains(s.className) ? s.className : (_classList.isNotEmpty ? _classList[0] : null);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUpdate ? 'Cập nhật thành công!' : 'Thêm thành công!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
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
      _selectedClass = _classList.isNotEmpty ? _classList[0] : null;
      _editingStudent = null;
    });
  }

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6750A4), width: 1.5)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black26, width: 1)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6750A4), width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FA),
      appBar: AppBar(
        title: const Text('Quản lý hồ sơ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFEADDFF),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                border: Border.all(color: const Color(0xFFEADDFF), width: 1)
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _codeController, 
                      decoration: _inputStyle('MSSV'), 
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập MSSV';
                        if (value.length < 5) return 'MSSV không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController, 
                      decoration: _inputStyle('Họ tên'), 
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập họ tên';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: _inputStyle('Lớp (Dữ liệu học tập)'),
                      items: _classList.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
                      onChanged: (v) => setState(() => _selectedClass = v!),
                      validator: (value) => value == null ? 'Vui lòng chọn lớp' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController, 
                      decoration: _inputStyle('Email'), 
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) return 'Email không đúng định dạng';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController, 
                      decoration: _inputStyle('SĐT'), 
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập số điện thoại';
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'SĐT phải có 10 chữ số';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: _inputStyle('Giới tính'),
                      items: _genderList.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                      onChanged: (v) => setState(() => _selectedGender = v!),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _save(false),
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text("THÊM MỚI", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6750A4), 
                            foregroundColor: Colors.white, 
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16)
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: _editingStudent != null ? () => _save(true) : null,
                          icon: const Icon(Icons.edit),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFE7E0EC),
                            padding: const EdgeInsets.all(16)
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          onPressed: _editingStudent != null ? _delete : null,
                          icon: const Icon(Icons.delete_sweep_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF9DEDC),
                            foregroundColor: const Color(0xFF410002),
                            padding: const EdgeInsets.all(16)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _clearForm,
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text("Làm mới biểu mẫu", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF6750A4)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Row(
              children: [
                Icon(Icons.list_alt, color: Color(0xFF6750A4)),
                SizedBox(width: 8),
                Text("DANH SÁCH SINH VIÊN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF6750A4), letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading 
              ? const CircularProgressIndicator()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _students.length,
                  itemBuilder: (context, i) {
                    final s = _students[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
                      ),
                      child: ListTile(
                        onTap: () => _onStudentTap(s),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF6750A4), width: 1)),
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFFEADDFF),
                            child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF21005D), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('MSSV: ${s.code ?? "N/A"} • Lớp: ${s.className ?? "N/A"}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
