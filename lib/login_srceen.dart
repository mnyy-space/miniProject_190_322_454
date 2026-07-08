import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:halalsefllearning/config/app_config.dart';
import 'package:halalsefllearning/utils/date_util.dart';
import "package:shared_preferences/shared_preferences.dart";

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
  bool _rememberMe = false;
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
    String authenRequestString = sha256.convert(utf8.encode(combinedString)).toString();

    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUri}/authen/authen_request"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'authen_request': authenRequestString}),
    );

    final json = jsonDecode(response.body);
    return (json["isError"] as bool, json["data"] as String, json["errorMessage"] as String);
  }

  void _doLogin(BuildContext context) async {
    var (isError, authenToken, errorMessage) = await _authenRequest();

    if (isError) {
      setState(() => _isLoading = false);
      showDialog(context: context, builder: (_) => AlertDialog(content: Text(errorMessage)));
    } else {
      var result = await _accessRequest(authenToken);
      setState(() => _isLoading = false);

      if (!result.$1) {
        print("Login Success!");
      } else {
        showDialog(context: context, builder: (_) => AlertDialog(content: Text(result.$3)));
      }
    }
  }

  Future<(bool isError, String data, String errorMessage)> _accessRequest(String authenToken) async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String passwordEncode = sha256.convert(utf8.encode(password)).toString();
    String combinedString = "$username&$passwordEncode&$authenToken";
    String authenSignature = sha256.convert(utf8.encode(combinedString)).toString();

    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUri}/authen/access_request"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'authen_signature': authenSignature, 'authen_token': authenToken}),
    );

    final json = jsonDecode(response.body);
    if (!json["isError"]) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", json["data"]["access_token"]);
      await prefs.setString("username", _usernameController.text);
    }
    return (json["isError"] as bool, json["data"]?["access_token"] as String? ?? "", json["errorMessage"] as String);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 135, 255, 163), Color(0xFF7C3AED)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flutter_dash, size: 80, color: Color.fromARGB(255, 255, 0, 255)),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'กรุณากรอก Username' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password', border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? 'กรุณากรอก Password' : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading ? const CircularProgressIndicator() : const Text('Login'),
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