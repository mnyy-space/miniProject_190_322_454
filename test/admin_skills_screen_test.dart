import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halalsefllearning/screens/admin/admin_skills_screen.dart';

import 'helpers/fake_backend.dart';

void main() {
  group('AdminSkillsScreen', () {
    adminTestWidgets('โหลดและแสดงรายการ Skill ในตาราง (desktop)', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminSkillsScreen());

      expect(backend.requests, contains('GET admin/skill'));
      expect(find.text('จัดการ Skill'), findsOneWidget);
      expect(find.text('Skill ทั้งหมด 2 รายการ'), findsOneWidget);
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('Arrays'), findsOneWidget);
      expect(find.text('Stack & Queue'), findsOneWidget);
    });

    adminTestWidgets('ค้นหาและกรองตามสถานะได้', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminSkillsScreen());

      await tester.enterText(find.byType(TextField).first, 'stack');
      await tester.pumpAndSettle();
      expect(find.text('Arrays'), findsNothing);
      expect(find.text('Stack & Queue'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '');
      await tester.tap(find.text('ทุกสถานะ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Active').last);
      await tester.pumpAndSettle();
      expect(find.text('Arrays'), findsOneWidget);
      expect(find.text('Stack & Queue'), findsNothing);
    });

    adminTestWidgets('สลับสถานะแล้วส่ง PATCH ไป backend', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminSkillsScreen());

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(backend.requests, contains('PATCH admin/skill/1/status'));
      expect(backend.bodyOf('PATCH admin/skill/1/status'), {'is_active': 0});
      expect(find.text('Inactive'), findsNWidgets(2));
    });

    adminTestWidgets('เพิ่ม Skill ใหม่ผ่าน dialog แล้วโหลดรายการใหม่', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminSkillsScreen());

      await tester.tap(find.text('เพิ่ม Skill ใหม่'));
      await tester.pumpAndSettle();
      final dialogFields = inDialog(find.byType(TextField));
      await tester.enterText(dialogFields.at(0), 'TREES');
      await tester.enterText(dialogFields.at(1), 'Binary Trees');
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      expect(backend.bodyOf('POST admin/skill'), {
        'skill_code': 'TREES',
        'skill_name': 'Binary Trees',
        'skill_icon': 'school',
        'is_active': 1,
      });
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Binary Trees'), findsOneWidget);
      expect(find.text('Skill ทั้งหมด 3 รายการ'), findsOneWidget);
    });

    adminTestWidgets('dialog ไม่บันทึกถ้าไม่กรอกชื่อ', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminSkillsScreen());

      await tester.tap(find.text('เพิ่ม Skill ใหม่'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(backend.requests, isNot(contains('POST admin/skill')));
    });

    adminTestWidgets('แก้ไข Skill ส่ง PUT', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminSkillsScreen());

      await tester.tap(find.text('แก้ไข').first);
      await tester.pumpAndSettle();
      expect(find.text('แก้ไข Skill'), findsOneWidget);
      await tester.enterText(inDialog(find.byType(TextField)).at(1), 'Arrays 2');
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      expect(backend.bodyOf('PUT admin/skill/1')['skill_name'], 'Arrays 2');
      expect(find.text('Arrays 2'), findsOneWidget);
    });

    adminTestWidgets('ลบ Skill หลังยืนยัน', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminSkillsScreen());

      await tester.tap(find.text('ลบ').first);
      await tester.pumpAndSettle();
      expect(find.text('ต้องการลบ "Arrays" ใช่หรือไม่?'), findsOneWidget);
      await tester.tap(inDialog(find.text('ลบ')));
      await tester.pumpAndSettle();

      expect(backend.requests, contains('DELETE admin/skill/1'));
      expect(find.text('Arrays'), findsNothing);
    });

    adminTestWidgets('dialog ดูรายละเอียด', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminSkillsScreen());

      await tester.tap(find.text('ดู').last);
      await tester.pumpAndSettle();

      expect(find.text('Skill Code: STACK'), findsOneWidget);
      expect(find.text('สถานะ: Inactive'), findsOneWidget);
    });

    adminTestWidgets('แสดงเป็นการ์ดบนจอมือถือ', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminSkillsScreen(), size: mobileSize);

      expect(find.byType(DataTable), findsNothing);
      expect(find.text('เพิ่มใหม่'), findsOneWidget);
      expect(find.text('Arrays'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
    });
  });
}
