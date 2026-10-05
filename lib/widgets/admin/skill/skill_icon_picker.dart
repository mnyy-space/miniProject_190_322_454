import 'package:flutter/material.dart';
import 'package:halalsefllearning/utils/skill_icons.dart';

/// ตารางไอคอนให้ admin เลือกไอคอนของ Skill (คืนค่าเป็นชื่อไอคอนที่เก็บลงฐานข้อมูล)
class SkillIconPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const SkillIconPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skillIcons.entries.map((entry) {
          final isSelected = entry.key == selected;
          return Tooltip(
            message: entry.key,
            child: InkWell(
              onTap: () => onChanged(entry.key),
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
      ),
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
