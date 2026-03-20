class Student {
  final String id; // MockAPI dùng String cho ID
  final String name;
  final String? code;
  final String? className;
  final String? email;
  final String? phone;
  final String? gender;

  Student({
    required this.id,
    required this.name,
    this.code,
    this.className,
    this.email,
    this.phone,
    this.gender,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      code: json['code']?.toString(),
      className: json['className']?.toString(),
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? 'Nam',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'className': className,
      'email': email,
      'phone': phone,
      'gender': gender,
    };
  }
}
