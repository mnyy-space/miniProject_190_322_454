import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/exercise_model.dart';
import 'package:halalsefllearning/utils/exercise_progress_store.dart';
import 'package:halalsefllearning/utils/skill_icons.dart';
import 'package:halalsefllearning/widgets/exercise/exercise_runner_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseScreen extends StatefulWidget {
  final int? sessionId;
  final String skillTitle;
  final bool isPreTest;
  final List<ExerciseQuestion>? customQuestions;

  const ExerciseScreen({
    super.key,
    this.sessionId,
    this.skillTitle = 'Exercise',
    this.isPreTest = false,
    this.customQuestions,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<ExerciseQuestion> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;

  // งานที่ทำค้างไว้ของ Session นี้ (exercise_id -> ตอบถูกหรือไม่)
  Map<int, bool> _savedAnswers = {};
  // true = ยังต้องถามผู้ใช้ว่าจะทำต่อหรือเริ่มใหม่
  bool _askResume = false;

  int? get _progressSessionId =>
      (widget.sessionId != null && widget.sessionId! > 0 && widget.customQuestions == null)
          ? widget.sessionId
          : null;

  /// โหลดงานค้าง (เก็บเฉพาะข้อที่ยังอยู่ใน Session) แล้วตัดสินใจว่าต้องถามทำต่อหรือไม่
  Future<void> _loadSavedProgress(List<ExerciseQuestion> questions) async {
    final sessionId = _progressSessionId;
    if (sessionId == null) return;
    final ids = questions.map((q) => q.id).toSet();
    final saved = await ExerciseProgressStore.load(sessionId);
    saved.removeWhere((id, _) => !ids.contains(id));
    _savedAnswers = saved;
    _askResume = saved.isNotEmpty;
  }

  void _saveProgress(Map<int, bool> answers) {
    final sessionId = _progressSessionId;
    if (sessionId == null) return;
    final first = _questions.isNotEmpty ? _questions.first : null;
    ExerciseProgressStore.save(
      sessionId,
      answers,
      sessionName: widget.skillTitle,
      skillName: first?.skillName ?? '',
      skillIcon: first?.skillIcon ?? defaultSkillIconName,
      totalQuestions: _questions.length,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    // 1. หากส่ง customQuestions มา (เช่น เพื่อการทดสอบเฉพาะ) ให้ใช้ทันที
    if (widget.customQuestions != null && widget.customQuestions!.isNotEmpty) {
      setState(() {
        _questions = widget.customQuestions!;
        _isLoading = false;
      });
      return;
    }

    // 2. หากไม่มี sessionId ให้แจ้งเตือน
    if (widget.sessionId == null || widget.sessionId == 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = "ไม่พบรหัส Session สำหรับโหลดแบบฝึกหัด";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 3. ดึงข้อมูลแบบฝึกหัดจริงจาก Backend API
    try {
      final response = await AppApi.get("exercise/${widget.sessionId}");
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final exerciseResponse = ExerciseResponse.fromJson(
          json,
          defaultSkillName: widget.skillTitle,
        );

        if (!exerciseResponse.isError) {
          await _loadSavedProgress(exerciseResponse.data);
          if (!mounted) return;
          setState(() {
            _questions = exerciseResponse.data;
            _isLoading = false;
          });
          return;
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = exerciseResponse.errorMessage.isNotEmpty
                ? exerciseResponse.errorMessage
                : "ไม่พบแบบฝึกหัดใน Session นี้";
          });
          return;
        }
      }

      setState(() {
        _isLoading = false;
        _errorMessage = "ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ (Code: ${response.statusCode})";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "เกิดข้อผิดพลาดในการโหลดแบบฝึกหัด: $e";
      });
    }
  }

  /// บันทึกประวัติการทำแบบฝึกหัด (พร้อมคะแนน) ลงตาราง history เมื่อทำเสร็จสิ้น
  /// คืนค่า null ถ้าบันทึกสำเร็จ หรือข้อความ error ถ้าไม่สำเร็จ
  Future<String?> _recordHistory(int score, int total) async {
    try {
      int? sweId;
      for (final q in _questions) {
        if (q.sessionWithExerciseId != null && q.sessionWithExerciseId! > 0) {
          sweId = q.sessionWithExerciseId;
          break;
        }
      }

      final Map<String, dynamic> body = {};
      if (sweId != null) body['session_with_exercise_id'] = sweId;
      if (widget.sessionId != null) body['session_id'] = widget.sessionId;
      body['score'] = score;
      body['total_questions'] = total;

      // unwrap จะ throw ถ้า HTTP ไม่ใช่ 2xx หรือ isError = true
      AppApi.unwrap(await AppApi.post("exercise/history", body));

      // อัปเดตข้อมูล Session ล่าสุดลง SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("has_history", true);
      if (widget.sessionId != null) {
        await prefs.setInt("latest_session_id", widget.sessionId!);
      }
      await prefs.setString("latest_session_name", widget.skillTitle);
      return null;
    } catch (e) {
      debugPrint("Failed to record exercise history: $e");
      return e.toString();
    }
  }

  /// ทำครบแล้ว: บันทึกผลลง DB ก่อน แล้วจึงล้างงานค้าง
  /// ถ้าบันทึกไม่สำเร็จจะเก็บงานค้างไว้ (กลับมากด "ดูสรุปผล" แล้วส่งใหม่ได้) และให้ลองใหม่
  Future<void> _finishExercise(int score, int total) async {
    // โหมดทดสอบด้วย customQuestions ไม่มี Session ให้บันทึก
    if (widget.sessionId == null || widget.sessionId == 0) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      return;
    }

    final error = await _recordHistory(score, total);
    if (!mounted) return;

    if (error == null) {
      final sessionId = _progressSessionId;
      if (sessionId != null) await ExerciseProgressStore.clear(sessionId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกผลแล้ว: ได้ $score / $total คะแนน')),
      );
      if (Navigator.canPop(context)) Navigator.pop(context);
      return;
    }

    final retry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('บันทึกผลไม่สำเร็จ'),
        content: Text(
          'ยังไม่ได้บันทึกคะแนน $score / $total ลงระบบ\n'
          'คำตอบของคุณยังเก็บไว้ในเครื่อง กลับมาส่งใหม่ภายหลังได้\n\n'
          'สาเหตุ: $error',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ไว้ทีหลัง', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลองอีกครั้ง'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (retry == true) {
      await _finishExercise(score, total);
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(widget.skillTitle),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
              SizedBox(height: 16),
              Text(
                'กำลังโหลดแบบฝึกหัด...',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || _questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(widget.skillTitle),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? "ยังไม่มีแบบฝึกหัดใน Session นี้",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('กลับไปยังหน้าแรก'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_askResume) {
      return _buildResumePrompt();
    }

    // เมื่อมีคำถามจริง ให้รันแบบฝึกหัดผ่าน ExerciseRunnerWidget
    return ExerciseRunnerWidget(
      questions: _questions,
      skillTitle: widget.skillTitle,
      isPreTest: widget.isPreTest,
      initialAnswers: _savedAnswers,
      onProgress: _saveProgress,
      onExit: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      onFinish: _finishExercise,
    );
  }

  /// หน้าถามว่าจะทำต่อจากที่ค้างไว้ หรือเริ่มทำใหม่ตั้งแต่ข้อแรก
  Widget _buildResumePrompt() {
    final answered = _savedAnswers.length;
    final total = _questions.length;
    final nextIndex = _questions.indexWhere((q) => !_savedAnswers.containsKey(q.id));
    final resumeLabel = nextIndex >= 0 ? 'ทำต่อจากข้อ ${nextIndex + 1}' : 'ดูสรุปผล';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.skillTitle),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history_edu_rounded,
                      size: 38,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'มีแบบฝึกหัดที่ทำค้างไว้',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ทำไปแล้ว $answered / $total ข้อ',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : answered / total,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _askResume = false),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(resumeLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _saveProgress({});
                        setState(() {
                          _savedAnswers = {};
                          _askResume = false;
                        });
                      },
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('เริ่มทำใหม่ตั้งแต่ข้อแรก'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
