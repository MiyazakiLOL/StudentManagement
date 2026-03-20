import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isRegistering = false;

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _usernameController.text.trim();
    final pass = _passwordController.text.trim();

    if (_isRegistering) {
      final success = await AuthService.register(user, pass);
      if (success) {
        setState(() => _isRegistering = false);
        _usernameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công! Hãy đăng nhập.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tài khoản đã tồn tại')));
      }
    } else {
      final success = await AuthService.login(user, pass);
      if (success) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sai tài khoản hoặc mật khẩu')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isRegistering ? Icons.person_add_alt_1_rounded : Icons.school_rounded, 
                  size: 80, 
                  color: const Color(0xFF6750A4)
                ),
                const SizedBox(height: 16),
                Text(
                  _isRegistering ? 'TẠO TÀI KHOẢN' : 'STUDENT MANAGER', 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF6750A4))
                ),
                const SizedBox(height: 8),
                if (_isRegistering)
                  const Text(
                    'Tham gia cùng chúng tôi ngay hôm nay!',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập tên đăng nhập';
                    if (value.length < 3) return 'Tên đăng nhập phải ít nhất 3 ký tự';
                    return null;
                  },
                ),
                if (_isRegistering) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email liên hệ',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) return 'Email không đúng định dạng';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (value.length < 6) return 'Mật khẩu phải ít nhất 6 ký tự';
                    return null;
                  },
                ),
                if (_isRegistering) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu',
                      prefixIcon: const Icon(Icons.lock_clock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                      if (value != _passwordController.text) return 'Mật khẩu xác nhận không khớp';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6750A4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_isRegistering ? 'ĐĂNG KÝ NGAY' : 'ĐĂNG NHẬP', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isRegistering ? 'Đã có tài khoản?' : 'Chưa có tài khoản?'),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isRegistering = !_isRegistering;
                        });
                        _usernameController.clear();
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                        _emailController.clear();
                        _formKey.currentState?.reset();
                      },
                      child: Text(
                        _isRegistering ? 'Đăng nhập' : 'Đăng ký ngay',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6750A4)),
                      ),
                    ),
                  ],
                ),
                if (!_isRegistering) ...[
                  const SizedBox(height: 20),
                  const Text('Mặc định: admin / admin', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
