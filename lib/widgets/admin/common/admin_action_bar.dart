import 'package:flutter/material.dart';

/// ข้อมูลของ dropdown กรองข้อมูล 1 ตัวใน [AdminActionBar]
class AdminFilter {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const AdminFilter({
    required this.value,
    required this.items,
    required this.onChanged,
  });
}

/// แถบค้นหา + ตัวกรอง + ปุ่มเพิ่มรายการใหม่
/// - Desktop: ทุกอย่างอยู่แถวเดียว
/// - Mobile: ช่องค้นหาอยู่บน ตัวกรองและปุ่มเพิ่มเรียงแถวละ 2 ช่อง
class AdminActionBar extends StatelessWidget {
  final bool isMobile;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final List<AdminFilter> filters;
  final String addLabel;
  final Color addColor;
  final VoidCallback onAdd;

  const AdminActionBar({
    super.key,
    required this.isMobile,
    required this.searchHint,
    required this.onSearchChanged,
    required this.filters,
    required this.addLabel,
    required this.onAdd,
    this.addColor = const Color(0xFF0284C7),
  });

  @override
  Widget build(BuildContext context) {
    final search = AdminSearchField(hintText: searchHint, onChanged: onSearchChanged);
    return isMobile ? _buildMobile(search) : _buildDesktop(search);
  }

  Widget _buildDesktop(Widget search) {
    return Row(
      children: [
        Expanded(child: search),
        for (final filter in filters) ...[
          const SizedBox(width: 12),
          AdminFilterDropdown(
            value: filter.value,
            items: filter.items,
            onChanged: filter.onChanged,
          ),
        ],
        const SizedBox(width: 12),
        AdminAddButton(label: addLabel, color: addColor, onPressed: onAdd),
      ],
    );
  }

  Widget _buildMobile(Widget search) {
    final List<Widget> cells = [
      for (final filter in filters)
        Expanded(
          child: AdminFilterDropdown(
            value: filter.value,
            items: filter.items,
            onChanged: filter.onChanged,
            isExpanded: true,
          ),
        ),
      AdminAddButton(label: 'เพิ่มใหม่', color: addColor, onPressed: onAdd, compact: true),
    ];

    return Column(
      children: [
        search,
        for (int i = 0; i < cells.length; i += 2) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              cells[i],
              if (i + 1 < cells.length) ...[
                const SizedBox(width: 10),
                cells[i + 1],
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// ช่องค้นหาพร้อมไอคอนแว่นขยาย
class AdminSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const AdminSearchField({super.key, required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

/// Dropdown สำหรับกรองรายการ (สถานะ / ประเภท / Skill)
class AdminFilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool isExpanded;

  const AdminFilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: isExpanded,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: items
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

/// ปุ่ม "+ เพิ่ม ... ใหม่"
class AdminAddButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool compact;

  const AdminAddButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      icon: Icon(Icons.add_rounded, size: compact ? 18 : 20),
      label: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: compact ? 13 : 14),
      ),
    );
  }
}
