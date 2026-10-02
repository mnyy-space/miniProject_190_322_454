import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/goal_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_list_widgets.dart';

/// callback ของแต่ละแถว Goal ที่ทั้งตารางและการ์ดใช้ร่วมกัน
class GoalRowCallbacks {
  final void Function(GoalItemData goal) onView;
  final void Function(GoalItemData goal) onEdit;
  final void Function(GoalItemData goal) onDelete;
  final void Function(GoalItemData goal, bool isActive) onStatusChanged;

  const GoalRowCallbacks({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });
}

/// ตาราง Goal บน Desktop
class GoalDataTable extends StatelessWidget {
  final List<GoalItemData> goals;
  final GoalRowCallbacks callbacks;

  const GoalDataTable({super.key, required this.goals, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AdminTableCard(
      minWidth: 950,
      columns: const [
        DataColumn(label: Text('Goal')),
        DataColumn(label: Text('Skill Require')),
        DataColumn(label: Text('Actions')),
        DataColumn(label: Text('สถานะ')),
      ],
      rows: goals.map(_buildRow).toList(),
    );
  }

  DataRow _buildRow(GoalItemData goal) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            goal.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: goal.isActive ? const Color(0xFF1E3A8A) : const Color(0xFF475569),
            ),
          ),
        ),
        DataCell(SizedBox(width: 320, child: GoalSkillTags(skills: goal.requiredSkills))),
        DataCell(
          AdminRowActions(
            onView: () => callbacks.onView(goal),
            onEdit: () => callbacks.onEdit(goal),
            onDelete: () => callbacks.onDelete(goal),
          ),
        ),
        DataCell(
          AdminStatusSwitch(
            value: goal.isActive,
            onChanged: (val) => callbacks.onStatusChanged(goal, val),
          ),
        ),
      ],
    );
  }
}

/// การ์ด Goal 1 รายการบน Mobile
class GoalMobileCard extends StatelessWidget {
  final GoalItemData goal;
  final GoalRowCallbacks callbacks;

  const GoalMobileCard({super.key, required this.goal, required this.callbacks});

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
                    goal.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: goal.isActive
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFF475569),
                    ),
                  ),
                  if (goal.code.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      goal.code,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ],
              ),
            ),
            AdminStatusSwitch(
              value: goal.isActive,
              showLabel: false,
              onChanged: (val) => callbacks.onStatusChanged(goal, val),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GoalSkillTags(skills: goal.requiredSkills, dense: true),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: AdminRowActions(
            onView: () => callbacks.onView(goal),
            onEdit: () => callbacks.onEdit(goal),
            onDelete: () => callbacks.onDelete(goal),
          ),
        ),
      ],
    );
  }
}

/// แถบ Tag ของ Skill ที่ Goal ต้องใช้ (เลื่อนแนวนอนได้)
class GoalSkillTags extends StatelessWidget {
  final List<GoalRequiredSkill> skills;
  final bool dense;

  const GoalSkillTags({super.key, required this.skills, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: skills
            .map((req) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: AdminTag(req.skillName, dense: dense),
                ))
            .toList(),
      ),
    );
  }
}
