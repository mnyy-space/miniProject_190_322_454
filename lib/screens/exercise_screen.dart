import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/exercise_model.dart';
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

  /// บันทึกประวัติการทำแบบฝึกหัดลงในตาราง history เมื่อทำเสร็จสิ้น
  Future<void> _recordHistory() async {
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

      await AppApi.post("exercise/history", body);

      // อัปเดตข้อมูล Session ล่าสุดลง SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("has_history", true);
      if (widget.sessionId != null) {
        await prefs.setInt("latest_session_id", widget.sessionId!);
      }
      await prefs.setString("latest_session_name", widget.skillTitle);
    } catch (e) {
      // แม้บันทึก history มีปัญหาก็ไม่ขัดขวางการจบแบบฝึกหัดของผู้ใช้
      debugPrint("Failed to record exercise history: $e");
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

    // เมื่อมีคำถามจริง ให้รันแบบฝึกหัดผ่าน ExerciseRunnerWidget
    return ExerciseRunnerWidget(
      questions: _questions,
      skillTitle: widget.skillTitle,
      isPreTest: widget.isPreTest,
      onExit: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      onFinish: (score, total) async {
        await _recordHistory();
        if (!context.mounted) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
    );
  }
}
