import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/sessions_model.dart';
import 'package:halalsefllearning/screens/exercise_screen.dart';
import 'package:halalsefllearning/screens/select_skill_screen.dart';
import 'package:halalsefllearning/widgets/home_block_widget.dart';
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

    if (mounted) {
      setState(() {
        _currentSkillId = skillId;
        _currentSkillName = skillName;
      });
    }

    if (skillId != null && skillId > 0) {
      _fetchSessions(skillId);
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
                          Text(
                            'Skill: $_currentSkillName',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F6DA8),
                            ),
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
                  childAspectRatio: 0.95,
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
    // ธีมสีสลับกันสำหรับ Session แต่ละใบ
    final List<Map<String, dynamic>> cardTheme = [
      {
        'color': const Color(0xFF0096E6),
        'icon': Icons.menu_book_rounded,
      },
      {
        'color': const Color(0xFF00C9A7),
        'icon': Icons.code_rounded,
      },
      {
        'color': const Color(0xFF8B5CF6),
        'icon': Icons.quiz_rounded,
      },
      {
        'color': const Color(0xFFF59E0B),
        'icon': Icons.terminal_rounded,
      },
    ];

    final theme = cardTheme[index % cardTheme.length];

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
                    color: theme['color'] as Color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (theme['color'] as Color).withValues(alpha: 0.3),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
