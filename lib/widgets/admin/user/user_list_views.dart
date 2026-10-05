import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/user_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_list_widgets.dart';

/// Callback actions สำหรับรายการผู้ใช้แต่ละแถว
class UserRowCallbacks {
  final ValueChanged<UserItemData> onView;
  final ValueChanged<UserItemData> onEdit;
  final ValueChanged<UserItemData> onDelete;

  const UserRowCallbacks({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });
}

/// ตารางข้อมูลผู้ใช้บน Desktop พร้อม UX/UI ที่สวยงามและแสดงครบตามข้อกำหนด
class UserDataTable extends StatelessWidget {
  final List<UserItemData> users;
  final UserRowCallbacks callbacks;
  final String currentUsername;

  const UserDataTable({
    super.key,
    required this.users,
    required this.callbacks,
    this.currentUsername = '',
  });

  @override
  Widget build(BuildContext context) {
    return AdminTableCard(
      minWidth: 850,
      columns: const [
        DataColumn(label: Text('ชื่อ - นามสกุล')),
        DataColumn(label: Text('Username')),
        DataColumn(label: Text('เนื้อหาที่เรียน')),
        DataColumn(label: Text('บทบาท (Role)')),
        DataColumn(label: Text('การจัดการ')),
      ],
      rows: users.map(_buildRow).toList(),
    );
  }

  DataRow _buildRow(UserItemData user) {
    final initials = user.fullName.trim().isNotEmpty
        ? user.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U';

    final bool isCurrentUser = currentUsername.isNotEmpty &&
        user.username.trim().toLowerCase() == currentUsername.trim().toLowerCase();

    return DataRow(
      cells: [
        // ชื่อ - นามสกุล พร้อม Avatar
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: user.isAdmin ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: user.isAdmin ? const Color(0xFF2563EB) : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  user.fullName.isEmpty ? '-' : user.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Text(
                    'คุณ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Username
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '@${user.username}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ),

        // เนื้อหาที่เรียน
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 15,
                  color: user.learningContent == '-' ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    user.learningContent == '-' ? 'ยังไม่มีประวัติการเรียน' : user.learningContent,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 13,
                      color: user.learningContent == '-'
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF334155),
                      fontWeight: user.learningContent == '-' ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // บทบาท (Role)
        DataCell(
          _RoleBadge(isAdmin: user.isAdmin, roleName: user.roleName),
        ),

        // การจัดการ (ดู, แก้ไข, ลบ)
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 19, color: Color(0xFF64748B)),
                tooltip: 'ดูรายละเอียด',
                onPressed: () => callbacks.onView(user),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 19, color: Color(0xFF2563EB)),
                tooltip: 'แก้ไขข้อมูลผู้ใช้',
                onPressed: () => callbacks.onEdit(user),
              ),
              if (isCurrentUser)
                const IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFFCBD5E1)),
                  tooltip: 'ไม่สามารถลบบัญชีของตัวเองได้',
                  onPressed: null,
                )
              else
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFFEF4444)),
                  tooltip: 'ลบผู้ใช้งาน',
                  onPressed: () => callbacks.onDelete(user),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// การ์ดข้อมูลผู้ใช้ 1 รายการบน Mobile
class UserMobileCard extends StatelessWidget {
  final UserItemData user;
  final UserRowCallbacks callbacks;
  final String currentUsername;

  const UserMobileCard({
    super.key,
    required this.user,
    required this.callbacks,
    this.currentUsername = '',
  });

  @override
  Widget build(BuildContext context) {
    final initials = user.fullName.trim().isNotEmpty
        ? user.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U';

    final bool isCurrentUser = currentUsername.isNotEmpty &&
        user.username.trim().toLowerCase() == currentUsername.trim().toLowerCase();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + ชื่อ - นามสกุล + Role Badge
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: user.isAdmin ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: user.isAdmin ? const Color(0xFF2563EB) : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.fullName.isEmpty ? '-' : user.fullName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: const Text(
                              'คุณ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              _RoleBadge(isAdmin: user.isAdmin, roleName: user.roleName),
            ],
          ),
          const SizedBox(height: 12),

          // กล่องเนื้อหาที่เรียน
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'เนื้อหาที่เรียน',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.learningContent == '-' ? 'ยังไม่มีประวัติการเรียน' : user.learningContent,
                        style: TextStyle(
                          fontSize: 13,
                          color: user.learningContent == '-'
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ปุ่มการจัดการ: ดู / แก้ไข / ลบ
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => callbacks.onView(user),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('ดู', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  backgroundColor: const Color(0xFFEFF6FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => callbacks.onEdit(user),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('แก้ไข', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              if (!isCurrentUser) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => callbacks.onDelete(user),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('ลบ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// ป้ายกำกับ Role (Admin vs User) แบบ Modern Pill
class _RoleBadge extends StatelessWidget {
  final bool isAdmin;
  final String roleName;

  const _RoleBadge({required this.isAdmin, required this.roleName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdmin ? const Color(0xFFBFDBFE) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
            size: 13,
            color: isAdmin ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
          ),
          const SizedBox(width: 4),
          Text(
            isAdmin ? 'Admin' : 'User',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isAdmin ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}

