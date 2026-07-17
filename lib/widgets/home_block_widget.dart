import 'package:flutter/material.dart';

class HomeBlockWidget extends StatelessWidget {
  const HomeBlockWidget({super.key});

  @override
  Widget build(BuildContext context) {
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

        // เนื้อหาด้านบน: ปุ่ม Back และ Title "Find Your Courses" + Card "Especially For You"
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ปุ่มย้อนกลับ (Back Button Icon Container)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),

                const SizedBox(height: 16),

                // Title Header Text
                const Text(
                  'Find Your Courses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Card สีขาว "Especially For You" (Promo Card)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2894D7).withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ส่วนข้อความและปุ่ม Watch Now ด้านซ้าย
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Especially For You',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Two new sections and\nmany topics.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2F6FC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Watch Now',
                                style: TextStyle(
                                  color: Color(0xFF1E88E5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
                                  child: const Icon(
                                    Icons.menu_book_rounded,
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
