import 'package:flutter/material.dart';

/// ไอคอน Skill ที่ admin เลือกได้: key = ชื่อที่เก็บในคอลัมน์ skills.skill_icon
/// (ตรงกับชื่อ Icons.xxx ของ Material) ต้องเป็น const เพื่อให้ tree-shake ฟอนต์ไอคอนได้ตอน build release
const Map<String, IconData> skillIcons = {
  'school': Icons.school,
  'code': Icons.code,
  'terminal': Icons.terminal,
  'data_object': Icons.data_object,
  'data_array': Icons.data_array,
  'integration_instructions': Icons.integration_instructions,
  'developer_mode': Icons.developer_mode,
  'javascript': Icons.javascript,
  'html': Icons.html,
  'css': Icons.css,
  'php': Icons.php,
  'web': Icons.web,
  'language': Icons.language,
  'api': Icons.api,
  'storage': Icons.storage,
  'dns': Icons.dns,
  'table_chart': Icons.table_chart,
  'schema': Icons.schema,
  'account_tree': Icons.account_tree,
  'hub': Icons.hub,
  'lan': Icons.lan,
  'memory': Icons.memory,
  'functions': Icons.functions,
  'calculate': Icons.calculate,
  'sort': Icons.sort,
  'loop': Icons.loop,
  'view_list': Icons.view_list,
  'layers': Icons.layers,
  'extension': Icons.extension,
  'bug_report': Icons.bug_report,
  'security': Icons.security,
  'cloud': Icons.cloud,
  'smartphone': Icons.smartphone,
  'android': Icons.android,
  'laptop': Icons.laptop,
  'desktop_windows': Icons.desktop_windows,
  'settings': Icons.settings,
  'build': Icons.build,
  'psychology': Icons.psychology,
  'science': Icons.science,
  'lightbulb': Icons.lightbulb,
  'rocket_launch': Icons.rocket_launch,
  'menu_book': Icons.menu_book,
  'auto_stories': Icons.auto_stories,
  'quiz': Icons.quiz,
};

/// ไอคอนเริ่มต้นเมื่อ Skill ยังไม่ได้เลือกไอคอน (ตรงกับ DEFAULT ของคอลัมน์ในฐานข้อมูล)
const String defaultSkillIconName = 'school';

/// แปลงชื่อไอคอนจากฐานข้อมูลเป็น IconData (ชื่อที่ไม่รู้จักใช้ไอคอนเริ่มต้น)
IconData skillIconOf(String? name) =>
    skillIcons[name] ?? skillIcons[defaultSkillIconName]!;
