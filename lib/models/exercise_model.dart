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
      text: json['choice_script'] ?? '',
      isCorrect: json['isAnswer'] == 1 || json['is_correct'] == true,
    );
  }
}

class ExerciseQuestion {
  final int id;
  final String skillName;
  final int level;
  final String questionText;
  final String? codeSnippet;
  final String codeLanguage;
  final List<ExerciseChoice> choices; // ตัวเลือก 4 ข้อ

  ExerciseQuestion({
    required this.id,
    required this.skillName,
    this.level = 2,
    required this.questionText,
    this.codeSnippet,
    this.codeLanguage = 'PYTHON',
    required this.choices,
  });
}
