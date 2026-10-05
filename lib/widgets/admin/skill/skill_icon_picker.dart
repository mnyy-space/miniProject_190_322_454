import 'package:flutter/material.dart';
import 'package:halalsefllearning/utils/skill_icons.dart';

/// ตัวเลือกไอคอนของ Skill แบบกดย่อ/ขยายได้ (คืนค่าเป็นชื่อไอคอนที่เก็บลงฐานข้อมูล)
/// ปกติจะย่อไว้ แสดงเฉพาะไอคอนที่เลือกอยู่ กดที่แถบด้านบนเพื่อเปิดตารางไอคอน
class SkillIconPicker extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const SkillIconPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<SkillIconPicker> createState() => _SkillIconPickerState();
}

class _SkillIconPickerState extends State<SkillIconPicker> {
  bool _isExpanded = false;

  void _select(String iconName) {
    widget.onChanged(iconName);
    // เลือกแล้วย่อกลับอัตโนมัติ
    setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // แถบหัว: ไอคอนที่เลือกอยู่ + ปุ่มย่อ/ขยาย
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  SkillIconBadge(iconName: widget.selected, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.selected,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  Text(
                    _isExpanded ? 'ย่อ' : 'เปลี่ยนไอคอน',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: _buildGrid(),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skillIcons.entries.map((entry) {
        final isSelected = entry.key == widget.selected;
        return Tooltip(
          message: entry.key,
          child: InkWell(
            onTap: () => _select(entry.key),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                entry.value,
                size: 22,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// ไอคอน Skill ในกรอบสี่เหลี่ยมมุมมน ใช้ในตาราง / การ์ด / dialog ของ admin
class SkillIconBadge extends StatelessWidget {
  final String iconName;
  final double size;

  const SkillIconBadge({super.key, required this.iconName, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        skillIconOf(iconName),
        color: const Color(0xFF2563EB),
        size: size * 0.56,
      ),
    );
  }
}
