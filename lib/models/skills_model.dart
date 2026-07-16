  import 'dart:async';

  class SkillsModel {
    int skillId = 0;
    String skillName = "";

    SkillsModel({
      required this.skillId,
      required this.skillName,
    });

    factory SkillsModel.fromJson(Map<String, dynamic> json) {
      return SkillsModel(
        skillId: json['skill_id'] as int,
        skillName: json['skill_name'] as String
        );
    }
  }

  class SkillsResponse {
    bool isError = false;
    List<SkillsModel> data = [];
    String errorMessage = "";

    SkillsResponse({
      required this.isError,
      required this.data,
      required this.errorMessage,
    });

    factory SkillsResponse.fromJson(Map<String, dynamic> json) {
      return SkillsResponse(
        isError: json['isError'],
        data: (json['data'] as List)
          .map((item) => SkillsModel.fromJson(item))
          .toList(),
        errorMessage: json['errorMessage'],
      );
    }
  }

