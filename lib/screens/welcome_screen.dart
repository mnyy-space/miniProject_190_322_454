import 'package:flutter/material.dart';
import 'package:halalsefllearning/screens/user_main_layout.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F6DA8), // พื้นหลังสีน้ำเงินด้านบน
      body: Stack(
        children: [
          // 1. โลโก้ด้านบนกึ่งกลางในพื้นที่สีน้ำเงิน
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

          // 2. การ์ดสีขาวทรงโค้งมนด้านล่าง
          Positioned.fill(
            child: ClipPath(
              clipper: _WelcomeWhiteDomeClipper(),
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    children: [
                      // เว้นระยะจากส่วนโค้งด้านบน
                      SizedBox(height: size.height * 0.22),

                      // ข้อความต้อนรับ 4 บรรทัดตามภาพ
                      const Text(
                        'Welcome',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E2022),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E2022),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'programing',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E2022),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'selflearing',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E2022),
                          letterSpacing: 0.8,
                        ),
                      ),

                      const Spacer(),

                      // ปุ่ม Start พร้อมไอคอนลูกศรหนาสีขาว
                      Padding(
                        padding: const EdgeInsets.only(bottom: 48),
                        child: Material(
                          color: const Color(0xFF0093E5),
                          borderRadius: BorderRadius.circular(16),
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserMainLayout(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 36,
                                vertical: 14,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Start',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  _ThickBlockArrow(
                                    width: 30,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
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
}

/// Custom Clipper ทำเส้นโค้งทรงโดม/เนิน (Dome Arch) ให้เหมือนในภาพ
class _WelcomeWhiteDomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final startY = size.height * 0.27;
    path.moveTo(0, startY);

    // เส้นโค้งโค้งขึ้นไปหากึ่งกลาง แล้วโค้งลงสู่ขอบขวา
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

/// วาดไอคอนลูกศรหนาแบบ Block Arrow เหมือนในปุ่ม Start ตามภาพ
class _ThickBlockArrow extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _ThickBlockArrow({
    this.width = 30,
    this.height = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _ThickBlockArrowPainter(color),
    );
  }
}

class _ThickBlockArrowPainter extends CustomPainter {
  final Color color;
  _ThickBlockArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final stemTop = size.height * 0.24;
    final stemBottom = size.height * 0.76;
    final headStart = size.width * 0.52;

    // ก้านลูกศรหนา
    path.moveTo(0, stemTop);
    path.lineTo(headStart, stemTop);
    // หัวลูกศรสามเหลี่ยม
    path.lineTo(headStart, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(headStart, size.height);
    path.lineTo(headStart, stemBottom);
    path.lineTo(0, stemBottom);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
