class SessionItemData {
  final int id;
  final String name;
  final int skillId;
  final String skillName;
  final List<int> exerciseIds;
  final List<String> exerciseNames;

  const SessionItemData({
    required this.id,
    required this.name,
    required this.skillId,
    required this.skillName,
    required this.exerciseIds,
    required this.exerciseNames,
  });

  factory SessionItemData.fromJson(Map<String, dynamic> json) {
    return SessionItemData(
      id: int.tryParse(json['session_id']?.toString() ?? '') ?? 0,
      name: (json['session_name'] ?? '').toString(),
      skillId: int.tryParse(json['skill_id']?.toString() ?? '') ?? 0,
      skillName: (json['skill_name'] ?? '').toString(),
      exerciseIds: (json['exercise_ids'] as List? ?? [])
          .map((id) => int.tryParse(id.toString()) ?? 0)
          .where((id) => id > 0)
          .toList(),
      exerciseNames: (json['exercise_names'] as List? ?? [])
          .map((name) => name.toString())
          .toList(),
    );
  }
}
