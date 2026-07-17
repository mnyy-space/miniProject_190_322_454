import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/skills_model.dart';

class SkillsCard extends StatelessWidget {
  const SkillsCard({
    super.key,
    required this.skill,
    this.index = 0,
  });

  final SkillsModel skill;
  final int index;

  @override
  Widget build(BuildContext context) {
    // ชุดสีและไอคอนสำหรับตกแต่ง Card ตาม Index (คล้ายธีม Courses, Quiz, Exams, Library ในภาพ)
    final List<Map<String, dynamic>> cardTheme = [
      {
        'color': const Color(0xFFFF3B56),
        'icon': Icons.menu_book_rounded,
      },
      {
        'color': const Color(0xFF00C9A7),
        'icon': Icons.quiz_rounded,
      },
      {
        'color': const Color(0xFF3B82F6),
        'icon': Icons.assignment_rounded,
      },
      {
        'color': const Color(0xFFF59E0B),
        'icon': Icons.local_library_rounded,
      },
    ];

    final theme = cardTheme[index % cardTheme.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // วงกลมสีพร้อมไอคอนตรงกลาง
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: theme['color'] as Color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (theme['color'] as Color).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    theme['icon'] as IconData,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 16),

                // ชื่อ Skill / Topic
                Text(
                  skill.skillName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
