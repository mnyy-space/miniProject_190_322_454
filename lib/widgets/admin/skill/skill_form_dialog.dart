import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/skill_item_data.dart';
import 'package:halalsefllearning/utils/skill_icons.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';
import 'package:halalsefllearning/widgets/admin/skill/skill_icon_picker.dart';

/// Dialog เพิ่ม / แก้ไข Skill
/// [onSubmit] รับ body ที่จะส่งไป backend และคืน true ถ้าบันทึกสำเร็จ (dialog จะปิดเอง)
class SkillFormDialog extends StatefulWidget {
  final SkillItemData? existingSkill;
  final Future<bool> Function(Map<String, dynamic> body) onSubmit;

  const SkillFormDialog({
    super.key,
    this.existingSkill,
    required this.onSubmit,
  });

  @override
  State<SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends State<SkillFormDialog> {
  static const List<String> _tiers = ['Basic', 'Intermediate', 'Advanced'];

  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late String _selectedTier;
  late String _selectedIcon;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final skill = widget.existingSkill;
    _codeController = TextEditingController(text: skill?.code ?? '');
    _nameController = TextEditingController(text: skill?.name ?? '');
    _selectedTier = skill?.tier ?? 'Basic';
    _selectedIcon = skill?.icon ?? defaultSkillIconName;
    _isActive = skill?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nameText = _nameController.text.trim();
    final codeText = _codeController.text.trim();
    if (nameText.isEmpty) return;

    final saved = await widget.onSubmit({
      'skill_code': codeText.isEmpty ? nameText.toUpperCase() : codeText,
      'skill_name': nameText,
      'skill_icon': _selectedIcon,
      'is_active': _isActive ? 1 : 0,
    });
    if (saved && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              skillIconOf(_selectedIcon),
              color: const Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              widget.existingSkill == null ? 'เพิ่ม Skill ใหม่' : 'แก้ไข Skill',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminLabeledField(
                label: 'Skill Code (รหัส)',
                child: TextField(
                  controller: _codeController,
                  decoration: adminInputDecoration(
                    hint: 'เช่น ARRAYS & LINKED LISTS',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AdminLabeledField(
                label: 'Skill Name (ชื่อ Skill)',
                child: TextField(
                  controller: _nameController,
                  decoration: adminInputDecoration(
                    hint: 'เช่น Arrays & Linked Lists',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AdminLabeledField(
                label: 'Icon (ไอคอน Skill)',
                child: SkillIconPicker(
                  selected: _selectedIcon,
                  onChanged: (val) => setState(() => _selectedIcon = val),
                ),
              ),
              const SizedBox(height: 16),
              AdminLabeledField(
                label: 'Tier (ระดับ)',
                child: AdminDropdownField<String>(
                  value: _selectedTier,
                  items: _tiers,
                  onChanged: (val) => setState(() => _selectedTier = val),
                ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'ยกเลิก',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: _save,
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}
