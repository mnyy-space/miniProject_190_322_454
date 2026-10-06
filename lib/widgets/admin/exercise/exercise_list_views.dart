import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/exercise_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_list_widgets.dart';

/// callback ของแต่ละแถว Exercise ที่ทั้งตารางและการ์ดใช้ร่วมกัน
class ExerciseRowCallbacks {
  final void Function(ExerciseItemData exercise) onView;
  final void Function(ExerciseItemData exercise) onEdit;
  final void Function(ExerciseItemData exercise) onDelete;
  final void Function(ExerciseItemData exercise, bool isActive) onStatusChanged;

  const ExerciseRowCallbacks({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });
}

/// ตาราง Exercise บน Desktop
class ExerciseDataTable extends StatelessWidget {
  final List<ExerciseItemData> exercises;
  final ExerciseRowCallbacks callbacks;

  const ExerciseDataTable({super.key, required this.exercises, required this.callbacks});

  static const TextStyle _cellStyle = TextStyle(fontSize: 13, color: Color(0xFF1E293B));

  @override
  Widget build(BuildContext context) {
    return AdminTableCard(
      columns: const [
        DataColumn(label: Text('คำอธิบายโจทย์')),
        DataColumn(label: Text('Skill')),
        DataColumn(label: Text('Level')),
        DataColumn(label: Text('ประเภท')),
        DataColumn(label: Text('Actions')),
        DataColumn(label: Text('สถานะ')),
      ],
      rows: exercises.map(_buildRow).toList(),
    );
  }

  DataRow _buildRow(ExerciseItemData exercise) {
    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              exercise.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _cellStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        DataCell(Text(exercise.skill, style: _cellStyle)),
        DataCell(Text(exercise.level.toString(), style: _cellStyle)),
        DataCell(AdminTag(exercise.type)),
        DataCell(
          AdminRowActions(
            onView: () => callbacks.onView(exercise),
            onEdit: () => callbacks.onEdit(exercise),
            onDelete: () => callbacks.onDelete(exercise),
          ),
        ),
        DataCell(
          AdminStatusSwitch(
            value: exercise.isActive,
            onChanged: (val) => callbacks.onStatusChanged(exercise, val),
          ),
        ),
      ],
    );
  }
}

/// การ์ด Exercise 1 รายการบน Mobile
class ExerciseMobileCard extends StatelessWidget {
  final ExerciseItemData exercise;
  final ExerciseRowCallbacks callbacks;

  const ExerciseMobileCard({super.key, required this.exercise, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                exercise.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            AdminStatusSwitch(
              value: exercise.isActive,
              showLabel: false,
              onChanged: (val) => callbacks.onStatusChanged(exercise, val),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Flexible(child: AdminTag(exercise.skill, tone: AdminTagTone.blue, dense: true)),
            const SizedBox(width: 8),
            Flexible(child: AdminTag(exercise.type, dense: true)),
            const SizedBox(width: 8),
            Text(
              'Lv.${exercise.level}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF2563EB)),
              onPressed: () => callbacks.onEdit(exercise),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
              tooltip: 'ลบ',
              onPressed: () => callbacks.onDelete(exercise),
            ),
          ],
        ),
      ],
    );
  }
}
