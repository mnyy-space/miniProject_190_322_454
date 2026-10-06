class UserItemData {
  final int id;
  final String username;
  String fullName;
  String email;
  int roleId;
  String roleName;
  final String? createDate;
  final String learningContent;

  UserItemData({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.roleId,
    required this.roleName,
    this.createDate,
    required this.learningContent,
  });

  bool get isAdmin => roleId == 2 || roleName.toLowerCase() == 'admin';

  bool get hasLearningContent =>
      learningContent.isNotEmpty && learningContent != '-';

  String get displayLearningContent {
    if (isAdmin) {
      return hasLearningContent ? learningContent : '-';
    }
    return hasLearningContent ? learningContent : 'ยังไม่มีประวัติการเรียน';
  }

  factory UserItemData.fromJson(Map<String, dynamic> item) {
    final rawContent = item['learning_content']?.toString().trim();
    return UserItemData(
      id: item['user_id'] is int
          ? item['user_id']
          : int.tryParse(item['user_id']?.toString() ?? '0') ?? 0,
      username: (item['username'] ?? '').toString(),
      fullName: (item['full_name'] ?? '').toString(),
      email: (item['email'] ?? '').toString(),
      roleId: item['role_id'] is int
          ? item['role_id']
          : int.tryParse(item['role_id']?.toString() ?? '1') ?? 1,
      roleName: (item['role_name'] ?? (item['role_id'] == 2 ? 'admin' : 'user')).toString(),
      createDate: item['create_date']?.toString(),
      learningContent: (rawContent == null || rawContent.isEmpty)
          ? '-'
          : rawContent,
    );
  }
}
