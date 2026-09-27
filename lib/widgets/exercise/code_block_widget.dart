import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeBlockWidget extends StatefulWidget {
  final String code;
  final String language;

  const CodeBlockWidget({
    super.key,
    required this.code,
    this.language = 'PYTHON',
  });

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  bool _copied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอกโค้ดเรียบร้อยแล้ว'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E), // สีพื้นหลังโค้ดแบบ Dark Theme
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF313244)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar: ภาษาโค้ด + ปุ่มคัดลอก
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF181825),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFF313244)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.language.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF89DCEB),
                    letterSpacing: 1,
                  ),
                ),
                InkWell(
                  onTap: _copyToClipboard,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF313244),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 13,
                          color: _copied ? const Color(0xFFA6E3A1) : const Color(0xFFCDD6F4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copied ? 'คัดลอกแล้ว' : 'คัดลอก',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _copied ? const Color(0xFFA6E3A1) : const Color(0xFFCDD6F4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: SelectableText.rich(
              _buildSyntaxHighlightedText(widget.code),
            ),
          ),
        ],
      ),
    );
  }

  // ไฮไลต์สี Syntax แบบง่าย (Python / Javascript)
  TextSpan _buildSyntaxHighlightedText(String code) {
    final List<TextSpan> spans = [];
    final lines = code.split('\n');

    final keywords = {
      'class', 'def', 'return', 'import', 'from', 'if', 'else', 'elif',
      'for', 'while', 'in', 'print', 'self', 'True', 'False', 'None',
      'const', 'let', 'var', 'function', 'async', 'await'
    };

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // การตัดคำแบบ RegExp match
      final pattern = RegExp(r'(\w+|[^\w\s]|\s+)');
      final matches = pattern.allMatches(line);

      for (final match in matches) {
        final token = match.group(0) ?? '';

        if (keywords.contains(token)) {
          // คำสั่งหลัก (Keyword) เช่น class, def, return
          spans.add(TextSpan(
            text: token,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCBA6F7), // ม่วงพาสเทล
            ),
          ));
        } else if (token.startsWith('"') || token.endsWith('"') || token.startsWith("'")) {
          // ข้อความ String
          spans.add(TextSpan(
            text: token,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Color(0xFFA6E3A1), // เขียวพาสเทล
            ),
          ));
        } else if (int.tryParse(token) != null) {
          // ตัวเลข
          spans.add(TextSpan(
            text: token,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Color(0xFFFAB387), // ส้มพีช
            ),
          ));
        } else if (token == 'self' || token == 'this') {
          // self
          spans.add(TextSpan(
            text: token,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFFF38BA8), // แดงชมพู
            ),
          ));
        } else {
          // ตัวแปรและสัญลักษณ์ทั่วไป
          spans.add(TextSpan(
            text: token,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Color(0xFFCDD6F4), // ขาวสว่าง
            ),
          ));
        }
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: spans);
  }
}
