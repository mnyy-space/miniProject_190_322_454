import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/history_model.dart';
import 'package:halalsefllearning/screens/exercise_screen.dart';
import 'package:halalsefllearning/utils/skill_icons.dart';

class HomeBlockWidget extends StatefulWidget {
  const HomeBlockWidget({super.key});

  @override
  State<HomeBlockWidget> createState() => _HomeBlockWidgetState();
}

class _HomeBlockWidgetState extends State<HomeBlockWidget> {
  String? _latestSkillName;
  String? _latestSkillIcon;
  int? _latestSessionId;
  String? _latestSessionName;

  @override
  void initState() {
    super.initState();
    _loadLatestHistory();
  }

  Future<void> _loadLatestHistory() async {
    // 1. อ่านข้อมูลแคชเดิมจาก SharedPreferences มาแสดงผลก่อนทันที
    final prefs = await SharedPreferences.getInstance();
    final cachedSkillName = prefs.getString("latest_skill_name");
    final cachedSkillIcon = prefs.getString("latest_skill_icon");
    final cachedSessionId = prefs.getInt("latest_session_id");
    final cachedSessionName = prefs.getString("latest_session_name");

    if (mounted && cachedSkillName != null && cachedSkillName.isNotEmpty) {
      setState(() {
        _latestSkillName = cachedSkillName;
        _latestSkillIcon = cachedSkillIcon;
        _latestSessionId = cachedSessionId;
        _latestSessionName = cachedSessionName;
      });
    }

    // 2. ยิง API ไปดึงข้อมูลประวัติล่าสุดจริงจากฐานข้อมูล (Database)
    try {
      final response = await AppApi.get("user/latest-history");
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final latestHistoryRes = LatestHistoryResponse.fromJson(json);

        if (!latestHistoryRes.isError && latestHistoryRes.data != null) {
          final history = latestHistoryRes.data!;
          if (mounted) {
            setState(() {
              _latestSkillName = history.skillName;
              _latestSkillIcon = history.skillIcon;
              _latestSessionId = history.sessionId;
              _latestSessionName = history.sessionName;
            });
          }

          // ซิงค์ข้อมูลล่าสุดลง SharedPreferences ให้ตรงกับฐานข้อมูล
          await prefs.setBool("has_history", true);
          await prefs.setInt("latest_skill_id", history.skillId);
          await prefs.setString("latest_skill_name", history.skillName);
          await prefs.setString("latest_skill_icon", history.skillIcon);
          await prefs.setInt("latest_session_id", history.sessionId);
          await prefs.setString("latest_session_name", history.sessionName);
        } else if (!latestHistoryRes.isError && latestHistoryRes.data == null) {
          // ถ้าในฐานข้อมูลไม่มีประวัติเลย
          if (mounted) {
            setState(() {
              _latestSkillName = null;
              _latestSkillIcon = null;
              _latestSessionId = null;
              _latestSessionName = null;
            });
          }
          await prefs.setBool("has_history", false);
          await prefs.remove("latest_skill_id");
          await prefs.remove("latest_skill_name");
          await prefs.remove("latest_skill_icon");
          await prefs.remove("latest_session_id");
          await prefs.remove("latest_session_name");
        }
      }
    } catch (e) {
      debugPrint("Error fetching latest history from DB: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLatestSession = _latestSkillName != null && _latestSkillName!.isNotEmpty;

    return Stack(
      children: [
        // พื้นหลังสีฟ้าโค้งด้านบน (Blue Curved Background)
        ClipPath(
          clipper: _HeaderCurvedClipper(),
          child: Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5ED1EA),
                  Color(0xFF2894D7),
                ],
              ),
            ),
          ),
        ),

        // เนื้อหาด้านบน: Title Header + Card "Especially For You"
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title Header Text
                const Text(
                  'ยินดีต้อนรับสู่บทเรียน',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 22),

                // Card สีขาว "Especially For You" หรือ "Continue Learning"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2894D7).withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ส่วนข้อความและปุ่มทำต่อด้านซ้าย
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasLatestSession ? 'Continue Learning' : 'Especially For You',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              hasLatestSession
                                  ? '$_latestSkillName\n${_latestSessionName ?? "Session ล่าสุด"}'
                                  : 'Two new sections and\nmany topics.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () {
                                if (hasLatestSession && _latestSessionId != null && _latestSessionId! > 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExerciseScreen(
                                        skillTitle: _latestSessionName ?? "แบบฝึกหัด",
                                        sessionId: _latestSessionId,
                                      ),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2F6FC),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  hasLatestSession ? 'ทำต่อเลย ➡' : 'Watch Now',
                                  style: const TextStyle(
                                    color: Color(0xFF1E88E5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ส่วนภาพกราฟิกตกแต่งด้านขวา (Illustration simulation)
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: 110,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              // วงกลมตกแต่งสีสันต่างๆ
                              Positioned(
                                top: 5,
                                right: 10,
                                child: _buildDot(const Color(0xFF3B82F6), 10),
                              ),
                              Positioned(
                                top: 25,
                                left: 15,
                                child: _buildDot(const Color(0xFF10B981), 12),
                              ),
                              Positioned(
                                bottom: 40,
                                left: 5,
                                child: _buildDot(const Color(0xFFEC4899), 10),
                              ),
                              Positioned(
                                bottom: 25,
                                right: 0,
                                child: _buildDot(const Color(0xFFEF4444), 8),
                              ),
                              // ต้นไม้สีม่วง/กราฟิกคนอ่านหนังสือ
                              Positioned(
                                right: 12,
                                bottom: 0,
                                child: Container(
                                  width: 44,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 28,
                                bottom: 0,
                                child: Container(
                                  width: 40,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    hasLatestSession
                                        ? skillIconOf(_latestSkillIcon)
                                        : Icons.menu_book_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// Custom Clipper สำหรับทำคลื่นโค้งด้านบนเหมือนในดีไซน์
class _HeaderCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 50);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height - 60);
    final secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
