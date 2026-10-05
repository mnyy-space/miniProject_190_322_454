import 'package:halalsefllearning/utils/skill_icons.dart';

class ExerciseChoice {
  final String id;
  final String label; // "A", "B", "C", "D"
  final String text;
  final bool isCorrect;

  ExerciseChoice({
    required this.id,
    required this.label,
    required this.text,
    required this.isCorrect,
  });

  factory ExerciseChoice.fromJson(Map<String, dynamic> json, String label) {
    return ExerciseChoice(
      id: json['choice_id']?.toString() ?? '',
      label: label,
      text: (json['choice_script'] ?? '').toString(),
      isCorrect: json['isAnswer'] == 1 ||
          json['isAnswer'] == true ||
          json['is_correct'] == 1 ||
          json['is_correct'] == true,
    );
  }
}

class ExerciseQuestion {
  final int id;
  final int? sessionWithExerciseId;
  final String skillName;
  final String skillIcon;
  final int level;
  final String questionText;
  final String? codeSnippet;
  final String codeLanguage;
  final List<ExerciseChoice> choices;

  ExerciseQuestion({
    required this.id,
    this.sessionWithExerciseId,
    required this.skillName,
    this.skillIcon = defaultSkillIconName,
    this.level = 1,
    required this.questionText,
    this.codeSnippet,
    this.codeLanguage = 'PYTHON',
    required this.choices,
  });

  factory ExerciseQuestion.fromJson(
    Map<String, dynamic> json, {
    String defaultSkillName = '',
  }) {
    final String rawScript = (json['exercise_script'] ?? '').toString().trim();
    String question = rawScript;
    String? code;
    String language = 'PYTHON';

    // แยก Code Block ออกมาจาก exercise_script หากมีรูปแบบ ```python ... ``` หรือ ``` ... ```
    final codeBlockRegex = RegExp(r'```([a-zA-Z0-9_-]*)\s*([\s\S]*?)```');
    final match = codeBlockRegex.firstMatch(rawScript);
    if (match != null) {
      final matchedLang = match.group(1)?.trim();
      if (matchedLang != null && matchedLang.isNotEmpty) {
        language = matchedLang.toUpperCase();
      }
      code = match.group(2)?.trim();
      question = rawScript.replaceAll(codeBlockRegex, '').trim();
      if (question.isEmpty) {
        question = 'จงวิเคราะห์โค้ดต่อไปนี้และเลือกคำตอบที่ถูกต้อง';
      }
    }

    // ตัวอักษรระบุหน้าตัวเลือก A, B, C, D
    const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
    final List rawChoices = json['choices'] is List ? json['choices'] as List : [];
    final List<ExerciseChoice> choicesList = [];
    for (int i = 0; i < rawChoices.length; i++) {
      if (rawChoices[i] is Map<String, dynamic>) {
        final choiceMap = rawChoices[i] as Map<String, dynamic>;
        final label = i < labels.length ? labels[i] : '${i + 1}';
        choicesList.add(ExerciseChoice.fromJson(choiceMap, label));
      }
    }

    final int exId = json['exercise_id'] is int
        ? json['exercise_id'] as int
        : int.tryParse(json['exercise_id']?.toString() ?? '') ?? 0;

    final int? sweId = json['session_with_exercise_id'] is int
        ? json['session_with_exercise_id'] as int
        : int.tryParse(json['session_with_exercise_id']?.toString() ?? '');

    final String sName = (json['skill_name'] ?? defaultSkillName).toString();

    final int lvl = json['level'] is int
        ? json['level'] as int
        : int.tryParse(json['level']?.toString() ?? '') ?? 1;

    return ExerciseQuestion(
      id: exId,
      sessionWithExerciseId: sweId,
      skillName: sName.isNotEmpty ? sName : 'Exercise',
      skillIcon: (json['skill_icon'] ?? defaultSkillIconName).toString(),
      level: lvl,
      questionText: question,
      codeSnippet: code,
      codeLanguage: language,
      choices: choicesList,
    );
  }
}

class ExerciseResponse {
  final bool isError;
  final List<ExerciseQuestion> data;
  final String errorMessage;

  ExerciseResponse({
    required this.isError,
    required this.data,
    required this.errorMessage,
  });

  factory ExerciseResponse.fromJson(
    Map<String, dynamic> json, {
    String defaultSkillName = '',
  }) {
    List<ExerciseQuestion> questions = [];
    if (json['data'] != null && json['data'] is List) {
      questions = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => ExerciseQuestion.fromJson(item, defaultSkillName: defaultSkillName))
          .toList();
    }

    return ExerciseResponse(
      isError: json['isError'] as bool? ?? false,
      data: questions,
      errorMessage: json['errorMessage'] as String? ?? '',
    );
  }
}
