import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _gender;
  final List<_StudentProfile> _profiles = <_StudentProfile>[];
  String? _selectedId;

  bool get _hasSelection => _selectedId != null;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profilesJson = prefs.getString('local_students');
      if (profilesJson != null) {
        final List<dynamic> decoded = jsonDecode(profilesJson);
        setState(() {
          _profiles.clear();
          _profiles.addAll(
            decoded.map((item) => _StudentProfile.fromJson(item)).toList(),
          );
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi tải dữ liệu: $e");
    }
  }

  Future<void> _saveProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        _profiles.map((p) => p.toJson()).toList(),
      );
      await prefs.setString('local_students', encoded);
    } catch (e) {
      debugPrint("Lỗi khi lưu dữ liệu: $e");
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    setState(() {
      _selectedId = null;
      _gender = null;
      _fullNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
    });
  }

  void _loadProfileToForm(_StudentProfile profile) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedId = profile.id;
      _gender = profile.gender.trim().isEmpty ? null : profile.gender;
      _fullNameController.text = profile.fullName;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _addressController.text = profile.address;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _addProfile() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final profile = _StudentProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: (_gender ?? '').trim(),
      address: _addressController.text.trim(),
    );

    setState(() {
      _profiles.insert(0, profile);
    });
    _saveProfiles();

    _showSuccess('Đã thêm sinh viên');
    _resetForm();
  }

  void _updateProfile() {
    if (_selectedId == null) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final index = _profiles.indexWhere((p) => p.id == _selectedId);
    if (index < 0) return;

    final updated = _profiles[index].copyWith(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: (_gender ?? '').trim(),
      address: _addressController.text.trim(),
    );

    setState(() {
      _profiles[index] = updated;
    });
    _saveProfiles();

    _showSuccess('Đã cập nhật sinh viên');
    _resetForm();
  }

  Future<void> _confirmAndDelete() async {
    if (_selectedId == null) return;
    final index = _profiles.indexWhere((p) => p.id == _selectedId);
    if (index < 0) return;

    final name = _profiles[index].fullName.trim();
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

    setState(() {
      _profiles.removeAt(index);
    });
    _saveProfiles();
    _showSuccess('Đã xóa sinh viên');
    _resetForm();
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return FilledButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      animationDuration: const Duration(milliseconds: 140),
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
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
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
                            Icon(
                              Icons.person_outline,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Form thông tin',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            if (_hasSelection)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Đang chọn',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _fullNameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Họ tên',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Vui lòng nhập họ tên';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Vui lòng nhập email';
                            final ok = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(text);
                            if (!ok) return 'Email không hợp lệ';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'SĐT',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            final digits = text.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );
                            if (digits.length < 8) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: const InputDecoration(
                            labelText: 'Giới tính',
                            prefixIcon: Icon(Icons.wc_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                            DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                            DropdownMenuItem(
                              value: 'Khác',
                              child: Text('Khác'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _gender = value),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Vui lòng chọn giới tính';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          keyboardType: TextInputType.streetAddress,
                          textInputAction: TextInputAction.newline,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Địa chỉ',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Vui lòng nhập địa chỉ';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.end,
                          children: [
                            FilledButton.icon(
                              onPressed: _addProfile,
                              style: _buttonStyle(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _hasSelection ? _updateProfile : null,
                              style: _buttonStyle(context),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Sửa'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _hasSelection
                                  ? _confirmAndDelete
                                  : null,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Xóa'),
                            ),
                            TextButton.icon(
                              onPressed: _resetForm,
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Reset'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: radius),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.list_alt_outlined,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Danh sách sinh viên',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          if (_profiles.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${_profiles.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_profiles.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Chưa có sinh viên nào. Hãy nhập thông tin và bấm “Thêm”.',
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _profiles.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = _profiles[index];
                            final isSelected = p.id == _selectedId;
                            final subtitleParts = <String>[
                              if (p.email.trim().isNotEmpty) p.email.trim(),
                              if (p.phone.trim().isNotEmpty) p.phone.trim(),
                              if (p.gender.trim().isNotEmpty) p.gender.trim(),
                            ];

                            return ListTile(
                              selected: isSelected,
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? colorScheme.primaryContainer
                                    : null,
                                foregroundColor: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : null,
                                child: Text(
                                  p.fullName.isNotEmpty
                                      ? p.fullName.characters.first
                                            .toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(p.fullName),
                              subtitle: subtitleParts.isEmpty
                                  ? null
                                  : Text(subtitleParts.join(' • ')),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _loadProfileToForm(p),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentProfile {
  const _StudentProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.address,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String address;

  _StudentProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? gender,
    String? address,
  }) {
    return _StudentProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'gender': gender,
        'address': address,
      };

  factory _StudentProfile.fromJson(Map<String, dynamic> json) => _StudentProfile(
        id: json['id'] ?? '',
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        gender: json['gender'] ?? '',
        address: json['address'] ?? '',
      );
}
