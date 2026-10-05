import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:halalsefllearning/screens/select_skill_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _dark = Color(0xFF1E2022);
  static const Color _blue = Color(0xFF1A6FA8);
  static const Color _buttonBlue = Color(0xFF0093E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // หัวข้อ WELCOME ตัวหนา เว้นระยะตัวอักษรกว้าง
                const Text(
                  'WELCOME',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: _dark,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 28),

                // ไอคอนหลอดไฟบนหนังสือ
                SvgPicture.asset(
                  'assets/welcome_icon_2.svg',
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 36),

                // ชื่อแอป Programing + </> selflearing
                const Text(
                  'Programing',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: _blue,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/welcome_screen_code.svg',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'selflearing',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),

                // ปุ่ม Let's Start
                Material(
                  color: _buttonBlue,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectSkillScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Let's Start",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
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
