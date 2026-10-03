import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/exercise_item_data.dart';
import 'package:halalsefllearning/models/admin/session_item_data.dart';
import 'package:halalsefllearning/models/admin/skill_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';

class SessionFormDialog extends StatefulWidget {
  final SessionItemData? existingSession;
  final List<SkillItemData> skills;
  final List<ExerciseItemData> exercises;
  final Future<bool> Function(Map<String, dynamic> body) onSubmit;

  const SessionFormDialog({
    super.key,
    this.existingSession,
    required this.skills,
    required this.exercises,
    required this.onSubmit,
  });

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  late final TextEditingController _nameController;
  late int? _selectedSkillId;
  late final Set<int> _selectedExerciseIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingSession?.name ?? '',
    );
    _selectedSkillId = widget.existingSession?.skillId;
    _selectedExerciseIds = {...?widget.existingSession?.exerciseIds};
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<ExerciseItemData> get _availableExercises => widget.exercises
      .where((exercise) => exercise.skillId == _selectedSkillId)
      .toList();

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedSkillId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อ Session และเลือก Skill')),
      );
      return;
    }

    final saved = await widget.onSubmit({
      'session_name': name,
      'skill_id': _selectedSkillId,
      'exercise_ids': _selectedExerciseIds.toList(),
    });
    if (saved && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existingSession == null
        ? 'เพิ่ม Session'
        : 'แก้ไข Session';
    final skillIds = widget.skills.map((skill) => skill.id).toSet();
    final skillValue = skillIds.contains(_selectedSkillId)
        ? _selectedSkillId
        : null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'ปิด',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdminFieldLabel('ชื่อ Session'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      decoration: adminInputDecoration(
                        hint: 'เช่น พื้นฐาน Array',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const AdminFieldLabel('Skill'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: skillValue,
                      decoration: adminInputDecoration(hint: 'เลือก Skill'),
                      items: widget.skills
                          .map(
                            (skill) => DropdownMenuItem(
                              value: skill.id,
                              child: Text(
                                skill.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (id) {
                        if (id == null) return;
                        setState(() {
                          _selectedSkillId = id;
                          _selectedExerciseIds.removeWhere(
                            (exerciseId) => !widget.exercises.any(
                              (exercise) =>
                                  exercise.id == exerciseId &&
                                  exercise.skillId == id,
                            ),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const AdminFieldLabel('Exercise ใน Session'),
                    const SizedBox(height: 8),
                    if (_selectedSkillId == null)
                      const Text('เลือก Skill เพื่อแสดง Exercise')
                    else if (_availableExercises.isEmpty)
                      const Text('ยังไม่มี Exercise สำหรับ Skill นี้')
                    else
                      ..._availableExercises.map(
                        (exercise) => CheckboxListTile(
                          value: _selectedExerciseIds.contains(exercise.id),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(exercise.description),
                          subtitle: Text(exercise.type),
                          onChanged: (selected) => setState(() {
                            if (selected == true) {
                              _selectedExerciseIds.add(exercise.id);
                            } else {
                              _selectedExerciseIds.remove(exercise.id);
                            }
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('บันทึก'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
