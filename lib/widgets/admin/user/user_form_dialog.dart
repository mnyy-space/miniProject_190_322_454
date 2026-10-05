import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/admin/user_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';

/// Dialog เพิ่ม / แก้ไข ข้อมูลผู้ใช้
class UserFormDialog extends StatefulWidget {
  final UserItemData? existingUser;
  final Future<bool> Function(Map<String, dynamic> body) onSubmit;

  const UserFormDialog({
    super.key,
    this.existingUser,
    required this.onSubmit,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _passwordController;
  late String _selectedRole;
  bool _obscurePassword = true;
  bool _isSaving = false;

  bool get _isEditing => widget.existingUser != null;

  @override
  void initState() {
    super.initState();
    final user = widget.existingUser;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _passwordController = TextEditingController();
    _selectedRole = (user?.roleName.toLowerCase() == 'admin') ? 'admin' : 'user';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final roleId = _selectedRole == 'admin' ? 2 : 1;

    final body = <String, dynamic>{
      'username': _usernameController.text.trim(),
      'full_name': _fullNameController.text.trim(),
      'role_id': roleId,
      if (widget.existingUser?.email != null && widget.existingUser!.email.isNotEmpty)
        'email': widget.existingUser!.email,
    };

    if (_passwordController.text.isNotEmpty) {
      body['password'] = _passwordController.text;
    }

    final success = await widget.onSubmit(body);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _isEditing ? 'แก้ไขข้อมูลผู้ใช้' : 'เพิ่มผู้ใช้ใหม่',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username field
                AdminLabeledField(
                  label: 'Username (ชื่อบัญชีผู้ใช้)',
                  child: TextFormField(
                    controller: _usernameController,
                    enabled: !_isEditing,
                    decoration: adminInputDecoration(hint: 'เช่น somchai123'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'กรุณากรอก Username';
                      if (v.trim().length < 3) return 'Username ต้องมีความยาวอย่างน้อย 3 ตัวอักษร';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Full Name
                AdminLabeledField(
                  label: 'ชื่อ-นามสกุล',
                  child: TextFormField(
                    controller: _fullNameController,
                    decoration: adminInputDecoration(hint: 'เช่น สมชาย ใจดี'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อ-นามสกุล' : null,
                  ),
                ),
                const SizedBox(height: 16),



                // Role Dropdown
                AdminLabeledField(
                  label: 'บทบาท (Role)',
                  child: AdminDropdownField<String>(
                    value: _selectedRole,
                    items: const ['user', 'admin'],
                    onChanged: (val) {
                      setState(() => _selectedRole = val);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                AdminLabeledField(
                  label: _isEditing ? 'รหัสผ่านใหม่ (เว้นว่างได้)' : 'รหัสผ่าน (Password)',
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: adminInputDecoration(
                      hint: _isEditing ? 'ปล่อยว่างถ้าไม่เปลี่ยน' : 'อย่างน้อย 4 ตัวอักษร',
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (!_isEditing && (v == null || v.isEmpty)) {
                        return 'กรุณากรอกรหัสผ่าน';
                      }
                      if (v != null && v.isNotEmpty && v.length < 4) {
                        return 'รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก', style: TextStyle(color: Color(0xFF64748B))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('บันทึก'),
        ),
      ],
    );
  }
}
