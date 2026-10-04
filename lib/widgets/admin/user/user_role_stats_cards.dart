import 'package:flutter/material.dart';

/// การ์ดสรุปจำนวนผู้ใช้แยกตาม Role พร้อมคลิกเพื่อกรองข้อมูลได้ทันที (Interactive KPI Cards)
class UserRoleStatsCards extends StatelessWidget {
  final int totalCount;
  final int adminCount;
  final int userCount;
  final String selectedRole; // 'ทุกบทบาท', 'admin', 'user'
  final ValueChanged<String> onSelectRole;

  const UserRoleStatsCards({
    super.key,
    required this.totalCount,
    required this.adminCount,
    required this.userCount,
    required this.selectedRole,
    required this.onSelectRole,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 760;

    final cards = [
      _StatCard(
        title: 'ผู้ใช้งานทั้งหมด',
        subtitle: 'รวมทุกบทบาทในระบบ',
        count: totalCount,
        icon: Icons.people_alt_rounded,
        accentColor: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        isSelected: selectedRole == 'ทุกบทบาท',
        onTap: () => onSelectRole('ทุกบทบาท'),
      ),
      _StatCard(
        title: 'ผู้ดูแลระบบ (Admin)',
        subtitle: 'สิทธิ์จัดการระบบและการเรียน',
        count: adminCount,
        icon: Icons.admin_panel_settings_rounded,
        accentColor: const Color(0xFF4F46E5),
        bgColor: const Color(0xFFEEF2FF),
        isSelected: selectedRole.toLowerCase() == 'admin',
        onTap: () => onSelectRole('admin'),
      ),
      _StatCard(
        title: 'ผู้ใช้งานทั่วไป (User)',
        subtitle: 'ผู้เรียนแบบ Self-learning',
        count: userCount,
        icon: Icons.school_rounded,
        accentColor: const Color(0xFF059669),
        bgColor: const Color(0xFFECFDF5),
        isSelected: selectedRole.toLowerCase() == 'user',
        onTap: () => onSelectRole('user'),
      ),
    ];

    if (isNarrow) {
      return Column(
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: card,
        )).toList(),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accentColor : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? accentColor.withAlpha(30)
                    : const Color(0x05000000),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? accentColor : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'คน',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'กำลังเลือก',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
