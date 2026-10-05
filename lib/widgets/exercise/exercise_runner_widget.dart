import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/exercise_model.dart';
import 'package:halalsefllearning/widgets/exercise/code_block_widget.dart';
import 'package:halalsefllearning/utils/skill_icons.dart';

class ExerciseRunnerWidget extends StatefulWidget {
  final List<ExerciseQuestion> questions;
  final String skillTitle;
  final bool
  isPreTest; // ถ้า true = แบบทดสอบก่อนเรียน (ไม่เฉลยทันที), ถ้า false = แบบฝึกจริง (เฉลยทันที)
  final VoidCallback? onExit;
  final Function(int score, int total)? onFinish;

  /// คำตอบที่ทำค้างไว้ (exercise_id -> ตอบถูกหรือไม่) ใช้ทำต่อจากข้อที่ยังไม่ได้ตอบ
  final Map<int, bool> initialAnswers;

  /// เรียกทุกครั้งที่คำตอบเปลี่ยน (ตอบข้อใหม่ / เริ่มใหม่) เพื่อบันทึกงานค้าง
  final void Function(Map<int, bool> answers)? onProgress;

  const ExerciseRunnerWidget({
    super.key,
    required this.questions,
    this.skillTitle = 'Inheritance & Polymorphism',
    this.isPreTest = false,
    this.onExit,
    this.onFinish,
    this.initialAnswers = const {},
    this.onProgress,
  });

  @override
  State<ExerciseRunnerWidget> createState() => _ExerciseRunnerWidgetState();
}

class _ExerciseRunnerWidgetState extends State<ExerciseRunnerWidget> {
  int _currentIndex = 0;
  int? _selectedChoiceIndex;
  bool _isAnswerSubmitted = false;

  // คำตอบของแต่ละข้อ (exercise_id -> ตอบถูกหรือไม่)
  final Map<int, bool> _answers = {};

  // คะแนน = จำนวนข้อที่ตอบถูก (นับเฉพาะข้อที่ยังอยู่ในชุดคำถามนี้)
  int get _score =>
      widget.questions.where((q) => _answers[q.id] == true).length;

