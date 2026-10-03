import 'package:flutter/material.dart';
import 'package:halalsefllearning/screens/login_srceen.dart';
import 'package:halalsefllearning/screens/admin/admin_exercises_screen.dart';
import 'package:halalsefllearning/screens/admin/admin_goals_screen.dart';
import 'package:halalsefllearning/screens/admin/admin_skills_screen.dart';
import 'package:halalsefllearning/screens/admin/admin_sessions_screen.dart';
import 'package:halalsefllearning/screens/admin/admin_users_screen.dart';
import 'package:halalsefllearning/widgets/admin/admin_sidebar_widget.dart';
import 'package:halalsefllearning/widgets/admin/admin_topbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<String> _titles = [
    'จัดการ Skill',
    'จัดการ Goal',
    'จัดการ Exercise',
    'จัดการ Session',
    'จัดการข้อมูลผู้ใช้',
  ];

  final List<Widget> _screens = const [
    AdminSkillsScreen(),
    AdminGoalsScreen(),
    AdminExercisesScreen(),
    AdminSessionsScreen(),
    AdminUsersScreen(),
  ];

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // ถ้าหน้าจอเล็กและเปิด Drawer อยู่ ให้ปิด Drawer อัตโนมัติเมื่อเลือกเมนู
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text(
              'ยืนยันการออกจากระบบ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text('คุณต้องการออกจากระบบ Admin หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // กำหนด breakpoint สำหรับจอคอม (Desktop Web >= 1024px)
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      // บนมือถือ/แท็บเล็ต ให้ใช้ Drawer เป็น Sidebar
      drawer: isDesktop
          ? null
          : Drawer(
              child: AdminSidebarWidget(
                selectedIndex: _selectedIndex,
                onItemSelected: _onMenuItemSelected,
                onLogout: _handleLogout,
              ),
            ),
      body: Row(
        children: [
          // บน Desktop ให้แสดง Sidebar ถาวรด้านซ้าย
          if (isDesktop)
            AdminSidebarWidget(
              selectedIndex: _selectedIndex,
              onItemSelected: _onMenuItemSelected,
              onLogout: _handleLogout,
            ),

          // พื้นที่ด้านขวา: Topbar + เนื้อหาแต่ละหน้า
          Expanded(
            child: Column(
              children: [
                // Topbar
                AdminTopbarWidget(
                  title: _titles[_selectedIndex],
                  showMenuButton: !isDesktop,
                  onMenuPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),

                // Main Content Screen
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
