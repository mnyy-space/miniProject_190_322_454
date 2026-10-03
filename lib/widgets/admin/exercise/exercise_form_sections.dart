import 'package:flutter/material.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';

/// ช่องกรอก "โค้ดประกอบโจทย์ (ไม่บังคับ)"
class ExerciseCodeEditor extends StatelessWidget {
  final TextEditingController controller;

  const ExerciseCodeEditor({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminFieldLabel('โค้ดประกอบโจทย์ (ไม่บังคับ)'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: TextField(
            controller: controller,
            maxLines: 6,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
              hintText: 'พิมพ์โค้ดประกอบโจทย์ที่นี่... (ไม่บังคับ)',
              hintStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ฟิลด์เฉพาะโจทย์ FILL_IN_BLANK: คำตอบที่ถูกต้อง + ตรวจตัวพิมพ์เล็ก/ใหญ่
class FillInBlankAnswerField extends StatelessWidget {
  final TextEditingController controller;
  final bool caseSensitive;
  final ValueChanged<bool> onCaseSensitiveChanged;

  const FillInBlankAnswerField({
    super.key,
    required this.controller,
    required this.caseSensitive,
    required this.onCaseSensitiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminLabeledField(
          label: 'คำตอบที่ถูกต้อง (FILL IN BLANK)',
          child: TextField(
            controller: controller,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            decoration: adminInputDecoration(hint: 'เช่น pop(0)'),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: caseSensitive,
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) => onCaseSensitiveChanged(val ?? false),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'ตรวจตัวพิมพ์เล็ก/ใหญ่ (Case sensitive)',
                style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ฟิลด์เฉพาะโจทย์ CHOICE: ตัวเลือกแต่ละข้อ + radio เลือกข้อที่ถูกต้อง
class ChoiceOptionsField extends StatelessWidget {
  final List<TextEditingController> controllers;
  final int correctIndex;
  final ValueChanged<int> onCorrectIndexChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ChoiceOptionsField({
    super.key,
    required this.controllers,
    required this.correctIndex,
    required this.onCorrectIndexChanged,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AdminLabeledField(
      label: 'ตัวเลือก ${controllers.length}/4 (เลือกข้อที่ถูกต้อง)',
      child: RadioGroup<int>(
        groupValue: correctIndex,
        onChanged: (val) => onCorrectIndexChanged(val ?? 0),
        child: Column(
          children: [
            for (int i = 0; i < controllers.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(value: i, activeColor: const Color(0xFF10B981)),
                    Expanded(
                      child: TextField(
                        controller: controllers[i],
                        decoration: adminInputDecoration(
                          hint: 'ตัวเลือกที่ ${String.fromCharCode(65 + i)}',
                        ),
                      ),
                    ),
                    IconButton(
                      key: ValueKey('remove-choice-$i'),
                      tooltip: 'ลบตัวเลือก ${String.fromCharCode(65 + i)}',
                      onPressed: controllers.length > 2
                          ? () => onRemove(i)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: const Color(0xFFDC2626),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey('add-choice'),
                onPressed: controllers.length < 4 ? onAdd : null,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('เพิ่มตัวเลือก'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
