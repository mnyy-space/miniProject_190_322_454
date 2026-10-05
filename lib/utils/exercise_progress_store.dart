import 'dart:convert';
import 'package:halalsefllearning/utils/skill_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// แบบฝึกหัดที่ทำค้างไว้ 1 Session
class ExerciseProgress {
  final int sessionId;
  final Map<int, bool> answers; // exercise_id -> ตอบถูกหรือไม่
  final String sessionName;
  final String skillName;
  final String skillIcon;
  final int totalQuestions;
  final DateTime? updatedAt;

  const ExerciseProgress({
    required this.sessionId,
    required this.answers,
    this.sessionName = '',
    this.skillName = '',
    this.skillIcon = defaultSkillIconName,
    this.totalQuestions = 0,
    this.updatedAt,
  });
}

/// เก็บความคืบหน้าแบบฝึกหัดที่ทำค้างไว้ในเครื่อง (แยกตามผู้ใช้ + Session)
/// เก็บเป็น exercise_id -> ตอบถูกหรือไม่ แทนเลขข้อ
/// เพื่อให้ทำต่อได้ถูกต้องแม้ admin จะเพิ่ม/ลบข้อใน Session ภายหลัง
class ExerciseProgressStore {
  static String _prefix(SharedPreferences prefs) =>
      'exercise_progress_${prefs.getString('username') ?? ''}_';

  static ExerciseProgress? _decode(int sessionId, String? raw) {
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      // รูปแบบเดิม: { "<exercise_id>": true/false } ไม่มีข้อมูล Session
      final bool isLegacy = !decoded.containsKey('answers');
      final rawAnswers = (isLegacy ? decoded : decoded['answers']) as Map<String, dynamic>;
      final answers = rawAnswers.map((id, correct) => MapEntry(int.parse(id), correct == true));
      if (answers.isEmpty) return null;
      if (isLegacy) return ExerciseProgress(sessionId: sessionId, answers: answers);
      return ExerciseProgress(
        sessionId: sessionId,
        answers: answers,
        sessionName: decoded['session_name'] as String? ?? '',
        skillName: decoded['skill_name'] as String? ?? '',
        skillIcon: decoded['skill_icon'] as String? ?? defaultSkillIconName,
        totalQuestions: (decoded['total_questions'] as num?)?.toInt() ?? 0,
        updatedAt: DateTime.tryParse(decoded['updated_at'] as String? ?? ''),
      );
    } catch (_) {
      return null;
    }
  }

  /// คำตอบที่บันทึกไว้ของ Session (ว่าง = ไม่มีงานค้าง)
  static Future<Map<int, bool>> load(int sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    return _decode(sessionId, prefs.getString('${_prefix(prefs)}$sessionId'))?.answers ?? {};
  }

  /// งานค้างทั้งหมดของผู้ใช้ปัจจุบัน เรียงจากที่ทำล่าสุดก่อน
  static Future<List<ExerciseProgress>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _prefix(prefs);
    final List<ExerciseProgress> result = [];
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(prefix)) continue;
      final sessionId = int.tryParse(key.substring(prefix.length));
      if (sessionId == null) continue;
      final progress = _decode(sessionId, prefs.getString(key));
      if (progress != null) result.add(progress);
    }
    result.sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
    return result;
  }

  /// บันทึกคำตอบทั้งหมดของ Session (ส่ง map ว่างเพื่อล้างงานค้าง)
  /// ข้อมูล Session / Skill ใช้แสดงรายการ "กำลังทำ" ในหน้าประวัติ
  static Future<void> save(
    int sessionId,
    Map<int, bool> answers, {
    String sessionName = '',
    String skillName = '',
    String skillIcon = defaultSkillIconName,
    int totalQuestions = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_prefix(prefs)}$sessionId';
    if (answers.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(
      key,
      jsonEncode({
        'answers': answers.map((id, correct) => MapEntry(id.toString(), correct)),
        'session_name': sessionName,
        'skill_name': skillName,
        'skill_icon': skillIcon,
        'total_questions': totalQuestions,
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );
  }

  static Future<void> clear(int sessionId) => save(sessionId, {});
}
