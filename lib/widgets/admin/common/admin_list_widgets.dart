import 'package:flutter/material.dart';

/// ตัวโหลดข้อมูลกลางหน้า
class AdminLoadingView extends StatelessWidget {
  const AdminLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      ),
    );
  }
}

/// กรอบการ์ดสีขาวที่ห่อ DataTable บน Desktop (เลื่อนแนวนอนได้ถ้าจอแคบ)
class AdminTableCard extends StatelessWidget {
  final double minWidth;
  final List<DataColumn> columns;
  final List<DataRow> rows;

  const AdminTableCard({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 900,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              horizontalMargin: 24,
              columnSpacing: 28,
              headingTextStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }
}

/// รายการการ์ดบน Mobile (อยู่ใน SingleChildScrollView ของหน้า จึงไม่ scroll เอง)
class AdminCardList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;

  const AdminCardList({super.key, required this.items, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => AdminListCard(child: itemBuilder(items[index])),
    );
  }
}

/// การ์ดสีขาวขอบมนสำหรับแต่ละรายการบน Mobile
class AdminListCard extends StatelessWidget {
  final Widget child;

  const AdminListCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// ปุ่มเล็กทรงเม็ดยา (ดู / แก้ไข / ลบ) ในตาราง
class AdminPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AdminPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF2563EB)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// กลุ่มปุ่ม ดู / แก้ไข / ลบ (ส่ง callback เป็น null เพื่อซ่อนปุ่มนั้น)
class AdminRowActions extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AdminRowActions({
    super.key,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      if (onView != null)
        AdminPillButton(icon: Icons.visibility_outlined, label: 'ดู', onTap: onView!),
      if (onEdit != null)
        AdminPillButton(icon: Icons.edit_outlined, label: 'แก้ไข', onTap: onEdit!),
      if (onDelete != null)
        AdminPillButton(icon: Icons.delete_outline, label: 'ลบ', onTap: onDelete!),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          buttons[i],
        ],
      ],
    );
  }
}

/// สวิตช์เปิด/ปิดสถานะ พร้อมข้อความ Active / Inactive (ถ้า [showLabel])
class AdminStatusSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showLabel;

  const AdminStatusSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final toggle = Switch(
      value: value,
      activeThumbColor: const Color(0xFF10B981),
      onChanged: onChanged,
    );
    if (!showLabel) return toggle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        toggle,
        const SizedBox(width: 4),
        Text(
          value ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: value ? const Color(0xFF059669) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}

enum AdminTagTone { neutral, green, blue }

/// ป้ายกำกับเล็ก ๆ เช่น Tier, ประเภทโจทย์, ชื่อ Skill
class AdminTag extends StatelessWidget {
  final String text;
  final AdminTagTone tone;
  final bool dense;

  const AdminTag(
    this.text, {
    super.key,
    this.tone = AdminTagTone.neutral,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground) = switch (tone) {
      AdminTagTone.neutral => (
          const Color(0xFFF1F5F9),
          const Color(0xFFCBD5E1),
          const Color(0xFF475569),
        ),
      AdminTagTone.green => (
          const Color(0xFFECFDF5),
          const Color(0xFFA7F3D0),
          const Color(0xFF059669),
        ),
      AdminTagTone.blue => (
          const Color(0xFFEFF6FF),
          const Color(0xFFBFDBFE),
          const Color(0xFF2563EB),
        ),
    };

    return Container(
      padding: dense
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(dense ? 6 : 8),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: dense ? 11 : 12,
          fontWeight: tone == AdminTagTone.neutral ? FontWeight.w600 : FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
