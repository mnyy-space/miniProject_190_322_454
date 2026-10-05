import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// เก็บความคืบหน้าแบบฝึกหัดที่ทำค้างไว้ในเครื่อง (แยกตามผู้ใช้ + Session)
/// เก็บเป็น exercise_id -> ตอบถูกหรือไม่ แทนเลขข้อ
/// เพื่อให้ทำต่อได้ถูกต้องแม้ admin จะเพิ่ม/ลบข้อใน Session ภายหลัง
class ExerciseProgressStore {
  static Future<String> _key(SharedPreferences prefs, int sessionId) async {
    final username = prefs.getString('username') ?? '';
    return 'exercise_progress_${username}_$sessionId';
  }

  /// คำตอบที่บันทึกไว้ของ Session (ว่าง = ไม่มีงานค้าง)
  static Future<Map<int, bool>> load(int sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _key(prefs, sessionId));
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((id, correct) => MapEntry(int.parse(id), correct == true));
    } catch (_) {
      return {};
    }
  }

  /// บันทึกคำตอบทั้งหมดของ Session (ส่ง map ว่างเพื่อล้างงานค้าง)
  static Future<void> save(int sessionId, Map<int, bool> answers) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _key(prefs, sessionId);
    if (answers.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(
      key,
      jsonEncode(answers.map((id, correct) => MapEntry(id.toString(), correct))),
    );
  }

  static Future<void> clear(int sessionId) => save(sessionId, {});
}
