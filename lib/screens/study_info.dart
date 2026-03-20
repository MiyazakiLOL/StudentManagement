import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ClassInfo {
  final String classCode;
  final String className;

  ClassInfo({required this.classCode, required this.className});

  Map<String, dynamic> toJson() => {
    'classCode': classCode,
    'className': className,
  };

  factory ClassInfo.fromJson(Map<String, dynamic> json) => ClassInfo(
    classCode: json['classCode'],
    className: json['className'],
  );
}

class StudyInfo {
  final String subjectName;
  final String semester;
  final String score;

  StudyInfo({
    required this.subjectName,
    required this.semester,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
    'subjectName': subjectName,
    'semester': semester,
    'score': score,
  };

  factory StudyInfo.fromJson(Map<String, dynamic> json) => StudyInfo(
    subjectName: json['subjectName'],
    semester: json['semester'],
    score: json['score'],
  );

  static const String _storageKey = 'cached_study_info';
  static const String _classStorageKey = 'cached_class_info';

  // Kho dữ liệu dùng chung cho toàn ứng dụng
  static List<StudyInfo> listStudy = [];
  static List<ClassInfo> listClass = [];

  // Lưu dữ liệu vào SharedPreferences
  static Future<void> saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String studyEncoded = jsonEncode(listStudy.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, studyEncoded);
      
      final String classEncoded = jsonEncode(listClass.map((e) => e.toJson()).toList());
      await prefs.setString(_classStorageKey, classEncoded);
    } catch (e) {
      print("Lỗi lưu dữ liệu: $e");
    }
  }

  // Tải dữ liệu từ SharedPreferences
  static Future<void> loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Study Info
      final String? cachedStudy = prefs.getString(_storageKey);
      if (cachedStudy != null) {
        final List<dynamic> decoded = jsonDecode(cachedStudy);
        listStudy = decoded.map((e) => StudyInfo.fromJson(e)).toList();
      } else {
        listStudy = [
          StudyInfo(subjectName: "Lập trình Flutter", semester: "Học kỳ 1 - 2026", score: "8.5"),
          StudyInfo(subjectName: "Thiết kế UI/UX", semester: "Học kỳ 2 - 2025", score: "9.0"),
          StudyInfo(subjectName: "Lập trình Android", semester: "Học kỳ 1 - 2025", score: "7.5"),
        ];
      }

      // Load Class Info
      final String? cachedClass = prefs.getString(_classStorageKey);
      if (cachedClass != null) {
        final List<dynamic> decoded = jsonDecode(cachedClass);
        listClass = decoded.map((e) => ClassInfo.fromJson(e)).toList();
      } else {
        listClass = [
          ClassInfo(classCode: "CNTT01", className: "Công nghệ thông tin 1"),
          ClassInfo(classCode: "KTPM02", className: "Kỹ thuật phần mềm 2"),
        ];
      }
      
      await saveToLocal();
    } catch (e) {
      print("Lỗi tải dữ liệu: $e");
    }
  }
}
