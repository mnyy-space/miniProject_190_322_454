class SkillItemData {
  int id;
  String code;
  String name;
  String tier;
  String prerequisite;
  bool isActive;

  SkillItemData({
    required this.id,
    required this.code,
    required this.name,
    required this.tier,
    required this.prerequisite,
    required this.isActive,
  });

  // แปลงข้อมูลจาก GET admin/skill (backend ยังไม่มี tier / prerequisite จึงใช้ค่าเริ่มต้น)
  factory SkillItemData.fromJson(Map<String, dynamic> item) {
    final name = (item['skill_name'] ?? '').toString();
    return SkillItemData(
      id: item['skill_id'] ?? 0,
      code: item['skill_code'] ?? (name.isEmpty ? 'SKILL' : name.toUpperCase()),
      name: name,
      tier: 'Basic',
      prerequisite: '—',
      isActive: parseIsActive(item['is_active']),
    );
  }
}

/// is_active จาก backend อาจเป็น 1 / true / '1'
bool parseIsActive(dynamic value) => value == 1 || value == true || value == '1';
