import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/sessions_model.dart';
import 'package:halalsefllearning/models/skills_model.dart';
import 'package:halalsefllearning/screens/exercise_screen.dart';
import 'package:halalsefllearning/screens/select_skill_screen.dart';
import 'package:halalsefllearning/widgets/home_block_widget.dart';
import 'package:halalsefllearning/utils/skill_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final int? skillId;
  const HomeScreen({super.key, this.skillId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SessionsModel> sessionStore = [];
  int? _currentSkillId;
  String? _currentSkillName;
  String? _currentSkillIcon;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initSkillAndFetchSessions();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.skillId != oldWidget.skillId) {
      _initSkillAndFetchSessions();
    }
  }

  Future<void> _initSkillAndFetchSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final skillId = widget.skillId ??
        prefs.getInt("selected_skill_id") ??
        prefs.getInt("latest_skill_id");
    final skillName = prefs.getString("selected_skill_name") ??
        prefs.getString("latest_skill_name");
    final skillIcon = prefs.getString("selected_skill_icon") ??
        prefs.getString("latest_skill_icon");

    if (mounted) {
      setState(() {
        _currentSkillId = skillId;
        _currentSkillName = skillName;
        _currentSkillIcon = skillIcon;
      });
    }

    if (skillId != null && skillId > 0) {
      _fetchSessions(skillId);
      _refreshSkillIcon(skillId);
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// ดึงไอคอนล่าสุดของ Skill จาก API (admin อาจเปลี่ยนไอคอนหลังจากที่แคชไว้ใน SharedPreferences)
  Future<void> _refreshSkillIcon(int skillId) async {
    try {
      final response = await AppApi.get("skill");
      if (response.statusCode != 200) return;
      final skills = SkillsResponse.fromJson(jsonDecode(response.body)).data;
      final matches = skills.where((s) => s.skillId == skillId);
      if (matches.isEmpty) return;
      final skill = matches.first;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("selected_skill_icon", skill.skillIcon);
      if (mounted && _currentSkillId == skillId) {
        setState(() => _currentSkillIcon = skill.skillIcon);
      }
    } catch (_) {
      // โหลดไม่สำเร็จก็ใช้ไอคอนจากแคชเดิมต่อไป
    }
  }

  Future<void> _fetchSessions(int skillId) async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final response = await AppApi.get("session/$skillId");
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final sessionsResponse = SessionsResponse.fromJson(json);

        if (mounted) {
          setState(() {
            sessionStore = sessionsResponse.data;
            isLoading = false;
            if (sessionsResponse.isError && sessionsResponse.data.isEmpty) {
              errorMessage = sessionsResponse.errorMessage.isNotEmpty
                  ? sessionsResponse.errorMessage
                  : "ไม่พบข้อมูล Session ใน Skill นี้";
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            sessionStore = [];
            isLoading = false;
            errorMessage = "ไม่พบข้อมูล Session ใน Skill นี้";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "เกิดข้อผิดพลาดในการโหลด Session: $e";
        });
      }
    }
  }

  void _onChangeSkill() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectSkillScreen(),
      ),
    );
  }

  void _onTapSession(SessionsModel session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseScreen(
          skillTitle: session.sessionName,
          sessionId: session.sessionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วน Header ด้านบน และ Card "Especially For You / Continue Learning"
            const HomeBlockWidget(),

            const SizedBox(height: 24),

            // แถบหัวข้อ Sessions พร้อมปุ่มเปลี่ยน Skill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sessions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (_currentSkillName != null && _currentSkillName!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                skillIconOf(_currentSkillIcon),
                                size: 16,
                                color: const Color(0xFF0F6DA8),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Skill: $_currentSkillName',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F6DA8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _onChangeSkill,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                    label: const Text(
                      'เปลี่ยน Skill',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0F6DA8),
                      backgroundColor: const Color(0xFFE2F6FC),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // เนื้อหาแสดงรายการ Sessions
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2894D7),
                  ),
                ),
              )
            else if (_currentSkillId == null || _currentSkillId == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 56,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "กรุณาเลือก Skill เพื่อเริ่มเรียน",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _onChangeSkill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0093E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('เลือก Skill ตอนนี้'),
                      ),
                    ],
                  ),
                ),
              )
            else if (sessionStore.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 54,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        errorMessage ?? "ไม่พบ Session ใน Skill นี้",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: sessionStore.length,
                itemBuilder: (context, index) {
                  final session = sessionStore[index];
                  return _buildSessionCard(session, index);
                },
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(SessionsModel session, int index) {
    // สีสลับกันสำหรับ Session แต่ละใบ ส่วนไอคอนใช้ไอคอนของ Skill ที่ admin เลือก
    const List<Color> cardColors = [
      Color(0xFF0096E6),
      Color(0xFF00C9A7),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
    ];

    final cardColor = cardColors[index % cardColors.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTapSession(session),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    skillIconOf(_currentSkillIcon),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  session.sessionName,
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
                const SizedBox(height: 4),
                Text(
                  'Session ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                // จำนวนแบบฝึกหัดใน Session นี้
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.quiz_rounded, size: 13, color: cardColor),
                      const SizedBox(width: 4),
                      Text(
                        '${session.exerciseCount} ข้อ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cardColor,
                        ),
                      ),
                    ],
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
