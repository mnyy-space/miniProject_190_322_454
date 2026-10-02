import 'package:flutter/material.dart';

/// ป้ายชื่อฟิลด์ในฟอร์ม
class AdminFieldLabel extends StatelessWidget {
  final String text;

  const AdminFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
    );
  }
}

/// ฟิลด์ในฟอร์ม: ป้ายชื่ออยู่บน ช่องกรอกอยู่ล่าง
class AdminLabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const AdminLabeledField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminFieldLabel(label),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// วางฟิลด์ 2 ช่องคู่กันในแถวเดียว
class AdminFieldRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const AdminFieldRow({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

/// รูปแบบกรอบช่องกรอกข้อความที่ใช้ร่วมกันในทุกฟอร์มของ Admin
InputDecoration adminInputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF2563EB)),
    ),
  );
}

/// Dropdown แบบมีกรอบ เต็มความกว้าง สำหรับใช้ในฟอร์ม
class AdminDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T)? displayLabel;
  final String? hint;

  const AdminDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.displayLabel,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: hint == null
              ? null
              : Text(hint!, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      displayLabel != null ? displayLabel!(item) : item.toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

/// แถว "สถานะเปิดใช้งาน (Active)" + สวิตช์ ในฟอร์ม
class AdminActiveSwitchField extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AdminActiveSwitchField({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: AdminFieldLabel('สถานะเปิดใช้งาน (Active)')),
        Switch(
          value: value,
          activeThumbColor: const Color(0xFF10B981),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// ถามยืนยันก่อนลบ คืนค่า true ถ้าผู้ใช้กด "ลบ"
Future<bool> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String itemName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text('ต้องการลบ "$itemName" ใช่หรือไม่?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('ยกเลิก'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('ลบ', style: TextStyle(color: Color(0xFFDC2626))),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// แสดง SnackBar สีแดงเมื่อเกิดข้อผิดพลาด
void showAdminError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: const Color(0xFFDC2626)),
  );
}
