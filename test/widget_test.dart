// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:student_management/main.dart';

void main() {
  testWidgets('Home page renders key sections', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: true));

    expect(find.text('TH5 - Nhóm 3 - Student Manager'), findsOneWidget);

    expect(find.text('Quản lý hồ sơ'), findsOneWidget);
    expect(find.text('Danh sách sinh viên'), findsOneWidget);
    expect(find.text('Thông tin học tập'), findsOneWidget);
    expect(find.text('Tìm kiếm / Phân loại'), findsOneWidget);
  });
}
