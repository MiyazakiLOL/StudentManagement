import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Kho dữ liệu dùng chung cho toàn ứng dụng
  static List<StudyInfo> listStudy = [];

  // Lưu dữ liệu vào SharedPreferences
  static Future<void> saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(listStudy.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      print("Lỗi lưu dữ liệu học tập: $e");
    }
  }

  // Tải dữ liệu từ SharedPreferences
  static Future<void> loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_storageKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        listStudy = decoded.map((e) => StudyInfo.fromJson(e)).toList();
      } else {
        // Dữ liệu mặc định nếu chưa có cache
        listStudy = [
          StudyInfo(subjectName: "Lập trình Flutter", semester: "Học kỳ 1 - 2026", score: "8.5"),
          StudyInfo(subjectName: "Thiết kế UI/UX", semester: "Học kỳ 2 - 2025", score: "9.0"),
          StudyInfo(subjectName: "Lập trình Android", semester: "Học kỳ 1 - 2025", score: "7.5"),
        ];
        await saveToLocal();
      }
    } catch (e) {
      print("Lỗi tải dữ liệu học tập: $e");
    }
  }
}
