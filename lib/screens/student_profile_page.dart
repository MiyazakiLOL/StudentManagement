import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/student.dart';
import '../services/student_api.dart';

class StudentProfileManagementPage extends StatefulWidget {
  const StudentProfileManagementPage({super.key});

  @override
  State<StudentProfileManagementPage> createState() =>
      _StudentProfileManagementPageState();
}

class _StudentProfileManagementPageState
    extends State<StudentProfileManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _fullNameController = TextEditingController();
  final _studentCodeController = TextEditingController();
  final _classController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _gender;
  List<Student> _profiles = <Student>[];
  String? _selectedId;
  bool _isLoading = true;

  late final StudentApi _api;

  bool get _hasSelection => _selectedId != null;

  @override
  void initState() {
    super.initState();
    _api = StudentApi(
      baseUrl: AppConfig.apiBaseUrl,
      studentsPath: AppConfig.studentsPath,
    );
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      final students = await _api.fetchStudents();
      setState(() {
        _profiles = List.from(students);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Lỗi khi tải dữ liệu: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _studentCodeController.dispose();
    _classController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    setState(() {
      _selectedId = null;
      _gender = null;
      _fullNameController.clear();
      _studentCodeController.clear();
      _classController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
    });
  }

  void _loadProfileToForm(Student profile) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedId = profile.id;
      _gender = (profile.gender ?? '').trim().isEmpty ? null : profile.gender;
      _fullNameController.text = profile.name;
      _studentCodeController.text = profile.code ?? '';
      _classController.text = profile.className ?? '';
      _emailController.text = profile.email ?? '';
      _phoneController.text = profile.phone ?? '';
      _addressController.text = profile.address ?? '';
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _addProfile() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final profile = Student(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _fullNameController.text.trim(),
      code: _studentCodeController.text.trim(),
      className: _classController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: (_gender ?? '').trim(),
      address: _addressController.text.trim(),
    );

    await _api.addStudent(profile);
    _showSuccess('Đã thêm sinh viên vào hệ thống');
    _resetForm();
    _loadProfiles();
  }

  Future<void> _updateProfile() async {
    if (_selectedId == null) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final updated = Student(
      id: _selectedId!,
      name: _fullNameController.text.trim(),
      code: _studentCodeController.text.trim(),
      className: _classController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: (_gender ?? '').trim(),
      address: _addressController.text.trim(),
    );

    await _api.updateStudent(updated);
    _showSuccess('Đã cập nhật thông tin sinh viên');
    _resetForm();
    _loadProfiles();
  }

  Future<void> _confirmAndDelete() async {
    if (_selectedId == null) return;
    final index = _profiles.indexWhere((p) => p.id == _selectedId);
    if (index < 0) return;

    final name = _profiles[index].name.trim();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          title: const Text('Xác nhận xóa'),
          content: Text(
            name.isEmpty
                ? 'Bạn có chắc muốn xóa sinh viên này?'
                : 'Bạn có chắc muốn xóa “$name”?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    await _api.deleteStudent(_selectedId!);
    _showSuccess('Đã xóa sinh viên khỏi hệ thống');
    _resetForm();
    _loadProfiles();
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return FilledButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(22);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý hồ sơ sinh viên'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfiles,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: radius),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.edit_note, color: colorScheme.primary, size: 28),
                                  const SizedBox(width: 8),
                                  Text(
                                    _hasSelection ? 'Cập nhật thông tin' : 'Thêm sinh viên mới',
                                    style: Theme.of(context).textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: _studentCodeController,
                                      decoration: const InputDecoration(
                                        labelText: 'MSSV',
                                        prefixIcon: Icon(Icons.numbers),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => (v?.isEmpty ?? true) ? 'Bắt buộc' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: _fullNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Họ và tên',
                                        prefixIcon: Icon(Icons.person_outline),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => (v?.isEmpty ?? true) ? 'Bắt buộc' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _classController,
                                      decoration: const InputDecoration(
                                        labelText: 'Lớp',
                                        prefixIcon: Icon(Icons.class_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => (v?.isEmpty ?? true) ? 'Bắt buộc' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _gender,
                                      decoration: const InputDecoration(
                                        labelText: 'Giới tính',
                                        prefixIcon: Icon(Icons.wc_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                                        DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                                        DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                                      ],
                                      onChanged: (value) => setState(() => _gender = value),
                                      validator: (v) => v == null ? 'Bắt buộc' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Bắt buộc';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Email sai định dạng';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Số điện thoại',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _addressController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Địa chỉ',
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.end,
                                children: [
                                  if (!_hasSelection)
                                    FilledButton.icon(
                                      onPressed: _addProfile,
                                      style: _buttonStyle(context),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Thêm mới'),
                                    ),
                                  if (_hasSelection) ...[
                                    FilledButton.icon(
                                      onPressed: _updateProfile,
                                      style: _buttonStyle(context),
                                      icon: const Icon(Icons.save_outlined),
                                      label: const Text('Lưu thay đổi'),
                                    ),
                                    FilledButton.tonalIcon(
                                      onPressed: _confirmAndDelete,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: colorScheme.errorContainer,
                                        foregroundColor: colorScheme.onErrorContainer,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      ),
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Xóa'),
                                    ),
                                  ],
                                  OutlinedButton.icon(
                                    onPressed: _resetForm,
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.restart_alt),
                                    label: const Text('Hủy/Làm mới'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.list_alt, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Danh sách đã lưu (${_profiles.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_profiles.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('Chưa có dữ liệu sinh viên')),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _profiles.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final p = _profiles[index];
                          final isSelected = p.id == _selectedId;
                          return Card(
                            elevation: isSelected ? 4 : 1,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isSelected 
                                ? BorderSide(color: colorScheme.primary, width: 2)
                                : BorderSide.none,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primaryContainer,
                                child: Text(p.name[0].toUpperCase()),
                              ),
                              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('MSSV: ${p.code ?? "N/A"} • Lớp: ${p.className ?? "N/A"}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _loadProfileToForm(p),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
