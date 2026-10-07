/// การทำ session 1 รอบของผู้ใช้ 1 คน
class SessionAttemptLog {
  final int historyId;
  final int userId;
  final String username;
  final String fullName;
  final int attemptNo;

  /// null เมื่อเป็นข้อมูลเก่าที่ยังไม่ได้บันทึกคะแนน
  final int? correctCount;
  final int? incorrectCount;
  final int? totalQuestions;
  final String createDate;

  const SessionAttemptLog({
    required this.historyId,
    required this.userId,
    required this.username,
    this.fullName = '',
    required this.attemptNo,
    this.correctCount,
    this.incorrectCount,
    this.totalQuestions,
    this.createDate = '',
  });

  factory SessionAttemptLog.fromJson(Map<String, dynamic> json) {
    return SessionAttemptLog(
      historyId: (json['history_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      attemptNo: (json['attempt_no'] as num?)?.toInt() ?? 1,
      correctCount: (json['correct_count'] as num?)?.toInt(),
      incorrectCount: (json['incorrect_count'] as num?)?.toInt(),
      totalQuestions: (json['total_questions'] as num?)?.toInt(),
      createDate: json['create_date']?.toString() ?? '',
    );
  }
}

/// log การทำ session ทั้งหมด (GET admin/session/:id/history)
class SessionHistoryData {
  final int attemptCount;
  final int userCount;
  final List<SessionAttemptLog> logs;

  const SessionHistoryData({
    required this.attemptCount,
    required this.userCount,
    required this.logs,
  });

  factory SessionHistoryData.fromJson(Map<String, dynamic> json) {
    final List rawLogs = json['logs'] ?? [];
    return SessionHistoryData(
      attemptCount: (json['attempt_count'] as num?)?.toInt() ?? 0,
      userCount: (json['user_count'] as num?)?.toInt() ?? 0,
      logs: rawLogs
          .map((l) => SessionAttemptLog.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}
