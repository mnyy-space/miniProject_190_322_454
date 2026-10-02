import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/goal_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_list_widgets.dart';

/// Dialog รายละเอียด Goal + Learning Tree
class GoalDetailDialog extends StatelessWidget {
  final GoalItemData goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GoalDetailDialog({
    super.key,
    required this.goal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      title: const Row(
        children: [
          Icon(Icons.search_rounded, color: Color(0xFF1E3A8A), size: 22),
          SizedBox(width: 8),
          Text(
            'รายละเอียด Goal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const _DetailLabel('ชื่อ GOAL'),
              const SizedBox(height: 4),
              Text(
                goal.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 18),
              const _DetailLabel('รหัส GOAL'),
              const SizedBox(height: 4),
              Text(
                goal.code.isEmpty ? '—' : goal.code,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 18),
              const _DetailLabel('สถานะ'),
              const SizedBox(height: 6),
              _StatusDot(isActive: goal.isActive),
              const SizedBox(height: 22),
              const _DetailLabel('SKILL ที่ต้องใช้'),
              const SizedBox(height: 10),
              goal.requiredSkills.isEmpty
                  ? const _EmptyText('— ไม่มีเงื่อนไข Skill —')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: goal.requiredSkills
                          .map((req) => AdminTag(req.skillName))
                          .toList(),
                    ),
              const SizedBox(height: 24),
              const _DetailLabel('LEARNING TREE'),
              const SizedBox(height: 10),
              goal.requiredSkills.isEmpty
                  ? const _EmptyText('— ไม่มีผัง Learning Tree —')
                  : _LearningTree(skills: goal.requiredSkills),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF334155),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('ปิด', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('ลบ', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0256B8),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.pop(context);
            onEdit();
          },
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('แก้ไข', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _DetailLabel extends StatelessWidget {
  final String text;

  const _DetailLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.4,
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;

  const _EmptyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)));
  }
}

class _StatusDot extends StatelessWidget {
  final bool isActive;

  const _StatusDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isActive ? 'active' : 'inactive',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }
}

/// กล่อง Skill เรียงแนวนอน (เลื่อนซ้าย-ขวาได้)
class _LearningTree extends StatelessWidget {
  final List<GoalRequiredSkill> skills;

  const _LearningTree({required this.skills});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: skills.map((req) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            width: 170,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Text(
              req.skillName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A8A),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
