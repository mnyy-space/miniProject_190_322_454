import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/skill_item_data.dart';
import 'package:halalsefllearning/widgets/admin/skill/skill_icon_picker.dart';

/// Dialog แสดงรายละเอียด Skill
class SkillDetailDialog extends StatelessWidget {
  final SkillItemData skill;

  const SkillDetailDialog({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          SkillIconBadge(iconName: skill.icon, size: 40),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              skill.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skill Code: ${skill.code}'),
          const SizedBox(height: 6),
          Text('Tier: ${skill.tier}'),
          const SizedBox(height: 6),
          Text('สถานะ: ${skill.isActive ? "Active" : "Inactive"}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ปิด'),
        ),
      ],
    );
  }
}
