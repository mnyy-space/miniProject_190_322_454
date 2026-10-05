import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/history_model.dart';
import 'package:halalsefllearning/screens/exercise_screen.dart';
import 'package:halalsefllearning/screens/login_srceen.dart';
import 'package:halalsefllearning/screens/home_screen.dart';
import 'package:halalsefllearning/utils/exercise_progress_store.dart';
import 'package:halalsefllearning/utils/skill_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserMainLayout extends StatefulWidget {
  final int? skillId;
  const UserMainLayout({super.key, this.skillId});

  @override
  State<UserMainLayout> createState() => _UserMainLayoutState();
}

class _UserMainLayoutState extends State<UserMainLayout> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  final GlobalKey<_UserHistoryScreenState> _historyKey =
      GlobalKey<_UserHistoryScreenState>();

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(skillId: widget.skillId),
      UserHistoryScreen(key: _historyKey),
      const UserProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // ใช้ IndexedStack เพื่อจำสถานะการเลื่อนของแต่ละหน้าไว้ ไม่ต้องโหลดใหม่ทุกครั้งที่สลับแท็บ
      body: IndexedStack(index: _currentIndex, children: _pages),

      // แถบ Navigation Bar ด้านล่าง 3 ไอคอน
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                // แท็บประวัติอยู่ใน IndexedStack จึงไม่โหลดใหม่เอง
                // -> รีเฟรชทุกครั้งที่เปิดแท็บ เพื่อให้เห็นงานค้าง/ผลล่าสุดจากหน้า Home
                if (index == 1) _historyKey.currentState?._fetchHistory();
              },
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: const Color(0xFF2894D7), // สีฟ้าตามธีมแอป
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              type: BottomNavigationBarType.fixed,
              items: const [
                // 1. Home
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_rounded),
                  ),
                  label: 'หน้าแรก',
                ),

                // 2. ประวัติ
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.history_rounded),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.manage_history_rounded),
                  ),
                  label: 'ประวัติ',
                ),

                // 3. แอคเคานต์
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_outline_rounded),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_rounded),
                  ),
                  label: 'แอคเคานต์',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// หน้าจอที่ 2: ประวัติ (History Screen) ดึงข้อมูลจริงจาก Database
// ======================================================================
class UserHistoryScreen extends StatefulWidget {
  const UserHistoryScreen({super.key});

  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  List<HistoryModel> _historyList = [];
  // แบบฝึกหัดที่ออกกลางคัน (เก็บในเครื่อง) แสดงแยกจากประวัติที่ทำเสร็จ
  List<ExerciseProgress> _inProgressList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final inProgress = await ExerciseProgressStore.loadAll();
    if (mounted) setState(() => _inProgressList = inProgress);

