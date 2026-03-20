import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userKey = 'registered_users';
  static const String _loginKey = 'is_logged_in';
  static const String _currentUserKey = 'current_user';

  // Lấy danh sách user đã đăng ký
  static Future<Map<String, String>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_userKey);
    if (data == null) {
      return {'admin': 'admin'}; // Tài khoản mặc định
    }
    return Map<String, String>.from(jsonDecode(data));
  }

  // Lấy tên user hiện tại
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Đăng ký
  static Future<bool> register(String username, String password) async {
    final Map<String, dynamic> users = await _getUsers();
    if (users.containsKey(username)) return false; // User đã tồn tại

    users[username] = password;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(users));
    return true;
  }

  // Đăng nhập
  static Future<bool> login(String username, String password) async {
    final users = await _getUsers();
    if (users[username] == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_loginKey, true);
      await prefs.setString(_currentUserKey, username);
      return true;
    }
    return false;
  }

  // Đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
    await prefs.remove(_currentUserKey);
  }

  // Kiểm tra trạng thái đăng nhập
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }
}
