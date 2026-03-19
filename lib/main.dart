import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'study_info_screen.dart';
=======

import 'screens/home_page.dart';
>>>>>>> origin/main

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'Quản lý sinh viên',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEADDFF),
        title: const Text("TH5 - Quản lý sinh viên", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildMenuItem(context, "Quản lý hồ sơ", Icons.person_outline, Colors.blue),
            _buildMenuItem(context, "Danh sách sinh viên", Icons.people_outline, Colors.orange),
            _buildMenuItem(context, "Thông tin học tập", Icons.school_outlined, Colors.green, isTarget: true),
            _buildMenuItem(context, "Cài đặt hệ thống", Icons.settings_outlined, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Color color, {bool isTarget = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (isTarget) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StudyInfoScreen()),
            );
          }
        },
      ),
    );
  }
}
=======
      title: 'Student Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}
>>>>>>> origin/main
