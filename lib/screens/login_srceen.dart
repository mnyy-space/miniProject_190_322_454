import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:halalsefllearning/config/app_config.dart';
import 'package:halalsefllearning/utils/date_util.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:halalsefllearning/screens/register_screen.dart';
import 'package:halalsefllearning/screens/welcome_screen.dart';
import 'package:halalsefllearning/screens/user_main_layout.dart';
import 'package:halalsefllearning/screens/admin/admin_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color _inputFill = Color(0xFFF1EFEF);
  static const Color _primaryBlue = Color(0xFF1B75E5);
  static const LinearGradient _primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_primaryBlue, Color(0xFF192582)],
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _doLogin();
    }
  }

  Future<(bool, String, String)> _authenRequest() async {
    String username = _usernameController.text.trim();
    String formattedDateString = DateUtil().getFormattedDate(DateTime.now());
    String combinedString = "$username&$formattedDateString";
    String authenRequestString = sha256
        .convert(utf8.encode(combinedString))
        .toString();

    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUri}/authen/authen_request"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'authen_request': authenRequestString}),
    );

    final json = jsonDecode(response.body);
    return (
      json["isError"] as bool? ?? true,
      json["data"] as String? ?? "",
      json["errorMessage"] as String? ?? "Login failed",
    );
  }

  void _doLogin() async {
    var (isError, authenToken, errorMessage) = await _authenRequest();
    if (!mounted) return;

    if (isError) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'เข้าสู่ระบบไม่สำเร็จ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    } else {
      var result = await _accessRequest(authenToken);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!result.isError) {
        if (result.roleName.toLowerCase() == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminLayout()),
          );
        } else {
          // ถ้ายังไม่มีประวัติใน history ล่าสุดเลย -> ไปหน้า WelcomeScreen
          if (!result.hasHistory) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
          } else {
            // ถ้ามีประวัติใน history แล้ว -> ไปหน้า Home โดยอิงตาม session ล่าสุด
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserMainLayout()),
            );
          }
        }
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'เข้าสู่ระบบไม่สำเร็จ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(result.errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<
    ({
      bool isError,
      String data,
      String roleName,
      bool hasHistory,
      String errorMessage,
    })
  >
  _accessRequest(String authenToken) async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text;
    String passwordEncode = sha256.convert(utf8.encode(password)).toString();
    String combinedString = "$username&$passwordEncode&$authenToken";
    String authenSignature = sha256
        .convert(utf8.encode(combinedString))
        .toString();

    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUri}/authen/access_request"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'authen_signature': authenSignature,
        'authen_token': authenToken,
      }),
    );

    final json = jsonDecode(response.body);
    String roleName = "";
    bool hasHistory = false;
    if (!json["isError"]) {
      roleName = json["data"]?["role_name"] as String? ?? "";
      hasHistory = json["data"]?["has_history"] == true;
      final latestHistory = json["data"]?["latest_history"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", json["data"]?["accessToken"] ?? "");
      await prefs.setString("username", username);
      await prefs.setString("full_name", json["data"]?["full_name"]?.toString() ?? "");
      await prefs.setString("role_name", roleName);
      await prefs.setBool("has_history", hasHistory);

      if (hasHistory && latestHistory != null) {
        await prefs.setInt(
          "latest_skill_id",
          (latestHistory["skill_id"] as num?)?.toInt() ?? 0,
        );
        await prefs.setString(
          "latest_skill_name",
          latestHistory["skill_name"] as String? ?? "",
        );
        await prefs.setString(
          "latest_skill_icon",
          latestHistory["skill_icon"] as String? ?? "",
        );
        await prefs.setInt(
          "latest_session_id",
          (latestHistory["session_id"] as num?)?.toInt() ?? 0,
        );
        await prefs.setString(
          "latest_session_name",
          latestHistory["session_name"] as String? ?? "",
        );
      } else {
        await prefs.remove("latest_skill_id");
        await prefs.remove("latest_skill_name");
        await prefs.remove("latest_skill_icon");
        await prefs.remove("latest_session_id");
        await prefs.remove("latest_session_name");
      }
    }
    return (
      isError: json["isError"] as bool? ?? true,
      data: json["data"]?["accessToken"] as String? ?? "",
      roleName: roleName,
      hasHistory: hasHistory,
      errorMessage: json["errorMessage"] as String? ?? "Login failed",
    );
  }

  void _openRegister() async {
    final username = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
    // สมัครสำเร็จจะได้ username กลับมา เติมให้ในช่อง login
    if (username != null && username.isNotEmpty) {
      _usernameController.text = username;
      _passwordController.clear();
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF8E8E93),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 15, color: Color(0xFF22292F)),
          decoration: InputDecoration(
            filled: true,
            fillColor: _inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _primaryBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE53935),
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE53935),
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(
              fontSize: 12,
              height: 1.2,
              color: Color(0xFFE53935),
            ),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: _primaryGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenHeight = constraints.maxHeight;
              final double headerHeight = (screenHeight * 0.33).clamp(220.0, 280.0);
              final double iconHeight = (headerHeight * 0.42).clamp(100.0, 122.0);
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top region with Logo & Welcome Back
                        Container(
                          width: double.infinity,
                          height: headerHeight,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/Logo login.svg',
                                height: iconHeight,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Welcome Back!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 29,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // White Sheet with top-right curve extending to the bottom edge
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(100),
                            ),
                          ),
                          alignment: Alignment.topCenter,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  28,
                                  36,
                                  28,
                                  32,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Centered Title with gradient text
                                      Center(
                                        child: ShaderMask(
                                          shaderCallback: (bounds) =>
                                              _primaryGradient.createShader(bounds),
                                          child: const Text(
                                            'Login',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 38,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Centered Subtitle
                                      const Center(
                                        child: Text(
                                          'Log in to continue your learning journey.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF8E8E93),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 28),

                                      // Username field
                                      _buildField(
                                        label: 'USERNAME',
                                        controller: _usernameController,
                                        validator: (v) =>
                                            v == null || v.trim().isEmpty
                                            ? 'กรุณากรอก Username'
                                            : null,
                                      ),
                                      const SizedBox(height: 18),

                                      // Password field
                                      _buildField(
                                        label: 'PASSWORD',
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFF94A3B8),
                                            size: 20,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'กรุณากรอก Password'
                                            : null,
                                      ),
                                      const SizedBox(height: 28),

                                      // Log in button with gradient
                                      Container(
                                        width: double.infinity,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: _primaryGradient,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _primaryBlue
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: _isLoading ? null : _login,
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.5,
                                                      ),
                                                )
                                              : const Text(
                                                  'Log in',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 28),

                                      // Don't have an account ? Sign up
                                      Center(
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            const Text(
                                              "Don't have an account ? ",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF8E8E93),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _isLoading
                                                  ? null
                                                  : _openRegister,
                                              child: const Text(
                                                'Sign up',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: _primaryBlue,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
}
