class Student {
  const Student({
    required this.id,
    required this.name,
    this.code,
    this.className,
    this.email,
    this.phone,
    this.gender,
    this.address,
  });

  final String id;
  final String name;
  final String? code;
  final String? className;
  final String? email;
  final String? phone;
  final String? gender;
  final String? address;

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
    final phone = asString(json['phone']) ?? asString(json['sdt']);
    final gender = asString(json['gender']) ?? asString(json['gioiTinh']);
    final address = asString(json['address']) ?? asString(json['diaChi']);

    return Student(
      id: id.isEmpty ? (code ?? name) : id,
      name: name.isEmpty ? (code ?? id) : name,
      code: code,
      className: className,
      email: email,
      phone: phone,
      gender: gender,
      address: address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'className': className,
      'email': email,
      'phone': phone,
      'gender': gender,
      'address': address,
    };
  }

  Student copyWith({
    String? name,
    String? code,
    String? className,
    String? email,
    String? phone,
    String? gender,
    String? address,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      className: className ?? this.className,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      address: address ?? this.address,
    );
  }
}
