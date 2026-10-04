class HistoryModel {
  final int historyId;
  final int userId;
  final DateTime? historyDate;
  final int sessionId;
  final String sessionName;
  final int skillId;
  final String skillName;
  final String? skillCode;

  HistoryModel({
    required this.historyId,
    required this.userId,
    this.historyDate,
    required this.sessionId,
    required this.sessionName,
    required this.skillId,
    required this.skillName,
    this.skillCode,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['history_date'] != null) {
      try {
        parsedDate = DateTime.parse(json['history_date'].toString());
      } catch (_) {}
    }

    return HistoryModel(
      historyId: (json['history_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      historyDate: parsedDate,
      sessionId: (json['session_id'] as num?)?.toInt() ?? 0,
      sessionName: json['session_name'] as String? ?? '',
      skillId: (json['skill_id'] as num?)?.toInt() ?? 0,
      skillName: json['skill_name'] as String? ?? '',
      skillCode: json['skill_code'] as String?,
    );
  }
}

class HistoryListResponse {
  final bool isError;
  final String errorMessage;
  final List<HistoryModel> data;

  HistoryListResponse({
    required this.isError,
    required this.errorMessage,
    required this.data,
  });

  factory HistoryListResponse.fromJson(Map<String, dynamic> json) {
    List<HistoryModel> list = [];
    if (json['data'] is List) {
      for (final item in json['data'] as List) {
        if (item is Map<String, dynamic>) {
          list.add(HistoryModel.fromJson(item));
        }
      }
    }

    return HistoryListResponse(
      isError: json['isError'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String? ?? '',
      data: list,
    );
  }
}

class LatestHistoryResponse {
  final bool isError;
  final String errorMessage;
  final HistoryModel? data;

  LatestHistoryResponse({
    required this.isError,
    required this.errorMessage,
    this.data,
  });

  factory LatestHistoryResponse.fromJson(Map<String, dynamic> json) {
    HistoryModel? model;
    if (json['data'] is Map<String, dynamic>) {
      model = HistoryModel.fromJson(json['data'] as Map<String, dynamic>);
    }

    return LatestHistoryResponse(
      isError: json['isError'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String? ?? '',
      data: model,
    );
  }
}
