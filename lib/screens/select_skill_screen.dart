import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/skills_model.dart';
import 'package:halalsefllearning/screens/user_main_layout.dart';
import 'package:halalsefllearning/utils/skill_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _primaryBlue = Color(0xFF1569A8);
const Color _textDark = Color(0xFF1E2022);

class SelectSkillScreen extends StatefulWidget {
  const SelectSkillScreen({super.key});

  @override
  State<SelectSkillScreen> createState() => _SelectSkillScreenState();
}

class _SelectSkillScreenState extends State<SelectSkillScreen> {
  List<SkillsModel> _skills = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedSkillId;

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
          // เลือก Skill ที่เคยเลือกไว้ล่าสุดให้อัตโนมัติ (ถ้ายังมีอยู่ในรายการ)
          final prefs = await SharedPreferences.getInstance();
          final savedId = prefs.getInt("selected_skill_id");
          setState(() {
            _skills = skillsResponse.data;
            _selectedSkillId = _skills.any((s) => s.skillId == savedId)
                ? savedId
                : null;
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

  Future<void> _onContinue() async {
    final skill = _skills.firstWhere((s) => s.skillId == _selectedSkillId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("selected_skill_id", skill.skillId);
    await prefs.setString("selected_skill_name", skill.skillName);
    await prefs.setString("selected_skill_icon", skill.skillIcon);

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C5FB8), Color(0xFF2A3FA0)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            if (Navigator.canPop(context))
              Positioned(
                left: 4,
                top: 4,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 44),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/select_skill_screen_icon.svg',
                    width: 72,
                    height: 90,
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                            children: [
                              TextSpan(text: 'Select '),
                              TextSpan(
                                text: 'Skill',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose your preferred\nSkill to continue',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryBlue),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchSkills,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ลองใหม่'),
              ),
            ],
          ),
        ),
      );
    }

    if (_skills.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 54, color: Colors.grey.shade400),
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
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: _skills.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _buildSkillCard(_skills[index]),
    );
  }

  Widget _buildSkillCard(SkillsModel skill) {
    final isSelected = skill.skillId == _selectedSkillId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? _primaryBlue : const Color(0xFFDADCE0),
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: _primaryBlue.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedSkillId = skill.skillId),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F1F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    skillIconOf(skill.skillIcon),
                    color: isSelected ? _primaryBlue : Colors.grey.shade500,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.skillName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F0FB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'จำนวนเลเวล : ${skill.sessionCount}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: 8, right: 4),
                    child: Icon(Icons.check_rounded, color: _primaryBlue, size: 28),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selectedSkillId == null ? null : _onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
