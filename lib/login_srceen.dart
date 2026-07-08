import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/config/app_config.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/utils/date_util.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:my_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); //final = can't edit

  final _usernameValueController = TextEditingController();
  final _passwordValueController = TextEditingController();

  Future<(bool, String, String)> _authenRequest() async {
    String username = _usernameValueController.text;
    DateTime now = DateTime.now();
    String formattedDeteString = DateUtil().getFormattedDate(now);

    String combinedString = "$username&$formattedDeteString";
    print(combinedString);

    String authenRequestString = sha256
        .convert(utf8.encode(combinedString))
        .toString();

    print(authenRequestString);

    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUri}/authen/authen_request"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'authen_request': authenRequestString}),
    );

    final json = jsonDecode(response.body);

    print(json);

    return (
      json["isError"] as bool,
      json["data"] as String,
      json["errorMessage"] as String,
    );
  }

  void _doLogin(BuildContext context) async {
    var (isError, authenToken, errorMessage) = await _authenRequest();

    if (isError) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(content: Text(errorMessage));
        },
      );
    } else {
      var result = await _accessRequest(authenToken);

      print(result);

      if (!result.isError) {
        //เปลี่ยนหน้าไป Home Screen
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(content: Text(result.errorMessage));
          },
        );
      }
    }
  }

  Future<({bool isError, String data, String errorMessage})> _accessRequest(
    String authenToken,
  ) async {
    String username = _usernameValueController.text;
    String password = _passwordValueController.text;
    String passwordEncode = sha256.convert(utf8.encode(password)).toString();
    String combinedString = "$username&$passwordEncode&$authenToken";
    String authenSignature = sha256
        .convert(utf8.encode(combinedString))
        .toString();

    print(combinedString);
    print(authenSignature);

    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUri}/authen/access_request"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'authen_signature': authenSignature,
        'authen_token': authenToken,
      }),
    );

    final json = jsonDecode(response.body);

    print(json);

    if (!json["isError"]) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString("access_token", json["data"]["access_token"]);
      await prefs.setString("username", _usernameValueController.text);
      await prefs.setString("image_url", json["data"]["image_url"]);
    }

    return (
      isError: json["isError"] as bool,
      data: json["data"]["access_token"] as String,
      errorMessage: json["errorMessage"] as String,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 135, 255, 163),
              Color(0xFF7C3AED),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),
                child: Card(
                  elevation: 12,
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
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.flutter_dash,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            'Welcome Back',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Sign in to continue',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 32),

                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'username',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอก Username';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก Password';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                              const Text('Remember Me'),
                            ],
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Navigate to Register Screen
                                },
                                child: const Text('Sign Up'),
                              ),
                            ],
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
      ),
    );
  }
}


