import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halalsefllearning/screens/admin/admin_exercises_screen.dart';

import 'helpers/fake_backend.dart';

void main() {
  group('AdminExercisesScreen', () {
    adminTestWidgets('โหลด Exercise และแยกประเภทจากจำนวน choice', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminExercisesScreen());

      expect(backend.requests, containsAll(['GET admin/exercise', 'GET admin/skill']));
      expect(find.text('Exercise ทั้งหมด 2 รายการ'), findsOneWidget);
      expect(find.text('ดึงค่าตัวสุดท้ายออกจาก list'), findsOneWidget);
      expect(find.text('FILL_IN_BLANK'), findsOneWidget);
      expect(find.text('CHOICE'), findsOneWidget);
    });

    adminTestWidgets('กรองตามประเภทโจทย์และ Skill', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminExercisesScreen());

      await tester.tap(find.text('ทุกประเภท'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CHOICE').last);
      await tester.pumpAndSettle();
      expect(find.text('Stack ทำงานแบบใด'), findsOneWidget);
      expect(find.text('ดึงค่าตัวสุดท้ายออกจาก list'), findsNothing);

      await tester.tap(find.text('ทุก Skill'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arrays').last);
      await tester.pumpAndSettle();
      expect(find.text('Stack ทำงานแบบใด'), findsNothing);
    });

    adminTestWidgets('dialog รายละเอียดแสดงคำตอบของ FILL_IN_BLANK', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminExercisesScreen());

      await tester.tap(find.text('ดู').first);
      await tester.pumpAndSettle();

      expect(find.text('รายละเอียด Exercise'), findsOneWidget);
      expect(find.text('คำตอบที่ถูกต้อง: pop()'), findsOneWidget);
    });

    adminTestWidgets('แก้ไข CHOICE แล้วส่ง PUT โดยคง choice_id เดิม', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminExercisesScreen());

      await tester.tap(find.text('แก้ไข').last);
      await tester.pumpAndSettle();
      expect(find.text('แก้ไข Exercise'), findsOneWidget);

      // โค้ดประกอบโจทย์ -> พรีวิวต้องอัปเดต
      await tester.enterText(inDialog(find.byType(TextField)).at(1), 'stack.____');
      await tester.pumpAndSettle();
      expect(find.textContaining('stack.____', findRichText: true), findsWidgets);

      await tester.ensureVisible(find.text('บันทึก'));
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      final body = backend.bodyOf('PUT admin/exercise/11');
      expect(body['skill_id'], 2);
      expect(body['choices'], [
        {'choice_id': 200, 'choice_script': 'FIFO', 'isAnswer': false},
        {'choice_id': 201, 'choice_script': 'LIFO', 'isAnswer': true},
      ]);
      // สถานะไม่ได้เปลี่ยน จึงไม่ต้องส่ง PATCH
      expect(backend.requests, isNot(contains('PATCH admin/exercise/11/status')));
    });

    adminTestWidgets('เพิ่ม CHOICE ใหม่แบบ inactive ส่ง POST แล้ว PATCH สถานะ', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminExercisesScreen());

      await tester.tap(find.text('เพิ่ม Exercise ใหม่'));
      await tester.pumpAndSettle();
      final fields = inDialog(find.byType(TextField));
      await tester.enterText(fields.at(0), 'เติมคำสั่งลบตัวแรก');
      await tester.ensureVisible(find.text('active'));
      await tester.tap(find.text('active'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('inactive').last);
      await tester.pumpAndSettle();
      // กรอกตัวเลือก CHOICE (index 0: desc, 1: code, 2: level, 3..6: choices)
      await tester.enterText(fields.at(3), 'pop(0)');
      await tester.enterText(fields.at(4), 'pop()');
      await tester.enterText(fields.at(5), 'remove()');
      await tester.enterText(fields.at(6), 'del');
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      expect(backend.bodyOf('POST admin/exercise'), {
        'exercise_script': 'เติมคำสั่งลบตัวแรก',
        'skill_id': 1,
        'choices': [
          {'choice_script': 'pop(0)', 'isAnswer': true},
          {'choice_script': 'pop()', 'isAnswer': false},
          {'choice_script': 'remove()', 'isAnswer': false},
          {'choice_script': 'del', 'isAnswer': false},
        ],
      });
      expect(backend.bodyOf('PATCH admin/exercise/1002/status'), {'is_active': 0});
      expect(find.text('Exercise ทั้งหมด 3 รายการ'), findsOneWidget);
    });

    adminTestWidgets('dialog เพิ่มใหม่ไม่ยอมบันทึกถ้าไม่กรอกคำอธิบาย', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminExercisesScreen());

      await tester.tap(find.text('เพิ่ม Exercise ใหม่'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      expect(find.text('กรุณากรอกคำอธิบายโจทย์'), findsOneWidget);
      expect(backend.requests, isNot(contains('POST admin/exercise')));
    });

    adminTestWidgets('แสดงเป็นการ์ดบนจอมือถือ', (tester, backend) async {
      await pumpAdminScreen(tester, const AdminExercisesScreen(), size: mobileSize);

      expect(find.byType(DataTable), findsNothing);
      expect(find.text('Lv.1'), findsNWidgets(2));
      expect(find.text('เพิ่มใหม่'), findsOneWidget);
    });
  });
}
