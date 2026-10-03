import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:halalsefllearning/models/admin/exercise_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';
import 'package:halalsefllearning/widgets/admin/exercise/code_preview_card.dart';
import 'package:halalsefllearning/widgets/admin/exercise/exercise_form_sections.dart';

/// Dialog เพิ่ม / แก้ไข Exercise — คืนค่า [ExerciseItemData] ผ่าน Navigator.pop เมื่อกดบันทึก
class ExerciseFormDialog extends StatefulWidget {
  final ExerciseItemData? existingExercise;
  final List<ExerciseSkillOption> skillOptions;

  const ExerciseFormDialog({super.key, this.existingExercise, required this.skillOptions});

  @override
  State<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<ExerciseFormDialog> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _codeController;
  late final TextEditingController _levelController;
  final List<TextEditingController> _choiceControllers = [];
  List<int?> _choiceIds = [];
  int _correctChoiceIndex = 0;

  late int _selectedSkillId;
  String _selectedStatus = 'active';

  static const List<String> _statuses = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    final e = widget.existingExercise;
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _codeController = TextEditingController(text: e?.codeSnippet ?? '');
    _levelController = TextEditingController(text: (e?.level ?? 1).toString());

    final skillIds = widget.skillOptions.map((s) => s.id);
    _selectedSkillId = (e != null && skillIds.contains(e.skillId))
        ? e.skillId
        : widget.skillOptions.first.id;

    // ตัวเลือกของ CHOICE (เริ่มต้นอย่างน้อย 4 ช่อง)
    final initialChoices =
        (e != null && e.choices.isNotEmpty) ? e.choices : List.filled(4, '');
    _choiceIds = (e != null && e.choiceIds.isNotEmpty)
        ? List<int?>.from(e.choiceIds)
        : List<int?>.filled(initialChoices.length, null);
    for (final text in initialChoices) {
      _choiceControllers.add(TextEditingController(text: text));
    }
    _correctChoiceIndex = e?.correctChoiceIndex ?? 0;
    _selectedStatus = (e?.isActive ?? true) ? 'active' : 'inactive';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _codeController.dispose();
    _levelController.dispose();
    for (final c in _choiceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: duration ?? const Duration(seconds: 4)),
    );
  }

  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: _codeController.text));
    _showMessage('คัดลอกโค้ดแล้ว', duration: const Duration(seconds: 1));
  }

  /// ตรวจความถูกต้องของฟอร์ม คืนข้อความ error หรือ null ถ้าผ่าน
  String? _validate(List<String> choiceTexts) {
    if (_descriptionController.text.trim().isEmpty) return 'กรุณากรอกคำอธิบายโจทย์';
    if (choiceTexts.length < 2 || choiceTexts.any((t) => t.isEmpty)) {
      return 'กรุณากรอกตัวเลือกให้ครบอย่างน้อย 2 ข้อ';
    }
    return null;
  }

  void _save() {
    final choiceTexts = _choiceControllers.map((c) => c.text.trim()).toList();
    final error = _validate(choiceTexts);
    if (error != null) {
      _showMessage(error);
      return;
    }

    final existing = widget.existingExercise;
    final result = ExerciseItemData(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch,
      description: _descriptionController.text.trim(),
      codeSnippet: _codeController.text,
      language: 'Python',
      level: int.tryParse(_levelController.text.trim()) ?? 1,
      skillId: _selectedSkillId,
      skill: widget.skillOptions.firstWhere((s) => s.id == _selectedSkillId).name,
      expectedTime: 3,
      timeUnit: 'นาที (minute)',
      type: 'CHOICE',
      correctAnswer: '',
      caseSensitive: false,
      choices: choiceTexts,
      // ใช้ choice_id เดิมเพื่อให้ backend อัปเดตแทนการเพิ่มใหม่
      choiceIds: _choiceIds,
      correctChoiceIndex: _correctChoiceIndex,
      isActive: _selectedStatus == 'active',
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(isEditing: widget.existingExercise != null),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildFormBody(),
              ),
            ),
            _DialogFooter(onSave: _save),
          ],
        ),
      ),
    );
  }

  Widget _buildFormBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminLabeledField(
          label: 'คำอธิบายโจทย์ (DESCRIPTION)',
          child: TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: adminInputDecoration(hint: 'พิมพ์คำอธิบายโจทย์...'),
          ),
        ),
        const SizedBox(height: 20),
        ExerciseCodeEditor(controller: _codeController),
        const SizedBox(height: 20),
        const AdminFieldLabel('ตัวอย่างที่ผู้เรียนจะเห็น'),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _codeController,
          builder: (context, value, child) {
            return CodePreviewCard(
              code: value.text,
              language: 'Python',
              onCopy: _copyCodeToClipboard,
            );
          },
        ),
        const SizedBox(height: 20),
        AdminFieldRow(
          left: AdminLabeledField(
            label: 'LEVEL',
            child: TextField(
              controller: _levelController,
              keyboardType: TextInputType.number,
              decoration: adminInputDecoration(),
            ),
          ),
          right: AdminLabeledField(
            label: 'SKILL',
            child: AdminDropdownField<int>(
              value: _selectedSkillId,
              items: widget.skillOptions.map((s) => s.id).toList(),
              displayLabel: (id) => widget.skillOptions.firstWhere((s) => s.id == id).name,
              onChanged: (val) => setState(() => _selectedSkillId = val),
            ),
          ),
        ),
        const SizedBox(height: 20),
        AdminLabeledField(
          label: 'สถานะ',
          child: AdminDropdownField<String>(
            value: _selectedStatus,
            items: _statuses,
            onChanged: (val) => setState(() => _selectedStatus = val),
          ),
        ),
        const SizedBox(height: 20),
        ChoiceOptionsField(
          controllers: _choiceControllers,
          correctIndex: _correctChoiceIndex,
          onCorrectIndexChanged: (val) => setState(() => _correctChoiceIndex = val),
        ),
      ],
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final bool isEditing;

  const _DialogHeader({required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF6FF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isEditing ? Icons.edit_rounded : Icons.add_rounded,
            color: const Color(0xFF1D4ED8),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isEditing ? 'แก้ไข Exercise' : 'เพิ่ม Exercise ใหม่',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  final VoidCallback onSave;

  const _DialogFooter({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('บันทึก', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
