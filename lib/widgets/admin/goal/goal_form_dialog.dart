import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/goal_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';

/// Dialog "+ เพิ่ม Goal ใหม่" และ "แก้ไข Goal"
/// [onSubmit] รับ body ที่จะส่งไป backend และคืน true ถ้าบันทึกสำเร็จ (dialog จะปิดเอง)
class GoalFormDialog extends StatefulWidget {
  final GoalItemData? existingGoal;
  final List<GoalRequiredSkill> availableSkills;
  final Future<bool> Function(Map<String, dynamic> body) onSubmit;

  const GoalFormDialog({
    super.key,
    this.existingGoal,
    required this.availableSkills,
    required this.onSubmit,
  });

  @override
  State<GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends State<GoalFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final List<GoalRequiredSkill> _requiredSkills;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final goal = widget.existingGoal;
    _nameController = TextEditingController(text: goal?.name ?? '');
    _codeController = TextEditingController(text: goal?.code ?? '');
    _requiredSkills = goal != null ? List.from(goal.requiredSkills) : [];
    _isActive = goal?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _addSkill(int skillId) {
    // ป้องกันเพิ่มซ้ำ
    if (_requiredSkills.any((item) => item.skillId == skillId)) return;
    setState(() {
      _requiredSkills.add(widget.availableSkills.firstWhere((s) => s.skillId == skillId));
    });
  }

  Future<void> _save() async {
    final nameText = _nameController.text.trim();
    if (nameText.isEmpty) return;

    final saved = await widget.onSubmit({
      'goal_code': _codeController.text.trim(),
      'goal_name': nameText,
      'is_active': _isActive ? 1 : 0,
      'skill_ids': _requiredSkills.map((s) => s.skillId).toList(),
    });
    if (saved && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      title: Text(
        widget.existingGoal == null ? '+ เพิ่ม Goal ใหม่' : '✏️ แก้ไข Goal',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E3A8A),
        ),
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminLabeledField(
                label: 'ชื่อ GOAL',
                child: TextField(
                  controller: _nameController,
                  decoration: _filledDecoration('กรอกชื่อ Goal...'),
                ),
              ),
              const SizedBox(height: 18),
              AdminLabeledField(
                label: 'รหัส GOAL',
                child: TextField(
                  controller: _codeController,
                  decoration: _filledDecoration('เช่น GOAL_DSA'),
                ),
              ),
              const SizedBox(height: 18),
              const AdminFieldLabel('SKILL ที่ต้องใช้'),
              const SizedBox(height: 8),
              _SkillPicker(skills: widget.availableSkills, onAdd: _addSkill),
              const SizedBox(height: 12),
              _SelectedSkillChips(
                skills: _requiredSkills,
                onRemove: (skill) => setState(() => _requiredSkills.remove(skill)),
              ),
              const SizedBox(height: 16),
              AdminActiveSwitchField(
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF334155),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0256B8),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _save,
          child: const Text('บันทึก', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  InputDecoration _filledDecoration(String hint) {
    return adminInputDecoration(hint: hint).copyWith(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}

/// Dropdown เลือก Skill + ปุ่ม "+ เพิ่ม"
class _SkillPicker extends StatefulWidget {
  final List<GoalRequiredSkill> skills;
  final ValueChanged<int> onAdd;

  const _SkillPicker({required this.skills, required this.onAdd});

  @override
  State<_SkillPicker> createState() => _SkillPickerState();
}

class _SkillPickerState extends State<_SkillPicker> {
  int? _selectedSkillId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AdminDropdownField<int>(
            value: _selectedSkillId,
            hint: '-- เลือก Skill --',
            items: widget.skills.map((s) => s.skillId).toList(),
            displayLabel: (id) => widget.skills.firstWhere((s) => s.skillId == id).skillName,
            onChanged: (val) => setState(() => _selectedSkillId = val),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0256B8),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            if (_selectedSkillId != null) widget.onAdd(_selectedSkillId!);
          },
          child: const Text(
            '+ เพิ่ม',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

/// Chip ของ Skill ที่เลือกแล้ว (กด x เพื่อเอาออก)
class _SelectedSkillChips extends StatelessWidget {
  final List<GoalRequiredSkill> skills;
  final ValueChanged<GoalRequiredSkill> onRemove;

  const _SelectedSkillChips({required this.skills, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '— ยังไม่ได้เลือก Skill —',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Chip(
          backgroundColor: const Color(0xFFEFF6FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFBFDBFE)),
          ),
          label: Text(
            skill.skillName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          deleteIcon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFEF4444)),
          onDeleted: () => onRemove(skill),
        );
      }).toList(),
    );
  }
}
