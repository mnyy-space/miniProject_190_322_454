import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halalsefllearning/screens/admin/admin_layout.dart';
import 'package:halalsefllearning/screens/login_srceen.dart';
import 'package:halalsefllearning/screens/user_main_layout.dart';
import 'package:halalsefllearning/widgets/role_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';

// จัดการข้อมูล login (token, role) และการเปลี่ยนหน้าตามสิทธิ์
class AuthSession {
  // ใช้เปลี่ยนหน้าจากที่ที่ไม่มี BuildContext เช่น AppApi ตอน token หมดอายุ
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const List<String> knownRoles = ['admin', 'user'];

  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('role_name') ?? '').toLowerCase();
  }

  // มี token และยังไม่หมดอายุ (อ่าน exp จาก payload ของ JWT)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    if (token.isEmpty) return false;
    try {
      final parts = token.split('.');
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'] as int?;
      if (exp == null) return true;
      return DateTime.now().millisecondsSinceEpoch < exp * 1000;
    } catch (_) {
      return false;
    }
  }

  // หน้าแรกของแต่ละ role ครอบด้วย RoleGuard เสมอ
  static Widget homeForRole(String roleName) {
    if (roleName.toLowerCase() == 'admin') {
      return const RoleGuard(allowedRoles: ['admin'], child: AdminLayout());
    }
    return const RoleGuard(allowedRoles: ['user'], child: UserMainLayout());
  }

  static Future<void> logout({String? message}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
    if (message != null && navigator.mounted) {
      showDialog(
        context: navigator.context,
        builder: (_) => AlertDialog(content: Text(message)),
      );
    }
  }
}
