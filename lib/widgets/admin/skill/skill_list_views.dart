import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/skill_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_list_widgets.dart';

/// callback ของแต่ละแถว Skill ที่ทั้งตารางและการ์ดใช้ร่วมกัน
class SkillRowCallbacks {
  final void Function(SkillItemData skill) onView;
  final void Function(SkillItemData skill) onEdit;
  final void Function(SkillItemData skill) onDelete;
  final void Function(SkillItemData skill, bool isActive) onStatusChanged;

  const SkillRowCallbacks({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });
}

/// ตาราง Skill บน Desktop
class SkillDataTable extends StatelessWidget {
  final List<SkillItemData> skills;
  final SkillRowCallbacks callbacks;

  const SkillDataTable({super.key, required this.skills, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AdminTableCard(
      columns: const [
        DataColumn(label: Text('Skill code')),
        DataColumn(label: Text('Skill')),
        DataColumn(label: Text('Tier')),
        DataColumn(label: Text('Prerequisite')),
        DataColumn(label: Text('Actions')),
        DataColumn(label: Text('สถานะ')),
      ],
      rows: skills.map(_buildRow).toList(),
    );
  }

  DataRow _buildRow(SkillItemData skill) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            skill.code,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A8A),
              letterSpacing: 0.3,
            ),
          ),
        ),
        DataCell(
          Text(
            skill.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        DataCell(AdminTag(skill.tier, tone: AdminTagTone.green)),
        DataCell(
          skill.prerequisite == '—'
              ? const Text('—', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16))
              : AdminTag(skill.prerequisite),
        ),
        DataCell(
          AdminRowActions(
            onView: () => callbacks.onView(skill),
            onEdit: () => callbacks.onEdit(skill),
            onDelete: () => callbacks.onDelete(skill),
          ),
        ),
        DataCell(
          AdminStatusSwitch(
            value: skill.isActive,
            onChanged: (val) => callbacks.onStatusChanged(skill, val),
          ),
        ),
      ],
    );
  }
}

/// การ์ด Skill 1 รายการบน Mobile
class SkillMobileCard extends StatelessWidget {
  final SkillItemData skill;
  final SkillRowCallbacks callbacks;

  const SkillMobileCard({super.key, required this.skill, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.code,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            AdminStatusSwitch(
              value: skill.isActive,
              showLabel: false,
              onChanged: (val) => callbacks.onStatusChanged(skill, val),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            AdminTag(skill.tier, tone: AdminTagTone.green, dense: true),
            const SizedBox(width: 8),
            Expanded(
              child: skill.prerequisite == '—'
                  ? const SizedBox.shrink()
                  : Text(
                      'Req: ${skill.prerequisite}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF2563EB)),
              onPressed: () => callbacks.onEdit(skill),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
              onPressed: () => callbacks.onDelete(skill),
            ),
          ],
        ),
      ],
    );
  }
}
