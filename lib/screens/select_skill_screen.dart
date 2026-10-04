import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/skills_model.dart';
import 'package:halalsefllearning/screens/user_main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectSkillScreen extends StatefulWidget {
  const SelectSkillScreen({super.key});

  @override
  State<SelectSkillScreen> createState() => _SelectSkillScreenState();
}

class _SelectSkillScreenState extends State<SelectSkillScreen> {
  List<SkillsModel> _skills = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  Future<void> _fetchSkills() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AppApi.get("skill");
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final skillsResponse = SkillsResponse.fromJson(json);

        if (!skillsResponse.isError) {
          setState(() {
            _skills = skillsResponse.data;
            _isLoading = false;
          });
          return;
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = skillsResponse.errorMessage.isNotEmpty
                ? skillsResponse.errorMessage
                : "ไม่พบข้อมูล Skill";
          });
          return;
        }
      }

      setState(() {
        _isLoading = false;
        _errorMessage = "ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ (Code: ${response.statusCode})";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "เกิดข้อผิดพลาดในการโหลดข้อมูล: $e";
      });
    }
  }

  void _onSelectSkill(SkillsModel skill) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("selected_skill_id", skill.skillId);
    await prefs.setString("selected_skill_name", skill.skillName);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UserMainLayout(skillId: skill.skillId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F6DA8), // พื้นหลังสีน้ำเงินด้านบน
      body: Stack(
        children: [
          // 1. ส่วนบน: โลโก้ตรงกลาง
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0D0),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logo1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // 2. ปุ่มย้อนกลับ (ถ้ามีหน้าก่อนหน้า)
          if (Navigator.canPop(context))
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 12),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

          // 3. การ์ดสีขาวทรงโดมโค้งมนด้านล่าง
          Positioned.fill(
            child: ClipPath(
              clipper: _SelectSkillWhiteDomeClipper(),
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    children: [
                      // เว้นระยะจากส่วนโค้งด้านบน
                      SizedBox(height: size.height * 0.20),

                      // หัวข้อ "Select Skill"
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Select Skill',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E2022),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // รายการ Skill Cards
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF0F6DA8),
                                ),
                              )
                            : _errorMessage != null
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            size: 48,
                                            color: Colors.red.shade400,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            _errorMessage!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: _fetchSkills,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0093E5),
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('ลองใหม่'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : _skills.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.school_outlined,
                                              size: 54,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              "ยังไม่มี Skill ที่เปิดใช้งานในขณะนี้",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 36),
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: _skills.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 16),
                                        itemBuilder: (context, index) {
                                          final skill = _skills[index];
                                          return _buildSkillCard(skill);
                                        },
                                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(SkillsModel skill) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black,
          width: 2.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onSelectSkill(skill),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    skill.skillName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2022),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Clipper ทรงโดม/เนิน (Dome Arch) สไตล์เดียวกับหน้า Welcome
class _SelectSkillWhiteDomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final startY = size.height * 0.27;
    path.moveTo(0, startY);

    path.cubicTo(
      size.width * 0.12,
      size.height * 0.20,
      size.width * 0.38,
      size.height * 0.20,
      size.width * 0.65,
      size.height * 0.21,
    );
    path.quadraticBezierTo(
      size.width * 0.88,
      size.height * 0.22,
      size.width,
      size.height * 0.28,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
