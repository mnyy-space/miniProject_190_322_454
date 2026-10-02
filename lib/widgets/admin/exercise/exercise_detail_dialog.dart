import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/exercise_item_data.dart';

/// Dialog แสดงรายละเอียด Exercise
class ExerciseDetailDialog extends StatelessWidget {
  final ExerciseItemData exercise;

  const ExerciseDetailDialog({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('รายละเอียด Exercise', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.description),
            const SizedBox(height: 10),
            Text('Skill: ${exercise.skill}'),
            const SizedBox(height: 6),
            Text('Level: ${exercise.level}'),
            const SizedBox(height: 6),
            Text('ประเภท: ${exercise.type}'),
            if (exercise.type == 'FILL_IN_BLANK') ...[
              const SizedBox(height: 6),
              Text('คำตอบที่ถูกต้อง: ${exercise.correctAnswer}'),
            ],
            const SizedBox(height: 6),
            Text('สถานะ: ${exercise.isActive ? "Active" : "Inactive"}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ปิด'),
        ),
      ],
    );
  }
}
