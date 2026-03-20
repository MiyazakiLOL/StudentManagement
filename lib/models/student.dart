class Student {
  final String id; // MockAPI dùng String cho ID
  final String name;
  final String? email;
  final String? phone;
  final String? gender;

  Student({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.gender,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? 'Nam',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
    };
  }
}