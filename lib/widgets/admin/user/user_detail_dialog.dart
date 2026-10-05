import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/user_item_data.dart';

/// Dialog แสดงรายละเอียดบัญชีผู้ใช้
class UserDetailDialog extends StatelessWidget {
  final UserItemData user;

  const UserDetailDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user.fullName.trim().isNotEmpty
        ? user.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: user.isAdmin ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: user.isAdmin ? const Color(0xFF2563EB) : const Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.isEmpty ? user.username : user.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user.username}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24, color: Color(0xFFF1F5F9)),
            _buildInfoRow('รหัสผู้ใช้ (User ID):', '#${user.id}'),
            const SizedBox(height: 10),
            _buildInfoRow('ชื่อบัญชีผู้ใช้ (Username):', user.username),
            const SizedBox(height: 10),
            _buildInfoRow('ชื่อ - นามสกุล:', user.fullName.isEmpty ? '-' : user.fullName),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'บทบาท (Role):',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isAdmin ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: user.isAdmin ? const Color(0xFFBFDBFE) : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                        size: 13,
                        color: user.isAdmin ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.isAdmin ? 'Admin (ผู้ดูแลระบบ)' : 'User (ผู้ใช้งานทั่วไป)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: user.isAdmin ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // เนื้อหาที่เรียน
            const Text(
              'เนื้อหาที่เรียน:',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.learningContent == '-' ? 'ยังไม่มีประวัติการเรียน' : user.learningContent,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: user.learningContent == '-' ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (user.createDate != null && user.createDate!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow('วันที่สร้างบัญชี:', user.createDate!),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ปิด', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}

