class SessionsModel {

  int sessionId = 0;
  String sessionName = '';
  
  SessionsModel({
    required this.sessionId,
    required this.sessionName,
  });


  factory SessionsModel.fromJson(Map<String, dynamic> json){
    return SessionsModel(
    sessionId: json['session_id'] is int ? json['session_id'] as int :int.tryParse(json['session_id']?.toString() ?? '') ?? 0 , 
    sessionName: json['session_name'] as String,
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
    return SessionsResponse(
      isError: json['isError'] as bool? ?? false,
      data : (json['data'] as List? ?? [])
            .map((item)=> SessionsModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      errorMessage: json['errorMessage'] as String? ?? '',
    );
  }
}