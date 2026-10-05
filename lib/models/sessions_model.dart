class SessionsModel {

  int sessionId = 0;
  String sessionName = '';
  int exerciseCount = 0;

  SessionsModel({
    required this.sessionId,
    required this.sessionName,
    this.exerciseCount = 0,
  });


  factory SessionsModel.fromJson(Map<String, dynamic> json){
    return SessionsModel(
    sessionId: json['session_id'] is int ? json['session_id'] as int :int.tryParse(json['session_id']?.toString() ?? '') ?? 0 , 
    sessionName: json['session_name'] as String,
    exerciseCount: (json['exercise_count'] as num?)?.toInt() ?? 0,
    );
  }

}


class SessionsResponse{
  bool isError = false;
  List<SessionsModel> data = [];
  String errorMessage = '';

  SessionsResponse({
    required this.isError,
    required this.data,
    required this.errorMessage
  });

  factory SessionsResponse.fromJson(Map<String, dynamic> json){
    List<SessionsModel> sessionList = [];
    if (json['data'] != null && json['data'] is List) {
      sessionList = (json['data'] as List)
          .map((item)=> SessionsModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return SessionsResponse(
      isError: json['isError'] as bool? ?? false,
      data: sessionList,
      errorMessage: json['errorMessage'] as String? ?? '',
    );
  }
}