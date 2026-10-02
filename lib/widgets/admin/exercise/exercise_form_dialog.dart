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
  late final TextEditingController _expectedTimeController;
  late final TextEditingController _correctAnswerController;
  final List<TextEditingController> _choiceControllers = [];
  List<int?> _choiceIds = [];
  int _correctChoiceIndex = 0;

  String _selectedLanguage = 'Python';
  late int _selectedSkillId;
  String _selectedTimeUnit = 'นาที (minute)';
  String _selectedType = 'FILL_IN_BLANK';
  String _selectedStatus = 'active';
  bool _caseSensitive = false;

  static const List<String> _languages = ['Python', 'JavaScript', 'Java', 'C++', 'Dart'];
  static const List<String> _timeUnits = ['วินาที (second)', 'นาที (minute)', 'ชั่วโมง (hour)'];
  static const Map<String, String> _typeLabels = {
    'CHOICE': 'CHOICE (ตัวเลือก)',
    'FILL_IN_BLANK': 'FILL_IN_BLANK (เติมคำ)',
  };
  static const List<String> _statuses = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    final e = widget.existingExercise;
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _codeController = TextEditingController(text: e?.codeSnippet ?? '');
    _levelController = TextEditingController(text: (e?.level ?? 1).toString());
    _expectedTimeController = TextEditingController(text: (e?.expectedTime ?? 3).toString());
    _correctAnswerController = TextEditingController(text: e?.correctAnswer ?? '');

    _selectedLanguage = e?.language ?? 'Python';
    final skillIds = widget.skillOptions.map((s) => s.id);
    _selectedSkillId = (e != null && skillIds.contains(e.skillId))
        ? e.skillId
        : widget.skillOptions.first.id;

    // ตัวเลือกของ CHOICE (ถ้าเป็นโจทย์ใหม่เริ่มต้นที่ 4 ช่อง)
    final isChoice = e != null && e.type == 'CHOICE';
    final initialChoices =
        (isChoice && e.choices.isNotEmpty) ? e.choices : List.filled(4, '');
    _choiceIds = isChoice
        ? List<int?>.from(e.choiceIds)
        : List<int?>.filled(initialChoices.length, null);
    for (final text in initialChoices) {
      _choiceControllers.add(TextEditingController(text: text));
    }
    _correctChoiceIndex = isChoice ? e.correctChoiceIndex : 0;
    _selectedTimeUnit = e?.timeUnit ?? 'นาที (minute)';
    _selectedType = e?.type ?? 'FILL_IN_BLANK';
    _selectedStatus = (e?.isActive ?? true) ? 'active' : 'inactive';
    _caseSensitive = e?.caseSensitive ?? false;

    // อัปเดตพรีวิวโค้ดทุกครั้งที่พิมพ์
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _codeController.dispose();
    _levelController.dispose();
    _expectedTimeController.dispose();
    _correctAnswerController.dispose();
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
    if (_selectedType == 'FILL_IN_BLANK' && _correctAnswerController.text.trim().isEmpty) {
      return 'กรุณากรอกคำตอบที่ถูกต้อง';
    }
    if (_selectedType == 'CHOICE' &&
        (choiceTexts.length < 2 || choiceTexts.any((t) => t.isEmpty))) {
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
      language: _selectedLanguage,
      level: int.tryParse(_levelController.text.trim()) ?? 1,
      skillId: _selectedSkillId,
      skill: widget.skillOptions.firstWhere((s) => s.id == _selectedSkillId).name,
      expectedTime: int.tryParse(_expectedTimeController.text.trim()) ?? 3,
      timeUnit: _selectedTimeUnit,
      type: _selectedType,
      correctAnswer: _correctAnswerController.text.trim(),
      caseSensitive: _caseSensitive,
      choices: choiceTexts,
      // ใช้ choice_id เดิมเพื่อให้ backend อัปเดตแทนการเพิ่มใหม่
      choiceIds: _selectedType == 'CHOICE'
          ? _choiceIds
          : (existing != null && existing.type == 'FILL_IN_BLANK' ? existing.choiceIds : []),
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
        CodePreviewCard(
          code: _codeController.text,
          language: _selectedLanguage,
          onCopy: _copyCodeToClipboard,
        ),
        const SizedBox(height: 20),
        AdminLabeledField(
          label: 'ภาษาของโค้ด',
          child: AdminDropdownField<String>(
            value: _selectedLanguage,
            items: _languages,
            onChanged: (val) => setState(() => _selectedLanguage = val),
          ),
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
        AdminFieldRow(
          left: AdminLabeledField(
            label: 'เวลาที่คาดหวัง (EXPECTED TIME)',
            child: TextField(
              controller: _expectedTimeController,
              keyboardType: TextInputType.number,
              decoration: adminInputDecoration(),
            ),
          ),
          right: AdminLabeledField(
            label: 'หน่วย (UNIT)',
            child: AdminDropdownField<String>(
              value: _selectedTimeUnit,
              items: _timeUnits,
              onChanged: (val) => setState(() => _selectedTimeUnit = val),
            ),
          ),
        ),
        const SizedBox(height: 20),
        AdminFieldRow(
          left: AdminLabeledField(
            label: 'ประเภทโจทย์ (TYPE)',
            child: AdminDropdownField<String>(
              value: _selectedType,
              items: _typeLabels.keys.toList(),
              displayLabel: (v) => _typeLabels[v] ?? v,
              onChanged: (val) => setState(() => _selectedType = val),
            ),
          ),
          right: AdminLabeledField(
            label: 'สถานะ',
            child: AdminDropdownField<String>(
              value: _selectedStatus,
              items: _statuses,
              onChanged: (val) => setState(() => _selectedStatus = val),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_selectedType == 'FILL_IN_BLANK')
          FillInBlankAnswerField(
            controller: _correctAnswerController,
            caseSensitive: _caseSensitive,
            onCaseSensitiveChanged: (val) => setState(() => _caseSensitive = val),
          )
        else
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
