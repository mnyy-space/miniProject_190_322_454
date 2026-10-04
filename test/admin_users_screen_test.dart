import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halalsefllearning/screens/admin/admin_users_screen.dart';

import 'helpers/fake_backend.dart';

void main() {
  group('AdminUsersScreen - UX/UI and CRUD with Role Stats', () {
    adminTestWidgets('1. แสดงข้อมูลผู้ใช้ และ 5. จำนวนผู้ใช้แยกตาม role', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminUsersScreen());

      expect(backend.requests, contains('GET admin/user'));
      expect(find.text('จัดการข้อมูลผู้ใช้'), findsOneWidget);

      // ตรวจสอบ การ์ดสถิติจำนวนผู้ใช้แยกตาม role
      expect(find.text('ผู้ใช้งานทั้งหมด'), findsOneWidget);
      expect(find.text('ผู้ดูแลระบบ (Admin)'), findsOneWidget);
      expect(find.text('ผู้ใช้งานทั่วไป (User)'), findsOneWidget);

      // ตรวจสอบหัวตาราง
      expect(find.text('ชื่อ - นามสกุล'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('เนื้อหาที่เรียน'), findsOneWidget);
      expect(find.text('บทบาท (Role)'), findsOneWidget);
      expect(find.text('การจัดการ'), findsOneWidget);

      // ตรวจสอบข้อมูลผู้ใช้ในตาราง
      expect(find.text('System Administrator'), findsOneWidget);
      expect(find.text('@admin'), findsOneWidget);
      expect(find.text('Arrays (Array เบื้องต้น)'), findsOneWidget);

      expect(find.text('Afdol User'), findsOneWidget);
      expect(find.text('@afdol'), findsOneWidget);
      expect(find.text('Functions (Introduction)'), findsOneWidget);
    });

    adminTestWidgets('5. คลิกการ์ดจำนวนผู้ใช้เพื่อกรองข้อมูลตาม role ทันที', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminUsersScreen());

      // คลิกการ์ด 'ผู้ดูแลระบบ (Admin)'
      await tester.tap(find.text('ผู้ดูแลระบบ (Admin)'));
      await tester.pumpAndSettle();

      expect(find.text('System Administrator'), findsOneWidget);
      expect(find.text('Afdol User'), findsNothing);

      // คลิกการ์ด 'ผู้ใช้งานทั่วไป (User)'
      await tester.tap(find.text('ผู้ใช้งานทั่วไป (User)'));
      await tester.pumpAndSettle();

      expect(find.text('Afdol User'), findsOneWidget);
      expect(find.text('System Administrator'), findsNothing);

      // คลิกการ์ด 'ผู้ใช้งานทั้งหมด'
      await tester.tap(find.text('ผู้ใช้งานทั้งหมด'));
      await tester.pumpAndSettle();

      expect(find.text('System Administrator'), findsOneWidget);
      expect(find.text('Afdol User'), findsOneWidget);
    });

    adminTestWidgets('1. ดูรายละเอียดข้อมูลผู้ใช้ (Detail Dialog)', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminUsersScreen());

      await tester.tap(find.byTooltip('ดูรายละเอียด').first);
      await tester.pumpAndSettle();

      expect(find.text('รหัสผู้ใช้ (User ID):'), findsOneWidget);
      expect(find.text('ชื่อบัญชีผู้ใช้ (Username):'), findsOneWidget);
      expect(find.text('เนื้อหาที่เรียน:'), findsOneWidget);
      expect(find.text('Arrays (Array เบื้องต้น)'), findsWidgets);

      await tester.tap(find.text('ปิด'));
      await tester.pumpAndSettle();
    });

    adminTestWidgets('3. เพิ่มข้อมูลผู้ใช้ (Add User Dialog & POST admin/user)', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminUsersScreen());

      await tester.tap(find.text('เพิ่มข้อมูลผู้ใช้'));
      await tester.pumpAndSettle();

      expect(find.text('เพิ่มผู้ใช้ใหม่'), findsOneWidget);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'newstudent');
      await tester.enterText(textFields.at(1), 'New Student');
      await tester.enterText(textFields.at(2), 'student@example.com');
      await tester.enterText(textFields.at(3), '123456');

      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      expect(backend.requests, contains('POST admin/user'));
      final postBody = backend.bodyOf('POST admin/user');
      expect(postBody['username'], 'newstudent');
      expect(postBody['full_name'], 'New Student');
      expect(postBody['email'], 'student@example.com');
      expect(postBody['role_id'], 1);
    });

    adminTestWidgets('2. แก้ไขข้อมูลผู้ใช้ (Edit User Dialog & PUT admin/user)', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminUsersScreen());

      await tester.tap(find.byTooltip('แก้ไขข้อมูลผู้ใช้').last);
      await tester.pumpAndSettle();

      expect(find.text('แก้ไขข้อมูลผู้ใช้'), findsOneWidget);

      final fullNameField = find.widgetWithText(TextFormField, 'Afdol User');
      await tester.enterText(fullNameField, 'Afdol Updated');

      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      expect(backend.requests, contains('PUT admin/user/4'));
      final putBody = backend.bodyOf('PUT admin/user/4');
      expect(putBody['full_name'], 'Afdol Updated');
    });

    adminTestWidgets('4. ลบข้อมูลผู้ใช้ (Delete User & DELETE admin/user)', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminUsersScreen());

      // ลบ afdol (user id 4)
      await tester.tap(find.byTooltip('ลบผู้ใช้งาน').last);
      await tester.pumpAndSettle();

      expect(find.text('ลบข้อมูลผู้ใช้'), findsOneWidget);

      await tester.tap(find.text('ลบ'));
      await tester.pumpAndSettle();

      expect(backend.requests, contains('DELETE admin/user/4'));
    });

    adminTestWidgets('แสดงผลและจัดการบนหน้าจอมือถือ (Mobile Responsive)', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminUsersScreen(), size: mobileSize);

      expect(find.text('System Administrator'), findsOneWidget);
      expect(find.text('เนื้อหาที่เรียน'), findsWidgets);
      expect(find.text('ดู'), findsWidgets);
      expect(find.text('แก้ไข'), findsWidgets);
      expect(find.text('ลบ'), findsWidgets);
    });
  });
}

