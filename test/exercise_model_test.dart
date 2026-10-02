import 'package:flutter_test/flutter_test.dart';
import 'package:halalsefllearning/models/admin/exercise_item_data.dart';

void main() {
  group('ExerciseItemData', () {
    test('fromJson: choice เดียวถือเป็น FILL_IN_BLANK', () {
      final e = ExerciseItemData.fromJson({
        'exercise_id': 5,
        'exercise_script': 'desc',
        'skill_id': 3,
        'skill_name': 'Arrays',
        'is_active': '1',
        'choices': [
          {'choice_id': 9, 'choice_script': 'pop()', 'isAnswer': 1},
        ],
      });

      expect(e.type, 'FILL_IN_BLANK');
      expect(e.correctAnswer, 'pop()');
      expect(e.isActive, isTrue);
      expect(e.toRequestBody(), {
        'exercise_script': 'desc',
        'skill_id': 3,
        'choices': [
          {'choice_id': 9, 'choice_script': 'pop()', 'isAnswer': true},
        ],
      });
    });

    test('fromJson: หลาย choice ถือเป็น CHOICE และหา index ที่ถูกต้อง', () {
      final e = ExerciseItemData.fromJson({
        'exercise_id': 6,
        'exercise_script': 'q',
        'skill_id': 1,
        'skill_name': 'S',
        'is_active': 0,
        'choices': [
          {'choice_id': 1, 'choice_script': 'A', 'isAnswer': 0},
          {'choice_id': 2, 'choice_script': 'B', 'isAnswer': true},
        ],
      });

      expect(e.type, 'CHOICE');
      expect(e.correctChoiceIndex, 1);
      expect(e.isActive, isFalse);
    });

    test('toRequestBody: choice ใหม่ไม่ส่ง choice_id', () {
      final e = ExerciseItemData(
        id: 1,
        description: 'd',
        level: 1,
        skillId: 2,
        skill: 'S',
        type: 'CHOICE',
        choices: ['x', 'y'],
        choiceIds: [null, null],
        correctChoiceIndex: 0,
        isActive: true,
      );

      expect(e.toRequestBody()['choices'], [
        {'choice_script': 'x', 'isAnswer': true},
        {'choice_script': 'y', 'isAnswer': false},
      ]);
    });
  });
}