    try {
      final response = await AppApi.get("user/history");
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final historyRes = HistoryListResponse.fromJson(json);

        if (mounted) {
          setState(() {
            _historyList = historyRes.data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                "ไม่สามารถโหลดประวัติได้ (Code: ${response.statusCode})";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "เกิดข้อผิดพลาดในการโหลดประวัติ: $e";
        });
      }
    }
  }

  /// ป้ายคะแนนของแต่ละประวัติ (ผ่าน >= 60% สีเขียว ไม่ผ่านสีส้ม)
  /// ประวัติเก่าที่ยังไม่ได้เก็บคะแนนแสดงเป็น "เสร็จสิ้น"
  Widget _buildScoreBadge(HistoryModel item) {
    final score = item.score;
    final total = item.totalQuestions;
    final bool hasScore = score != null && total != null && total > 0;
    final bool isPassed = hasScore && score / total >= 0.6;
    final Color fg = !hasScore || isPassed
        ? const Color(0xFF059669)
        : const Color(0xFFEA580C);
    final Color bg = !hasScore || isPassed
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFFF7ED);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        hasScore ? '$score/$total คะแนน' : 'เสร็จสิ้น',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  /// เปิดหน้าแบบฝึกหัด แล้วรีเฟรชประวัติ + งานค้างเมื่อกลับมา
  Future<void> _openExerciseScreen(int sessionId, String sessionName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExerciseScreen(skillTitle: sessionName, sessionId: sessionId),
      ),
    );
    _fetchHistory();
  }

  void _continueExercise(ExerciseProgress progress) {
    _openExerciseScreen(
      progress.sessionId,
      progress.sessionName.isNotEmpty ? progress.sessionName : 'แบบฝึกหัด',
    );
  }

  /// สรุปผลของประวัติที่ทำเสร็จ (แค่ดูผล ไม่พาเข้าไปทำแบบฝึกหัดเอง)
  void _showHistoryDetail(HistoryModel item, String dateStr) {
    final score = item.score;
    final total = item.totalQuestions;
    final bool hasScore = score != null && total != null && total > 0;
    final bool hasUnfinished = _inProgressList.any(
      (p) => p.sessionId == item.sessionId,
    );

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    skillIconOf(item.skillIcon),
                    color: const Color(0xFF2894D7),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.sessionName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildScoreBadge(item),
                ],
              ),
              const SizedBox(height: 16),
              row('Skill', item.skillName),
              row(
                'คะแนน',
                hasScore
                    ? '$score / $total (${(score / total * 100).toStringAsFixed(0)}%)'
                    : 'ไม่มีข้อมูลคะแนน (ประวัติเก่า)',
              ),
              row('ทำเสร็จเมื่อ', dateStr),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _openExerciseScreen(item.sessionId, item.sessionName);
                  },
                  icon: Icon(
                    hasUnfinished
                        ? Icons.play_arrow_rounded
                        : Icons.replay_rounded,
                  ),
                  label: Text(
                    hasUnfinished
                        ? 'ไปทำต่อจากที่ค้างไว้'
                        : 'ทำแบบฝึกหัดนี้อีกครั้ง',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ประวัติการเรียนรู้',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF2894D7)),
            SizedBox(height: 16),
            Text(
              'กำลังโหลดประวัติการเรียนรู้...',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchHistory,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('ลองใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2894D7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_historyList.isEmpty && _inProgressList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchHistory,
        color: const Color(0xFF2894D7),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F6FC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      size: 36,
                      color: Color(0xFF2894D7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ยังไม่มีประวัติการเรียนรู้',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'เริ่มเรียนและทำแบบฝึกหัดแรกของคุณได้เลย!',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      color: const Color(0xFF2894D7),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // ส่วนที่ 1: แบบฝึกหัดที่ออกกลางคัน (ยังไม่นับว่าทำเสร็จ)
          if (_inProgressList.isNotEmpty) ...[
            _buildSectionTitle('กำลังทำ (ยังไม่เสร็จ)', _inProgressList.length),
            for (final progress in _inProgressList)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildInProgressCard(progress),
              ),
            const SizedBox(height: 8),
          ],
          // ส่วนที่ 2: ประวัติที่ทำเสร็จและบันทึกลงระบบแล้ว
          if (_historyList.isNotEmpty) ...[
            _buildSectionTitle('ทำเสร็จแล้ว', _historyList.length),
            for (final item in _historyList)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHistoryCard(item),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  /// การ์ดแบบฝึกหัดที่ทำค้างไว้ กดเพื่อกลับไปทำต่อ
  Widget _buildInProgressCard(ExerciseProgress progress) {
    final answered = progress.answers.length;
    final total = progress.totalQuestions;
    final title = progress.sessionName.isNotEmpty
        ? progress.sessionName
        : 'Session #${progress.sessionId}';
    const orange = Color(0xFFEA580C);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _continueExercise(progress),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  skillIconOf(progress.skillIcon),
                  color: orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (progress.skillName.isNotEmpty) progress.skillName,
                        total > 0
                            ? 'ตอบแล้ว $answered / $total ข้อ'
                            : 'ตอบแล้ว $answered ข้อ',
                      ].join(' • '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (total > 0) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (answered / total).clamp(0, 1).toDouble(),
                          minHeight: 6,
                          backgroundColor: const Color(0xFFFFEDD5),
                          color: orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ทำต่อ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// การ์ดประวัติที่ทำเสร็จแล้ว กดเพื่อดูสรุปผล (ไม่เข้าไปทำแบบฝึกหัด)
  Widget _buildHistoryCard(HistoryModel item) {
    final dateStr = item.historyDate != null
        ? DateFormat('dd/MM/yyyy • HH:mm').format(item.historyDate!.toLocal())
        : '-';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showHistoryDetail(item, dateStr),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2894D7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2894D7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.sessionName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                skillIconOf(item.skillIcon),
                                size: 12,
                                color: const Color(0xFF475569),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.skillName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildScoreBadge(item),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// หน้าจอที่ 3: แอคเคานต์ (Profile Screen)
// ======================================================================
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _username = 'ผู้ใช้งาน';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'นักเรียน';
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันการออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ยกเลิก',
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
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'บัญชีของฉัน',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ส่วนโปรไฟล์ผู้ใช้
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5ED1EA), Color(0xFF2894D7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2894D7).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ผู้เรียน (Student)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // เมนูตั้งค่า & ช่วยเหลือ
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'การแจ้งเตือน',
                    onTap: () {},
                  ),
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0xFFF1F5F9),
                  ),
                  _buildProfileTile(
                    icon: Icons.language_rounded,
                    title: 'ภาษา (Language)',
                    trailing: 'ไทย',
                    onTap: () {},
                  ),
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0xFFF1F5F9),
                  ),
                  _buildProfileTile(
                    icon: Icons.help_outline_rounded,
                    title: 'ศูนย์ช่วยเหลือ & คู่มือ',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ปุ่มออกจากระบบ
            InkWell(
              onTap: _handleLogout,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'ออกจากระบบ',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF475569), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
