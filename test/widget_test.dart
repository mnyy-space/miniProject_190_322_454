import 'package:flutter_test/flutter_test.dart';
import 'package:halalsefllearning/main.dart';
import 'package:halalsefllearning/screens/admin/admin_goals_screen.dart';
import 'package:halalsefllearning/screens/admin/admin_layout.dart';
import 'package:halalsefllearning/screens/admin/admin_skills_screen.dart';

import 'helpers/fake_backend.dart';

void main() {
  adminTestWidgets('แอปเปิดขึ้นมาที่ AdminLayout และสลับเมนูได้', (tester, backend) async {
    await pumpAdminScreen(tester, const AdminLayout());

    expect(find.byType(AdminLayout), findsOneWidget);
    expect(find.byType(AdminSkillsScreen), findsOneWidget);
    expect(find.text('Arrays'), findsOneWidget);

    await tester.tap(find.text('จัดการ Goal').first);
    await tester.pumpAndSettle();
    expect(find.byType(AdminGoalsScreen), findsOneWidget);
  });
}
