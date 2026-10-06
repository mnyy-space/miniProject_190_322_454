import 'package:flutter/material.dart';

class AdminTopbarWidget extends StatelessWidget {
  final String title;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  const AdminTopbarWidget({
    super.key,
    required this.title,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Hamburger Menu for Mobile/Tablet
          if (showMenuButton) ...[
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF1E293B),
                size: 24,
              ),
              onPressed: onMenuPressed,
              tooltip: 'เมนู',
            ),
            const SizedBox(width: 8),
          ],

          // Page Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
