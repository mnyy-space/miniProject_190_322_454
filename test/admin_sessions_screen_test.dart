import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halalsefllearning/screens/admin/admin_sessions_screen.dart';

import 'helpers/fake_backend.dart';

void main() {
  group('AdminSessionsScreen', () {
    adminTestWidgets('โหลด Session พร้อม Skill และ Exercise', (
      tester,
      backend,
    ) async {
      await pumpAdminScreen(tester, const AdminSessionsScreen());

      expect(
        backend.requests,
        containsAll([
          'GET admin/session',
          'GET admin/skill',
          'GET admin/exercise',
        ]),
      );
      expect(find.text('Session ทั้งหมด 1 รายการ'), findsOneWidget);
      expect(find.text('Array เบื้องต้น'), findsOneWidget);
      expect(find.text('Arrays'), findsOneWidget);
    });

    adminTestWidgets('เพิ่ม Session ที่ผูก Skill และหลาย Exercise', (
      tester,
      backend,
    ) async {
      await pumpAdminScreen(tester, const AdminSessionsScreen());

      await tester.tap(find.text('เพิ่ม Session ใหม่'));
      await tester.pumpAndSettle();
      await tester.enterText(
        inDialog(find.byType(TextField)),
        'Array practice',
      );
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arrays').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('ดึงค่าตัวสุดท้ายออกจาก list'));
      await tester.tap(find.text('เพิ่มค่าเข้า list'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      final body = backend.bodyOf('POST admin/session');
      expect(body['session_name'], 'Array practice');
      expect(body['skill_id'], 1);
      expect(body['exercise_ids'], containsAll([10, 12]));
      expect(find.text('Session ทั้งหมด 2 รายการ'), findsOneWidget);
    });
  });
}
