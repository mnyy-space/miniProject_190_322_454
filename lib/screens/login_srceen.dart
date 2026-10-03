import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:halalsefllearning/config/app_config.dart';
import 'package:halalsefllearning/utils/date_util.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:halalsefllearning/screens/admin/admin_layout.dart';
import 'package:halalsefllearning/screens/user_main_layout.dart';
import 'package:halalsefllearning/screens/welcome_screen.dart';

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
  // bool _rememberMe = false;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _doLogin(context);
    }
  }

  Future<(bool, String, String)> _authenRequest() async {
    String username = _usernameController.text;
    String formattedDateString = DateUtil().getFormattedDate(DateTime.now());
    String combinedString = "$username&$formattedDateString";
    String authenRequestString = sha256
        .convert(utf8.encode(combinedString))
        .toString();
    
    print("${AppConfig.apiBaseUri}/authen/authen_request");

    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUri}/authen/authen_request"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'authen_request': authenRequestString}),
    );

    

    final json = jsonDecode(response.body);
    return (
      json["isError"] as bool,
      json["data"] as String? ?? "",
      json["errorMessage"] as String? ?? "Login failed",
    );
  }

  void _doLogin(BuildContext context) async {
    var (isError, authenToken, errorMessage) = await _authenRequest();
    if (!mounted) return;

    if (isError) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(content: Text(errorMessage)),
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
          builder: (_) => AlertDialog(content: Text(result.errorMessage)),
        );
      }
    }
  }

  Future<({bool isError, String data, String roleName, bool hasHistory, String errorMessage})> _accessRequest(
    String authenToken,
  ) async {
    String username = _usernameController.text;
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
      await prefs.setString("access_token", json["data"]["accessToken"] ?? "");
      await prefs.setString("username", _usernameController.text);
      await prefs.setString("role_name", roleName);
      await prefs.setBool("has_history", hasHistory);

      if (hasHistory && latestHistory != null) {
        await prefs.setInt("latest_skill_id", (latestHistory["skill_id"] as num?)?.toInt() ?? 0);
        await prefs.setString("latest_skill_name", latestHistory["skill_name"] as String? ?? "");
        await prefs.setInt("latest_session_id", (latestHistory["session_id"] as num?)?.toInt() ?? 0);
        await prefs.setString("latest_session_name", latestHistory["session_name"] as String? ?? "");
      } else {
        await prefs.remove("latest_skill_id");
        await prefs.remove("latest_skill_name");
        await prefs.remove("latest_session_id");
        await prefs.remove("latest_session_name");
      }
    }
    return (
      isError: json["isError"] as bool,
      data: json["data"]?["accessToken"] as String? ?? "",
      roleName: roleName,
      hasHistory: hasHistory,
      errorMessage: json["errorMessage"] as String? ?? "Login failed",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 135, 255, 163), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/logo1.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'กรุณากรอก Username' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'กรุณากรอก Password' : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
