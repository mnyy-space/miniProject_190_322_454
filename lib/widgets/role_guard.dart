import 'package:flutter/material.dart';
import 'package:halalsefllearning/utils/auth_session.dart';

// แสดง child เฉพาะผู้ที่ login แล้วและมี role อยู่ใน allowedRoles
// ไม่ได้ login / token หมดอายุ -> กลับหน้า login
// login แล้วแต่ role ไม่ตรง -> ไปหน้าแรกของ role ตัวเอง
class RoleGuard extends StatefulWidget {
  final List<String> allowedRoles;
  final Widget child;

  const RoleGuard({super.key, required this.allowedRoles, required this.child});

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    if (!await AuthSession.isLoggedIn()) {
      AuthSession.logout(message: 'กรุณาเข้าสู่ระบบ');
      return;
    }

    final role = await AuthSession.getRole();
    if (!AuthSession.knownRoles.contains(role)) {
      AuthSession.logout(message: 'ไม่มีสิทธิ์เข้าถึง');
      return;
    }
    final allowed = widget.allowedRoles.map((r) => r.toLowerCase()).contains(role);
    if (!mounted) return;

    if (allowed) {
      setState(() => _allowed = true);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AuthSession.homeForRole(role)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_allowed) return widget.child;
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
