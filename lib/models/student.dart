class Student {
  const Student({
    required this.id,
    required this.name,
    this.code,
    this.className,
    this.email,
  });

  final String id;
  final String name;
  final String? code;
  final String? className;
  final String? email;

  factory Student.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is num || value is bool) return value.toString();
      return null;
    }

    final id =
        asString(json['id']) ??
        asString(json['_id']) ??
        asString(json['studentId']) ??
        asString(json['maSV']) ??
        asString(json['mssv']) ??
        '';

    final name =
        asString(json['name']) ??
        asString(json['fullName']) ??
        asString(json['hoTen']) ??
        asString(json['ten']) ??
        '';

    final code =
        asString(json['code']) ??
        asString(json['studentCode']) ??
        asString(json['maSV']) ??
        asString(json['mssv']);

    final className =
        asString(json['className']) ??
        asString(json['lop']) ??
        asString(json['class']);

    final email = asString(json['email']);

    return Student(
      id: id.isEmpty ? (code ?? name) : id,
      name: name.isEmpty ? (code ?? id) : name,
      code: code,
      className: className,
      email: email,
    );
  }
}
