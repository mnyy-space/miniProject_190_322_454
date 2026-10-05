import 'package:halalsefllearning/utils/skill_icons.dart';

  class SkillsModel {
    int skillId = 0;
    String skillName = "";
    String skillIcon = defaultSkillIconName;
    int sessionCount = 0;

    SkillsModel({
      required this.skillId,
      required this.skillName,
      this.skillIcon = defaultSkillIconName,
      this.sessionCount = 0,
    });

    factory SkillsModel.fromJson(Map<String, dynamic> json) {
      return SkillsModel(
        skillId: json['skill_id'] as int,
        skillName: json['skill_name'] as String,
        skillIcon: json['skill_icon'] as String? ?? defaultSkillIconName,
        sessionCount: (json['session_count'] as num?)?.toInt() ?? 0,
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
      List<SkillsModel> skillList = [];
      if (json['data'] != null && json['data'] is List) {
        skillList = (json['data'] as List)
            .map((item) => SkillsModel.fromJson(item))
            .toList();
      }

      return SkillsResponse(
        isError: json['isError'] ?? false,
        data: skillList,
        errorMessage: json['errorMessage'] ?? "",
      );
    }
  }

