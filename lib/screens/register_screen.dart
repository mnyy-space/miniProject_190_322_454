import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:halalsefllearning/config/app_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showDialog('ข้อผิดพลาด', 'รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUri}/register"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
        }),
      );

      final json = jsonDecode(response.body);
      final bool isError = json["isError"] as bool? ?? true;
      final String errorMessage = json["errorMessage"] as String? ?? "การลงทะเบียนไม่สำเร็จ";

      setState(() => _isLoading = false);

      if (isError) {
        _showDialog('เกิดข้อผิดพลาด', errorMessage);
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 26),
                SizedBox(width: 8),
                Text('ลงทะเบียนสำเร็จ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text('บัญชีของคุณถูกสร้างเรียบร้อยแล้ว กรุณาเข้าสู่ระบบ'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Go back to login screen
                },
                child: const Text('เข้าสู่ระบบ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showDialog('เกิดข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
    }
  }

  void _showDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
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
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top header area with back arrow
                        Container(
                          width: double.infinity,
                          height: 80,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 12),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        // White Sheet with top-left rounded curve extending to bottom
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(85),
                              ),
                            ),
                            alignment: Alignment.topCenter,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Center(
                                          child: ShaderMask(
                                            shaderCallback: (bounds) =>
                                                _primaryGradient.createShader(bounds),
                                            child: const Text(
                                              'Create new\nAccount',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 34,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                height: 1.15,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Center(
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              const Text(
                                                'Already Registered? ',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF8E8E93),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => Navigator.pop(context),
                                                child: const Text(
                                                  'Log in here.',
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
                                        const SizedBox(height: 28),

                                      // Name
                                      _buildField(
                                        label: 'NAME',
                                        controller: _firstNameController,
                                        validator: (v) =>
                                            v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อ' : null,
                                      ),
                                      const SizedBox(height: 16),

                                      // Last Name
                                      _buildField(
                                        label: 'LASTNAME',
                                        controller: _lastNameController,
                                        validator: (v) =>
                                            v == null || v.trim().isEmpty ? 'กรุณากรอกนามสกุล' : null,
                                      ),
                                      const SizedBox(height: 16),

                                      // User Name (Username)
                                      _buildField(
                                        label: 'USERNAME',
                                        controller: _usernameController,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'กรุณากรอก Username';
                                          }
                                          if (v.trim().length < 3) {
                                            return 'Username ต้องมีความยาวอย่างน้อย 3 ตัวอักษร';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Password
                                      _buildField(
                                        label: 'PASSWORD',
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                            color: const Color(0xFF94A3B8),
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return 'กรุณากรอกรหัสผ่าน';
                                          }
                                          if (v.length < 4) {
                                            return 'รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Confirm Password
                                      _buildField(
                                        label: 'CONFIRM PASSWORD',
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFF94A3B8),
                                            size: 20,
                                          ),
                                          onPressed: () => setState(
                                              () => _obscureConfirmPassword = !_obscureConfirmPassword),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return 'กรุณายืนยันรหัสผ่าน';
                                          }
                                          if (v != _passwordController.text) {
                                            return 'รหัสผ่านไม่ตรงกัน';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 32),

                                      // Submit Button (Sign up)
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
                                          onPressed:
                                              _isLoading ? null : _register,
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
                                                  'Sign up',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
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
