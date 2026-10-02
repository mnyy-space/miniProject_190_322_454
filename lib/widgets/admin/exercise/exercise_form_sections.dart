import 'package:flutter/material.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';

/// ช่องกรอก "โค้ดประกอบโจทย์" + ปุ่มแทรกช่องว่าง ____ ตรงตำแหน่งเคอร์เซอร์
class ExerciseCodeEditor extends StatelessWidget {
  final TextEditingController controller;

  const ExerciseCodeEditor({super.key, required this.controller});

  void _insertBlank() {
    final text = controller.text;
    final selection = controller.selection;
    final insertPos =
        selection.start >= 0 && selection.start <= text.length ? selection.start : text.length;
    controller.value = TextEditingValue(
      text: text.replaceRange(insertPos, insertPos, '____'),
      selection: TextSelection.collapsed(offset: insertPos + 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: AdminFieldLabel('โค้ดประกอบโจทย์ (ไม่บังคับ)')),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _insertBlank,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'แทรกช่องว่าง',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
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
              hintText: 'data = [1, 2, 3, 4]\nval = data.pop()\nprint(val)',
              hintStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'พิมพ์ ____ (ขีดล่างอย่างน้อย 3 ตัว) ตรงจุดที่ต้องการให้ผู้เรียนเติมคำตอบ '
          'หรือกดปุ่ม "แทรกช่องว่าง" ด้านบนแทนการพิมพ์เอง',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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

  const ChoiceOptionsField({
    super.key,
    required this.controllers,
    required this.correctIndex,
    required this.onCorrectIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdminLabeledField(
      label: 'ตัวเลือก (เลือกวงกลมหน้าข้อที่ถูกต้อง)',
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
