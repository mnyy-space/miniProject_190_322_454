import 'package:flutter/material.dart';

class AdminTopbarWidget extends StatefulWidget {
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
  State<AdminTopbarWidget> createState() => _AdminTopbarWidgetState();
}

class _AdminTopbarWidgetState extends State<AdminTopbarWidget> {
  String _selectedLang = 'TH';
  bool _isDarkMode = false;

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
          if (widget.showMenuButton) ...[
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF1E293B),
                size: 24,
              ),
              onPressed: widget.onMenuPressed,
              tooltip: 'เมนู',
            ),
            const SizedBox(width: 8),
          ],

          // Page Title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: 0.2,
            ),
          ),

          const Spacer(),

          // Language Switcher (TH / EN)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLangButton('TH'),
                _buildLangButton('EN'),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Theme Toggle Icon
          InkWell(
            onTap: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Icon(
                _isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 18,
                color: _isDarkMode
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF64748B),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Admin Profile Avatar
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String lang) {
    final bool isSelected = _selectedLang == lang;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLang = lang;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          lang,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
