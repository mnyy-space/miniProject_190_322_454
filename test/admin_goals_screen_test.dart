import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halalsefllearning/screens/admin/admin_goals_screen.dart';

import 'helpers/fake_backend.dart';

void main() {
  group('AdminGoalsScreen', () {
    adminTestWidgets('โหลด Goal พร้อม Skill ที่ต้องใช้', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminGoalsScreen());

      expect(backend.requests, containsAll(['GET admin/goal', 'GET admin/skill']));
      expect(find.text('Goal ทั้งหมด 1 รายการ'), findsOneWidget);
      expect(find.text('Data Structures'), findsOneWidget);
      expect(find.text('Arrays'), findsOneWidget);
      expect(find.text('Stack & Queue'), findsOneWidget);
    });

    adminTestWidgets('ค้นหาด้วยชื่อ Skill ได้', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminGoalsScreen());

      await tester.enterText(find.byType(TextField).first, 'queue');
      await tester.pumpAndSettle();
      expect(find.text('Data Structures'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'ไม่มีแน่นอน');
      await tester.pumpAndSettle();
      expect(find.text('Data Structures'), findsNothing);
    });

    adminTestWidgets('dialog รายละเอียดแสดงข้อมูลและ Learning Tree', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminGoalsScreen());

      await tester.tap(find.text('ดู'));
      await tester.pumpAndSettle();

      expect(find.text('รายละเอียด Goal'), findsOneWidget);
      expect(find.text('GOAL_DSA'), findsOneWidget);
      expect(find.text('LEARNING TREE'), findsOneWidget);
      expect(find.text('active'), findsOneWidget);
      // skill แสดงทั้งใน tag และใน learning tree
      expect(inDialog(find.text('Arrays')), findsNWidgets(2));

      // ปุ่ม "แก้ไข" ใน dialog เปิดฟอร์มแก้ไข
      await tester.tap(inDialog(find.text('แก้ไข')));
      await tester.pumpAndSettle();
      expect(find.text('✏️ แก้ไข Goal'), findsOneWidget);
    });

    adminTestWidgets('แก้ไข Goal: เพิ่ม/ลบ Skill แล้วส่ง PUT พร้อม skill_ids', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminGoalsScreen());

      await tester.tap(find.text('แก้ไข'));
      await tester.pumpAndSettle();
      expect(find.text('✏️ แก้ไข Goal'), findsOneWidget);

      // ลบ chip "Stack & Queue"
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();
      expect(inDialog(find.text('Stack & Queue')), findsNothing);

      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      final putBody = backend.bodyOf('PUT admin/goal/1');
      expect(putBody['skill_ids'], [1]);
      expect(putBody['goal_name'], 'Data Structures');
      expect(putBody['goal_code'], 'GOAL_DSA');
    });

    adminTestWidgets('เพิ่ม Goal ใหม่พร้อมเลือก Skill จาก dropdown', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminGoalsScreen());

      await tester.tap(find.text('เพิ่ม Goal ใหม่'));
      await tester.pumpAndSettle();
      expect(find.text('— ยังไม่ได้เลือก Skill —'), findsOneWidget);

      await tester.enterText(inDialog(find.byType(TextField)).at(0), 'Algorithms');
      await tester.tap(find.text('-- เลือก Skill --'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stack & Queue').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('+ เพิ่ม'));
      await tester.pumpAndSettle();
      // กดซ้ำต้องไม่เพิ่มซ้ำ
      await tester.tap(find.text('+ เพิ่ม'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsOneWidget);

      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      expect(backend.bodyOf('POST admin/goal')['skill_ids'], [2]);
      expect(find.text('Goal ทั้งหมด 2 รายการ'), findsOneWidget);
    });

    adminTestWidgets('ลบ Goal หลังยืนยัน', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminGoalsScreen());

      await tester.tap(find.text('ลบ'));
      await tester.pumpAndSettle();
      await tester.tap(inDialog(find.text('ลบ')));
      await tester.pumpAndSettle();

      expect(backend.requests, contains('DELETE admin/goal/1'));
      expect(find.text('Goal ทั้งหมด 0 รายการ'), findsOneWidget);
    });

    adminTestWidgets('แสดงเป็นการ์ดบนจอมือถือ', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminGoalsScreen(), size: mobileSize);

      expect(find.byType(DataTable), findsNothing);
      expect(find.text('Data Structures'), findsOneWidget);
      expect(find.text('GOAL_DSA'), findsOneWidget);
    });
  });
}
