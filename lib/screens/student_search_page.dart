import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/student.dart';
import '../services/student_api.dart';

class StudentSearchPage extends StatefulWidget {
  const StudentSearchPage({super.key});

  @override
  State<StudentSearchPage> createState() => _StudentSearchPageState();
}

class _StudentSearchPageState extends State<StudentSearchPage> {
  late final StudentApi _api;
  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String _searchQuery = '';
  String? _selectedClass;
  String _sortBy = 'name_asc'; // name_asc, name_desc, code_asc, code_desc

  @override
  void initState() {
    super.initState();
    _api = StudentApi(
      baseUrl: AppConfig.apiBaseUrl,
      studentsPath: AppConfig.studentsPath,
    );
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final students = await _api.fetchStudents();
      setState(() {
        _allStudents = students;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Student> results = _allStudents.where((student) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = student.name.toLowerCase().contains(query) ||
          (student.code?.toLowerCase().contains(query) ?? false) ||
          (student.email?.toLowerCase().contains(query) ?? false);
      
      final matchesClass = _selectedClass == null || student.className == _selectedClass;
      
      return matchesSearch && matchesClass;
    }).toList();

    // Sorting
    results.sort((a, b) {
      switch (_sortBy) {
        case 'name_asc':
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case 'name_desc':
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case 'code_asc':
          return (a.code ?? '').compareTo(b.code ?? '');
        case 'code_desc':
          return (b.code ?? '').compareTo(a.code ?? '');
        default:
          return 0;
      }
    });

    setState(() {
      _filteredStudents = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final classes = _allStudents
        .map((s) => s.className)
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    classes.sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm & Phân loại'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, MSSV, email...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ActionChip(
                  avatar: const Icon(Icons.sort, size: 16),
                  label: Text(_getSortLabel()),
                  onPressed: _showSortDialog,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Tất cả lớp'),
                  selected: _selectedClass == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedClass = null;
                        _applyFilters();
                      });
                    }
                  },
                  visualDensity: VisualDensity.compact,
                ),
                ...classes.map((className) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: FilterChip(
                      label: Text(className),
                      selected: _selectedClass == className,
                      onSelected: (selected) {
                        setState(() {
                          _selectedClass = selected ? className : null;
                          _applyFilters();
                        });
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
              ],
            ),
          ),
          if (!_isLoading && _errorMessage.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Tìm thấy ${_filteredStudents.length} sinh viên',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'name_asc': return 'Tên A-Z';
      case 'name_desc': return 'Tên Z-A';
      case 'code_asc': return 'MSSV ↑';
      case 'code_desc': return 'MSSV ↓';
      default: return 'Sắp xếp';
    }
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Sắp xếp theo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Tên A-Z'),
                trailing: _sortBy == 'name_asc' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () => _updateSort('name_asc'),
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Tên Z-A'),
                trailing: _sortBy == 'name_desc' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () => _updateSort('name_desc'),
              ),
              ListTile(
                leading: const Icon(Icons.format_list_numbered),
                title: const Text('MSSV Tăng dần'),
                trailing: _sortBy == 'code_asc' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () => _updateSort('code_asc'),
              ),
              ListTile(
                leading: const Icon(Icons.format_list_numbered),
                title: const Text('MSSV Giảm dần'),
                trailing: _sortBy == 'code_desc' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () => _updateSort('code_desc'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateSort(String value) {
    setState(() {
      _sortBy = value;
      _applyFilters();
    });
    Navigator.pop(context);
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _fetchStudents,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy sinh viên phù hợp',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredStudents.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final s = _filteredStudents[index];
        final initials = s.name.trim().split(' ').last.characters.first.toUpperCase();
        
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: Colors.primaries[s.name.length % Colors.primaries.length].withOpacity(0.2),
            child: Text(
              initials,
              style: TextStyle(color: Colors.primaries[s.name.length % Colors.primaries.length], fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MSSV: ${s.code ?? 'N/A'} • Lớp: ${s.className ?? 'N/A'}'),
              if (s.email != null && s.email!.isNotEmpty)
                Text(s.email!, style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}