  @override
  void initState() {
    super.initState();
    _answers.addAll(widget.initialAnswers);

    // ทำต่อจากข้อแรกที่ยังไม่ได้ตอบ
    final firstUnanswered = widget.questions.indexWhere(
      (q) => !_answers.containsKey(q.id),
    );
    if (firstUnanswered >= 0) {
      _currentIndex = firstUnanswered;
    } else if (widget.questions.isNotEmpty && _answers.isNotEmpty) {
      // ตอบครบแล้วแต่ยังไม่ได้กดเสร็จสิ้น -> แสดงสรุปผลเลย
      _currentIndex = widget.questions.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCompletionDialog();
      });
    }
  }

  // สำหรับคำนวณและแสดงผลความคืบหน้า (%)
  double get _progressPercent {
    if (widget.questions.isEmpty) return 0.0;
    return (_currentIndex / widget.questions.length) * 100;
  }

  double get _nextProgressPercent {
    if (widget.questions.isEmpty) return 0.0;
    return ((_currentIndex + 1) / widget.questions.length) * 100;
  }

  ExerciseQuestion get _currentQuestion => widget.questions[_currentIndex];

  void _onSelectChoice(int index) {
    if (_isAnswerSubmitted) return; // ถ้าส่งคำตอบแล้วไม่ให้กดเปลี่ยน
    setState(() {
      _selectedChoiceIndex = index;
    });
  }

  void _submitAnswer() {
    if (_selectedChoiceIndex == null) return;

    final selectedChoice = _currentQuestion.choices[_selectedChoiceIndex!];
    final bool isCorrect = selectedChoice.isCorrect;

    // บันทึกคำตอบทันทีหลังส่ง เพื่อให้ออกกลางคันแล้วกลับมาทำต่อได้
    _answers[_currentQuestion.id] = isCorrect;
    widget.onProgress?.call(Map.of(_answers));

    if (widget.isPreTest) {
      // ในโหมด Pre-test: ไปข้อถัดไปทันทีโดยไม่ต้องเฉลยรายข้อ
      _goToNextQuestion();
    } else {
      // ในโหมด แบบฝึกจริง: แสดงแถบเฉลยด้านล่างตามรูปที่ 3
      setState(() {
        _isAnswerSubmitted = true;
      });
    }
  }

  void _goToNextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedChoiceIndex = null;
        _isAnswerSubmitted = false;
      });
    } else {
      // ทำครบทุกข้อแล้ว -> แสดงสรุปผลคะแนน
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final double percent = (_score / widget.questions.length) * 100;
    final bool isPassed = percent >= 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isPassed
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPassed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                size: 44,
                color: isPassed
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isPassed ? 'ยอดเยี่ยม! ทำสำเร็จ' : 'พยายามได้ดีมาก!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isPreTest
                  ? 'คุณได้ทำแบบทดสอบก่อนเรียน (Pre-test) ครบถ้วนแล้ว'
                  : 'คุณได้ทำแบบฝึกหัดทักษะนี้เรียบร้อยแล้ว',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'คะแนนที่ได้',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_score / ${widget.questions.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFCBD5E1),
                  ),
                  Column(
                    children: [
                      const Text(
                        'คิดเป็น',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPassed
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 0;
                        _selectedChoiceIndex = null;
                        _isAnswerSubmitted = false;
                        _answers.clear();
                      });
                      widget.onProgress?.call({});
                    },
                    child: const Text(
                      'ทำใหม่อีกครั้ง',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (widget.onFinish != null) {
                        widget.onFinish!(_score, widget.questions.length);
                      } else if (widget.onExit != null) {
                        widget.onExit!();
                      }
                    },
                    child: const Text(
                      'เสร็จสิ้น',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ออกจากแบบฝึกหัด?'),
        content: Text(
          'ทำไปแล้ว ${_answers.length} / ${widget.questions.length} ข้อ\n'
          'ข้อที่ตอบแล้วจะถูกบันทึกไว้ กลับมาทำต่อจากข้อที่ค้างได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ทำต่อ',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (widget.onExit != null) widget.onExit!();
            },
            child: const Text('ออกจากแบบฝึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('ไม่มีโจทย์แบบฝึกหัด')));
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // ปุ่ม Back ของระบบ / ปัดย้อนกลับ ให้ถามยืนยันเหมือนปุ่ม "ออก"
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // 1. Top Bar (ตรงตามภาพที่ 1)
            _buildTopBar(isMobile),

            // 2. Progress Header + Progress Bar
            _buildProgressHeader(),

            // 3. Question Card & Choices (พื้นที่เลื่อนตรงกลาง)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 780),
                    child: _buildQuestionCard(isMobile),
                  ),
                ),
              ),
            ),

            // 4. แถบเฉลย Feedback Sheet ด้านล่าง (แสดงเมื่อกดส่งคำตอบตามภาพที่ 3)
            if (_isAnswerSubmitted && !widget.isPreTest)
              _buildFeedbackBottomSheet(),
          ],
        ),
      ),
    );
  }

  // Top Bar ด้านบนสุด
  Widget _buildTopBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo & Brand
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.code_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'G06 · ALS',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 6),
                  const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                  const SizedBox(width: 6),
                  const Text(
                    'Adaptive Learning',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),

            const Spacer(),

            // Action Buttons บนขวา: [ออก] [ทัวร์] [กฎ] [ข้อ 1]
            Row(
              children: [
                // ปุ่มออก (สีแดง)
                InkWell(
                  onTap: _confirmExit,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'ออก',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                if (!isMobile) ...[
                  _buildTopBarPill(
                    icon: Icons.help_outline_rounded,
                    label: 'ทัวร์',
                    onTap: () {},
                  ),
                  const SizedBox(width: 6),
                  _buildTopBarPill(
                    icon: Icons.menu_book_rounded,
                    label: 'กฎ',
                    onTap: () {},
                  ),
                  const SizedBox(width: 6),
                ],

                // Badge ข้อปัจจุบัน
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    'ข้อ ${_currentIndex + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBarPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF475569)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // แถบความคืบหน้าด้านบน
  Widget _buildProgressHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ความคืบหน้า Skill: ${widget.skillTitle}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                _currentIndex == 0 && !_isAnswerSubmitted
                    ? 'ยังไม่เริ่ม'
                    : _isAnswerSubmitted
                    ? 'ยังไม่เริ่ม → ${_nextProgressPercent.toStringAsFixed(2)}%'
                    : '${_progressPercent.toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value:
                  (_currentIndex + (_isAnswerSubmitted ? 1 : 0)) /
                  widget.questions.length,
              minHeight: 7,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // กล่องการ์ดโจทย์คำถามและตัวเลือก 4 ช้อย
  Widget _buildQuestionCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. แถว Badges: ข้อ 1/8 | ชื่อวิชา | Level
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'ข้อ ${_currentIndex + 1} / ${widget.questions.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      skillIconOf(_currentQuestion.skillIcon),
                      size: 14,
                      color: const Color(0xFF475569),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _currentQuestion.skillName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFDE047)),
                ),
                child: Text(
                  'Level ${_currentQuestion.level} • ตัวเลือก',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF854D0E),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 2. กล่องข้อความโจทย์สีน้ำเงิน (ตรงตามภาพที่ 1)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Text(
              _currentQuestion.questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A8A),
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 3. กล่อง Code Block (ถ้ามี Snippet โค้ด)
          if (_currentQuestion.codeSnippet != null &&
              _currentQuestion.codeSnippet!.isNotEmpty) ...[
            CodeBlockWidget(
              code: _currentQuestion.codeSnippet!,
              language: _currentQuestion.codeLanguage,
            ),
            const SizedBox(height: 22),
          ],

          // 4. รายการตัวเลือกช้อย 4 ข้อ (A, B, C, D)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentQuestion.choices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final choice = _currentQuestion.choices[index];
              return _buildChoiceItem(index, choice);
            },
          ),

          const SizedBox(height: 24),

          // 5. ปุ่ม "ส่งคำตอบ →" (ซ่อนเมื่อแสดงแถบเฉลยแล้ว)
          if (!_isAnswerSubmitted)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedChoiceIndex == null
                      ? const Color(0xFFCBD5E1) // สีเทาเมื่อยังไม่ได้เลือกช้อย
                      : const Color(0xFF0256B8), // สีน้ำเงินเมื่อเลือกแล้ว
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectedChoiceIndex == null ? null : _submitAnswer,
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text(
                  'ส่งคำตอบ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ตัวเลือกช้อยแต่ละข้อ (รองรับการแสดงสีปกติ / สีไฮไลต์ / สีเฉลยถูกผิด)
  Widget _buildChoiceItem(int index, ExerciseChoice choice) {
    final bool isSelected = _selectedChoiceIndex == index;

    // สถานะสำหรับโหมดแบบฝึกจริง (หลังจากกดส่งคำตอบแล้ว)
    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFFE2E8F0);
    Color textColor = const Color(0xFF1E293B);
    Color badgeColor = const Color(0xFFF1F5F9);
    Color badgeTextColor = const Color(0xFF475569);
    Widget? trailingIcon;

    if (_isAnswerSubmitted && !widget.isPreTest) {
      if (choice.isCorrect) {
        // ข้อที่ถูกต้อง (สีเขียว)
        backgroundColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF065F46);
        badgeColor = const Color(0xFF10B981);
        badgeTextColor = Colors.white;
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 22,
        );
      } else if (isSelected && !choice.isCorrect) {
        // ข้อที่ตอบผิด (สีแดงตามรูปที่ 3)
        backgroundColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFF991B1B);
        badgeColor = const Color(0xFFEF4444);
        badgeTextColor = Colors.white;
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          color: Color(0xFFEF4444),
          size: 22,
        );
      }
    } else if (isSelected) {
      // เมื่อกดเลือก (ยังไม่ได้ส่ง)
      backgroundColor = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFF2563EB);
      textColor = const Color(0xFF1D4ED8);
      badgeColor = const Color(0xFF2563EB);
      badgeTextColor = Colors.white;
    }

    return InkWell(
      onTap: () => _onSelectChoice(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1),
        ),
        child: Row(
          children: [
            // ป้ายตัวอักษร A, B, C, D
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  choice.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // ข้อความตัวเลือก
            Expanded(
              child: Text(
                choice.text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            // ไอคอนตรวจคำตอบ (ถ้ามี)
            ?trailingIcon,
          ],
        ),
      ),
    );
  }

  // แถบเฉลย Feedback ด้านล่างตามภาพที่ 3
  Widget _buildFeedbackBottomSheet() {
    final selectedChoice = _currentQuestion.choices[_selectedChoiceIndex!];
    final bool isCorrect = selectedChoice.isCorrect;

    final Color bannerColor = isCorrect
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFFEE2E2);
    final Color mainColor = isCorrect
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bannerColor,
        border: Border(
          top: BorderSide(color: mainColor.withValues(alpha: 0.3), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ไอคอนเครื่องหมายถูก / ผิด
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: mainColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect ? Icons.check_rounded : Icons.close_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // ข้อความและแถบความคืบหน้า
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isCorrect ? 'ถูกต้อง!' : 'ไม่ถูกต้อง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ความคืบหน้า ยังไม่เริ่ม → ${_nextProgressPercent.toStringAsFixed(2)}% +${(100 / widget.questions.length).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / widget.questions.length,
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.6),
                        valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ปุ่ม "ข้อถัดไป →"
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _goToNextQuestion,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                _currentIndex == widget.questions.length - 1
                    ? 'ดูผลคะแนน'
                    : 'ข้อถัดไป',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
