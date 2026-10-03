import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halalsefllearning/screens/login_srceen.dart';
import 'package:halalsefllearning/screens/register_screen.dart';

void main() {
  group('Auth Screens Tests', () {
    testWidgets('LoginScreen แสดงองค์ประกอบครบถ้วนตามดีไซน์', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign in to continue.'), findsOneWidget);
      expect(find.text('NAME'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text("Don’t have an account ? "), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('กด Sign up ในหน้า Login จะเปิดหน้า RegisterScreen', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Create new\nAccount'), findsOneWidget);
      expect(find.text('NAME'), findsOneWidget);
      expect(find.text('LASTNAME'), findsOneWidget);
      expect(find.text('USERNAME'), findsOneWidget);
      expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
      expect(find.text('Log in here.'), findsOneWidget);
    });

    testWidgets('RegisterScreen ตรวจสอบ validation รหัสผ่านไม่ตรงกัน', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John');
      await tester.enterText(textFields.at(1), 'Doe');
      await tester.enterText(textFields.at(2), 'johndoe');
      await tester.enterText(textFields.at(3), '123456');
      await tester.enterText(textFields.at(4), '654321');

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('รหัสผ่านไม่ตรงกัน'), findsOneWidget);
    });
  });
}
