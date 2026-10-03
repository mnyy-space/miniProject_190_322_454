import 'package:flutter/material.dart';

/// การ์ดพรีวิวโค้ดสไตล์ตัวแก้ไขโค้ด พร้อมไฮไลต์คำสั่งพื้นฐาน และไฮไลต์ช่องว่าง ____
class CodePreviewCard extends StatelessWidget {
  final String code;
  final String language;
  final VoidCallback onCopy;

  const CodePreviewCard({
    super.key,
    required this.code,
    required this.language,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final displayCode = code.trim().isEmpty ? '# ยังไม่มีโค้ดประกอบโจทย์' : code;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    language.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _CopyButton(onTap: onCopy),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SelectableText.rich(
              highlightCode(displayCode),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CopyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copy_rounded, size: 12, color: Color(0xFFCBD5E1)),
            SizedBox(width: 4),
            Text('คัดลอก', style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1))),
          ],
        ),
      ),
    );
  }
}

const TextStyle _baseStyle = TextStyle(color: Color(0xFFE2E8F0));
const TextStyle _commentStyle = TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic);
const TextStyle _functionStyle = TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.w600);
const TextStyle _numberStyle = TextStyle(color: Color(0xFF7DD3FC));
const TextStyle blankHighlightStyle = TextStyle(
  color: Color(0xFF0F172A),
  backgroundColor: Color(0xFFFDE68A),
  fontWeight: FontWeight.w700,
);

final RegExp _blankPattern = RegExp(r'_{3,}');
final RegExp _functionPattern = RegExp(r'\b(print|pop|push|append|len|range|enqueue|dequeue)\b');
final RegExp _numberPattern = RegExp(r'\b\d+\b');

/// ไฮไลต์โค้ดแบบง่าย: คอมเมนต์ (สีเทา), ฟังก์ชันในตัว (สีทอง), ตัวเลข (สีฟ้าอ่อน),
/// และช่องว่าง ____ (กล่องไฮไลต์สีเหลือง)
TextSpan highlightCode(String code) {
  final List<TextSpan> spans = [];
  for (final line in code.split('\n')) {
    if (line.trim().startsWith('#')) {
      spans.add(TextSpan(text: '$line\n', style: _commentStyle));
      continue;
    }

    int cursor = 0;
    // รวมตำแหน่ง match ทั้งหมดของ blank / function / number แล้วเรียงตามตำแหน่ง
    final matches = <_Match>[
      ..._blankPattern.allMatches(line).map((m) => _Match(m.start, m.end, blankHighlightStyle)),
      ..._functionPattern.allMatches(line).map((m) => _Match(m.start, m.end, _functionStyle)),
      ..._numberPattern.allMatches(line).map((m) => _Match(m.start, m.end, _numberStyle)),
    ]..sort((a, b) => a.start.compareTo(b.start));

    for (final m in matches) {
      if (m.start < cursor) continue; // ข้าม overlap
      if (m.start > cursor) {
        spans.add(TextSpan(text: line.substring(cursor, m.start), style: _baseStyle));
      }
      spans.add(TextSpan(text: line.substring(m.start, m.end), style: m.style));
      cursor = m.end;
    }
    if (cursor < line.length) {
      spans.add(TextSpan(text: line.substring(cursor), style: _baseStyle));
    }
    spans.add(const TextSpan(text: '\n'));
  }

  return TextSpan(children: spans);
}

class _Match {
  final int start;
  final int end;
  final TextStyle style;
  _Match(this.start, this.end, this.style);
}
