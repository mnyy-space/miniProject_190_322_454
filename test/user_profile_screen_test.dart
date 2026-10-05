import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halalsefllearning/screens/user_main_layout.dart';
import 'helpers/fake_backend.dart';

void main() {
  group('UserProfileScreen Tests', () {
    adminTestWidgets('แสดงข้อมูลผู้ใช้, ซ่อนการแจ้งเตือน/ภาษา/คู่มือ, และมีปุ่มออกจากระบบ', (tester, backend) async {
      await pumpAdminScreen(tester, const UserProfileScreen(), size: const Size(420, 900));

      expect(find.text('บัญชีของฉัน'), findsOneWidget);
      expect(find.text('ข้อมูลบัญชีผู้ใช้'), findsOneWidget);
      expect(find.text('Murnee Madsakul'), findsWidgets);
      expect(find.text('@Murnee'), findsOneWidget);
      expect(find.text('ผู้เรียน (Student)'), findsWidgets);
      expect(find.text('แก้ไขข้อมูลส่วนตัว'), findsOneWidget);
      expect(find.text('ออกจากระบบ'), findsOneWidget);

      // ตรวจสอบว่าไม่มีเมนูที่ผู้ใช้สั่งเอาออก
      expect(find.text('รหัสผู้ใช้ (User ID)'), findsNothing);
      expect(find.text('การแจ้งเตือน'), findsNothing);
      expect(find.text('ภาษา (Language)'), findsNothing);
      expect(find.text('ศูนย์ช่วยเหลือ & คู่มือ'), findsNothing);
    });

    adminTestWidgets('เปิด Dialog แก้ไขข้อมูลส่วนตัว และบันทึกสำเร็จ', (tester, backend) async {
      await pumpAdminScreen(tester, const UserProfileScreen(), size: const Size(420, 900));

      await tester.tap(find.text('แก้ไขข้อมูลส่วนตัว'));
      await tester.pumpAndSettle();

      expect(find.text('แก้ไขข้อมูลส่วนตัว'), findsWidgets);
      expect(find.text('ชื่อบัญชีผู้ใช้ (Username)'), findsOneWidget);
      expect(find.text('@Murnee'), findsWidgets);

      // แก้ไขชื่อ-นามสกุล
      final fullNameField = find.widgetWithText(TextFormField, 'Murnee Madsakul');
      await tester.enterText(fullNameField, 'Murnee Updated');

      await tester.tap(find.text('บันทึกข้อมูล'));
      await tester.pumpAndSettle();

      expect(backend.requests, contains('PUT user/profile'));
      expect(find.text('บันทึกข้อมูลส่วนตัวเรียบร้อยแล้ว'), findsOneWidget);
      expect(find.text('Murnee Updated'), findsWidgets);
    });
  });
}
