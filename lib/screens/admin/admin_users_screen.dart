import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/admin/user_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_action_bar.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_list_widgets.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_page_header.dart';
import 'package:halalsefllearning/widgets/admin/user/user_detail_dialog.dart';
import 'package:halalsefllearning/widgets/admin/user/user_form_dialog.dart';
import 'package:halalsefllearning/widgets/admin/user/user_list_views.dart';
import 'package:halalsefllearning/widgets/admin/user/user_role_stats_cards.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserItemData> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRoleFilter = 'ทุกบทบาท';
  String _currentUsername = 'admin';

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
    _loadUsers();
  }

  Future<void> _loadCurrentUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      if (username != null && username.isNotEmpty && mounted) {
        setState(() => _currentUsername = username);
      }
    } catch (_) {}
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final List list = AppApi.unwrap(await AppApi.get('admin/user')) ?? [];
      if (!mounted) return;
      setState(() => _users = list.map((item) => UserItemData.fromJson(item)).toList());
    } catch (e) {
      _showError('โหลดข้อมูลผู้ใช้ไม่สำเร็จ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) showAdminError(context, message);
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _confirmDeleteUser(UserItemData user) async {
    if (user.username == 'admin') {
      _showError('ไม่สามารถลบบัญชีผู้ดูแลระบบหลัก (admin) ได้ เพื่อความปลอดภัยของระบบ');
      return;
    }

    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'ลบข้อมูลผู้ใช้',
      itemName: '${user.username} (${user.fullName.isNotEmpty ? user.fullName : user.roleName})',
    );
    if (!confirmed) return;

    try {
      AppApi.unwrap(await AppApi.delete('admin/user/${user.id}'));
      _showSuccess('ลบผู้ใช้ "${user.username}" สำเร็จ');
      _loadUsers();
    } catch (e) {
      _showError('ลบผู้ใช้ไม่สำเร็จ: $e');
    }
  }

  Future<bool> _saveUser(UserItemData? existingUser, Map<String, dynamic> body) async {
    try {
      if (existingUser == null) {
        AppApi.unwrap(await AppApi.post('admin/user', body));
        _showSuccess('เพิ่มข้อมูลผู้ใช้ใหม่สำเร็จ');
      } else {
        AppApi.unwrap(await AppApi.put('admin/user/${existingUser.id}', body));
        _showSuccess('แก้ไขข้อมูลผู้ใช้ "${existingUser.username}" สำเร็จ');
      }
    } catch (e) {
      _showError('บันทึกข้อมูลผู้ใช้ไม่สำเร็จ: $e');
      return false;
    }
    _loadUsers();
    return true;
  }

  void _showUserFormDialog([UserItemData? existingUser]) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        existingUser: existingUser,
        onSubmit: (body) => _saveUser(existingUser, body),
      ),
    );
  }

  void _showUserDetailDialog(UserItemData user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(user: user),
    );
  }

  List<UserItemData> get _filteredUsers {
    final query = _searchQuery.toLowerCase().trim();
    return _users.where((user) {
      final matchesSearch = query.isEmpty ||
          user.fullName.toLowerCase().contains(query) ||
          user.username.toLowerCase().contains(query) ||
          user.learningContent.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);

      final matchesRole = _selectedRoleFilter == 'ทุกบทบาท' ||
          user.roleName.toLowerCase() == _selectedRoleFilter.toLowerCase();

      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 860;
    final users = _filteredUsers;

    final adminCount = _users.where((u) => u.isAdmin).length;
    final userCount = _users.where((u) => !u.isAdmin).length;

    final callbacks = UserRowCallbacks(
      onView: _showUserDetailDialog,
      onEdit: _showUserFormDialog,
      onDelete: _confirmDeleteUser,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            AdminPageHeader(
              icon: Icons.people_alt_rounded,
              title: 'จัดการข้อมูลผู้ใช้',
              subtitle: 'ระบบบริหารจัดการบัญชีผู้ใช้งาน สิทธิ์ และตรวจสอบเนื้อหาที่เรียน',
            ),
            const SizedBox(height: 20),

            // จำนวนผู้ใช้แยกตาม role (Interactive Stats Cards)
            UserRoleStatsCards(
              totalCount: _users.length,
              adminCount: adminCount,
              userCount: userCount,
              selectedRole: _selectedRoleFilter,
              onSelectRole: (role) {
                setState(() => _selectedRoleFilter = role);
              },
            ),
            const SizedBox(height: 20),

            // Action Bar (ค้นหา + กรอง role + ปุ่มเพิ่มข้อมูลผู้ใช้)
            AdminActionBar(
              isMobile: isMobile,
              searchHint: 'ค้นหาชื่อ - นามสกุล, username หรือเนื้อหาที่เรียน...',
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              filters: [
                AdminFilter(
                  value: _selectedRoleFilter,
                  items: const ['ทุกบทบาท', 'user', 'admin'],
                  onChanged: (val) => setState(() => _selectedRoleFilter = val),
                ),
              ],
              addLabel: 'เพิ่มข้อมูลผู้ใช้',
              addColor: const Color(0xFF2563EB),
              onAdd: () => _showUserFormDialog(),
            ),
            const SizedBox(height: 20),

            // User List / Table (แสดงข้อมูลผู้ใช้, แก้ไข, ลบ)
            if (_isLoading)
              const AdminLoadingView()
            else if (users.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(Icons.people_outline_rounded, color: Color(0xFF94A3B8), size: 28),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ไม่พบข้อมูลผู้ใช้งานที่ตรงกับเงื่อนไข',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ลองเปลี่ยนคำค้นหา หรือรีเซ็ตตัวกรองบทบาท',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ],
                ),
              )
            else if (isMobile)
              AdminCardList<UserItemData>(
                items: users,
                itemBuilder: (user) => UserMobileCard(
                  user: user,
                  callbacks: callbacks,
                  currentUsername: _currentUsername,
                ),
              )
            else
              UserDataTable(
                users: users,
                callbacks: callbacks,
                currentUsername: _currentUsername,
              ),
          ],
        ),
      ),
    );
  }
}


