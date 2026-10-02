import 'package:halalsefllearning/models/admin/skill_item_data.dart';

class GoalItemData {
  int id;
  String code;
  String name;
  List<GoalRequiredSkill> requiredSkills;
  bool isActive;

  GoalItemData({
    required this.id,
    required this.code,
    required this.name,
    required this.requiredSkills,
    required this.isActive,
  });

  // แปลงข้อมูลจาก GET admin/goal (มี skills ที่ผูกไว้แบบ Many-to-Many)
  factory GoalItemData.fromJson(Map<String, dynamic> item) {
    final List skills = item['skills'] ?? [];
    return GoalItemData(
      id: item['goal_id'] ?? 0,
      code: (item['goal_code'] ?? '').toString(),
      name: (item['goal_name'] ?? '').toString(),
      isActive: parseIsActive(item['is_active']),
      requiredSkills: skills.map((s) => GoalRequiredSkill.fromJson(s)).toList(),
    );
  }
}

class GoalRequiredSkill {
  int skillId;
  String skillName;

  GoalRequiredSkill({
    required this.skillId,
    required this.skillName,
  });

  factory GoalRequiredSkill.fromJson(Map<String, dynamic> s) {
    return GoalRequiredSkill(
      skillId: s['skill_id'] ?? 0,
      skillName: (s['skill_name'] ?? '').toString(),
    );
  }
}
