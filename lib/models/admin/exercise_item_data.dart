import 'package:halalsefllearning/models/admin/skill_item_data.dart';

class ExerciseItemData {
  int id;
  String description;
  String codeSnippet; // โค้ดประกอบโจทย์ (ไม่บังคับ) อาจมี ____ เป็นช่องว่าง
  String language; // ภาษาของโค้ด เช่น Python
  int level;
  int skillId;
  String skill;
  int expectedTime; // เวลาที่คาดหวัง
  String timeUnit; // หน่วยเวลา เช่น นาที (minute)
  String type; // CHOICE หรือ FILL_IN_BLANK
  String correctAnswer; // คำตอบที่ถูกต้อง (สำหรับ FILL_IN_BLANK)
  bool caseSensitive; // ตรวจตัวพิมพ์เล็ก/ใหญ่
  List<String> choices; // ตัวเลือก (สำหรับ CHOICE)
  List<int?> choiceIds; // choice_id ใน DB ของแต่ละตัวเลือก (null = ยังไม่ได้บันทึก)
  int correctChoiceIndex; // index ของตัวเลือกที่ถูกต้อง (สำหรับ CHOICE)
  bool isActive;

  ExerciseItemData({
    required this.id,
    required this.description,
    this.codeSnippet = '',
    this.language = 'Python',
    required this.level,
    this.skillId = 0,
    required this.skill,
    this.expectedTime = 3,
    this.timeUnit = 'นาที (minute)',
    required this.type,
    this.correctAnswer = '',
    this.caseSensitive = false,
    List<String>? choices,
    List<int?>? choiceIds,
    this.correctChoiceIndex = 0,
    required this.isActive,
  })  : choices = choices ?? [],
        choiceIds = choiceIds ?? [];

  // แปลงข้อมูลจาก GET admin/exercise
  // FILL_IN_BLANK เก็บเป็น choice เดียวที่ isAnswer = 1, CHOICE คือมีหลายตัวเลือก
  factory ExerciseItemData.fromJson(Map<String, dynamic> item) {
    final List rawChoices = item['choices'] ?? [];
    final choiceTexts = rawChoices.map((c) => (c['choice_script'] ?? '').toString()).toList();
    final choiceIds = rawChoices.map<int?>((c) => c['choice_id']).toList();
    final correctIndex = rawChoices.indexWhere((c) => c['isAnswer'] == 1 || c['isAnswer'] == true);
    final isFillInBlank = rawChoices.length == 1;

    return ExerciseItemData(
      id: item['exercise_id'] ?? 0,
      description: (item['exercise_script'] ?? '').toString(),
      level: 1,
      skillId: item['skill_id'] ?? 0,
      skill: (item['skill_name'] ?? '').toString(),
      type: isFillInBlank ? 'FILL_IN_BLANK' : 'CHOICE',
      correctAnswer: isFillInBlank ? choiceTexts.first : '',
      choices: choiceTexts,
      choiceIds: choiceIds,
      correctChoiceIndex: correctIndex < 0 ? 0 : correctIndex,
      isActive: parseIsActive(item['is_active']),
    );
  }

  // สร้าง body สำหรับ POST / PUT admin/exercise
  Map<String, dynamic> toRequestBody() {
    final List<Map<String, dynamic>> choiceBody = [];
    if (type == 'FILL_IN_BLANK') {
      choiceBody.add({
        if (choiceIds.isNotEmpty && choiceIds.first != null) 'choice_id': choiceIds.first,
        'choice_script': correctAnswer,
        'isAnswer': true,
      });
    } else {
      for (int i = 0; i < choices.length; i++) {
        choiceBody.add({
          if (i < choiceIds.length && choiceIds[i] != null) 'choice_id': choiceIds[i],
          'choice_script': choices[i],
          'isAnswer': i == correctChoiceIndex,
        });
      }
    }
    return {
      'exercise_script': description,
      'skill_id': skillId,
      'choices': choiceBody,
    };
  }
}

class ExerciseSkillOption {
  final int id;
  final String name;
  const ExerciseSkillOption({required this.id, required this.name});

  factory ExerciseSkillOption.fromJson(Map<String, dynamic> s) {
    return ExerciseSkillOption(
      id: s['skill_id'] ?? 0,
      name: (s['skill_name'] ?? '').toString(),
    );
  }
}
