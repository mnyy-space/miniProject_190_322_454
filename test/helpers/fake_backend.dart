import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Backend ปลอมแบบ in-memory สำหรับ widget test ของหน้า Admin
/// รองรับ admin/skill, admin/goal, admin/exercise ตามรูปแบบ { isError, data }
class FakeBackend {
  final List<Map<String, dynamic>> skills = [
    {
      'skill_id': 1,
      'skill_code': 'ARRAYS',
      'skill_name': 'Arrays',
      'is_active': 1,
    },
    {
      'skill_id': 2,
      'skill_code': 'STACK',
      'skill_name': 'Stack & Queue',
      'is_active': 0,
    },
  ];

  final List<Map<String, dynamic>> goals = [
    {
      'goal_id': 1,
      'goal_code': 'GOAL_DSA',
      'goal_name': 'Data Structures',
      'is_active': 1,
      'skills': [
        {'skill_id': 1, 'skill_name': 'Arrays'},
        {'skill_id': 2, 'skill_name': 'Stack & Queue'},
      ],
    },
  ];

  final List<Map<String, dynamic>> exercises = [
    {
      'exercise_id': 10,
      'exercise_script': 'ดึงค่าตัวสุดท้ายออกจาก list',
      'skill_id': 1,
      'skill_name': 'Arrays',
      'is_active': 1,
      'choices': [
        {'choice_id': 100, 'choice_script': 'pop()', 'isAnswer': 1},
      ],
    },
    {
      'exercise_id': 11,
      'exercise_script': 'Stack ทำงานแบบใด',
      'skill_id': 2,
      'skill_name': 'Stack & Queue',
      'is_active': 0,
      'choices': [
        {'choice_id': 200, 'choice_script': 'FIFO', 'isAnswer': 0},
        {'choice_id': 201, 'choice_script': 'LIFO', 'isAnswer': 1},
      ],
    },
    {
      'exercise_id': 12,
      'exercise_script': 'เพิ่มค่าเข้า list',
      'skill_id': 1,
      'skill_name': 'Arrays',
      'is_active': 1,
      'choices': [
        {'choice_id': 202, 'choice_script': 'append()', 'isAnswer': 1},
      ],
    },
  ];

  final List<Map<String, dynamic>> sessions = [
    {
      'session_id': 5,
      'session_name': 'Array เบื้องต้น',
      'skill_id': 1,
      'skill_name': 'Arrays',
      'exercise_ids': [10],
      'exercise_names': ['ดึงค่าตัวสุดท้ายออกจาก list'],
    },
  ];

  final List<Map<String, dynamic>> users = [
    {
      'user_id': 1,
      'username': 'admin',
      'full_name': 'System Administrator',
      'email': 'admin@example.com',
      'role_id': 2,
      'role_name': 'admin',
      'learning_content': 'Arrays (Array เบื้องต้น)',
      'create_date': '2026-10-03 16:41:14',
    },
    {
      'user_id': 4,
      'username': 'afdol',
      'full_name': 'Afdol User',
      'email': 'afdol@example.com',
      'role_id': 1,
      'role_name': 'user',
      'learning_content': 'Functions (Introduction)',
      'create_date': '2026-10-03 16:41:14',
    },
  ];

  /// บันทึกทุก request ที่เข้ามา ในรูป "METHOD path" และ body คู่กัน
  final List<String> requests = [];
  final List<Map<String, dynamic>> bodies = [];

  Map<String, dynamic> bodyOf(String request) =>
      bodies[requests.indexOf(request)];

  late final MockClient client = MockClient(_handle);

  Future<http.Response> _handle(http.Request request) async {
    final path = request.url.path.replaceFirst(RegExp(r'^/'), '');
    requests.add('${request.method} $path');
    final body = request.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(request.body) as Map<String, dynamic>;
    bodies.add(body);

    if (path == 'user/profile') {
      if (request.method == 'GET') {
        return _ok({
          'user_id': 5,
          'username': 'Murnee',
          'full_name': 'Murnee Madsakul',
          'role_name': 'user',
          'create_date': '2026-10-03 17:33:21',
        });
      }
      if (request.method == 'PUT') {
        return _ok({
          'user_id': 5,
          'full_name': body['full_name'] ?? 'Murnee Madsakul',
        });
      }
    }

    final segments = path.split('/');
    if (segments.length < 2 || segments[0] != 'admin') return _error(404);

    final resource = segments[1];
    final table = switch (resource) {
      'skill' => skills,
      'goal' => goals,
      'exercise' => exercises,
      'session' => sessions,
      'user' => users,
      _ => null,
    };
    if (table == null) return _error(404);
    final idKey = '${resource}_id';

    if (segments.length == 2) {
      if (request.method == 'GET') return _ok(table);
      if (request.method == 'POST') {
        final id = 1000 + table.length;
        table.add({...body, idKey: id, 'is_active': body['is_active'] ?? 1});
        return _ok({idKey: id});
      }
    }

    final id = int.tryParse(segments[2]);
    final index = table.indexWhere((row) => row[idKey] == id);
    if (index < 0) return _error(404);

    if (segments.length == 4 &&
        segments[3] == 'status' &&
        request.method == 'PATCH') {
      table[index]['is_active'] = body['is_active'];
      return _ok(null);
    }
    if (request.method == 'PUT') {
      table[index] = {...table[index], ...body};
      return _ok(null);
    }
    if (request.method == 'DELETE') {
      table.removeAt(index);
      return _ok(null);
    }
    return _error(405);
  }

  http.Response _ok(dynamic data) => http.Response(
    jsonEncode({'isError': false, 'data': data}),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  http.Response _error(int status) => http.Response(
    jsonEncode({'isError': true, 'errorMessage': 'HTTP $status'}),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

const Size desktopSize = Size(1400, 1000);
const Size mobileSize = Size(420, 1600);

/// testWidgets ที่รันทั้ง test ภายใต้ http client ปลอม
/// (ทุก request ของ AppApi จะวิ่งเข้า [FakeBackend] แทน network จริง)
void adminTestWidgets(
  String description,
  Future<void> Function(WidgetTester tester, FakeBackend backend) body,
) {
  testWidgets(description, (tester) async {
    final backend = FakeBackend();
    await http.runWithClient(() => body(tester, backend), () => backend.client);
  });
}

/// pump หน้าจอด้วยขนาดหน้าจอที่กำหนด แล้วรอจนโหลดข้อมูลเสร็จ
Future<void> pumpAdminScreen(
  WidgetTester tester,
  Widget screen, {
  Size size = desktopSize,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    screen is MaterialApp ? screen : MaterialApp(home: screen),
  );
  await tester.pumpAndSettle();
}

/// หา widget ที่อยู่ภายใน dialog ที่เปิดอยู่ (ไม่รวม widget ของหน้าด้านหลัง)
Finder inDialog(Finder matching) => find.descendant(
  of: find.byWidgetPredicate((w) => w is Dialog || w is AlertDialog),
  matching: matching,
);
