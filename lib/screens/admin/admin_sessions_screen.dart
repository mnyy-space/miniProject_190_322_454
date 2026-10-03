import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/admin/exercise_item_data.dart';
import 'package:halalsefllearning/models/admin/session_item_data.dart';
import 'package:halalsefllearning/models/admin/skill_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_action_bar.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_list_widgets.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_page_header.dart';
import 'package:halalsefllearning/widgets/admin/session/session_form_dialog.dart';

class AdminSessionsScreen extends StatefulWidget {
  const AdminSessionsScreen({super.key});

  @override
  State<AdminSessionsScreen> createState() => _AdminSessionsScreenState();
}

class _AdminSessionsScreenState extends State<AdminSessionsScreen> {
  List<SessionItemData> _sessions = [];
  List<SkillItemData> _skills = [];
  List<ExerciseItemData> _exercises = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        AppApi.get('admin/session'),
        AppApi.get('admin/skill'),
        AppApi.get('admin/exercise'),
      ]);
      final sessions = AppApi.unwrap(responses[0]) as List? ?? [];
      final skills = AppApi.unwrap(responses[1]) as List? ?? [];
      final exercises = AppApi.unwrap(responses[2]) as List? ?? [];
      if (!mounted) return;
      setState(() {
        _sessions = sessions
            .map((row) => SessionItemData.fromJson(row))
            .toList();
        _skills = skills.map((row) => SkillItemData.fromJson(row)).toList();
        _exercises = exercises
            .map((row) => ExerciseItemData.fromJson(row))
            .toList();
      });
    } catch (error) {
      _showError('โหลดข้อมูล Session ไม่สำเร็จ: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) showAdminError(context, message);
  }

  Future<bool> _saveSession(
    SessionItemData? existingSession,
    Map<String, dynamic> body,
  ) async {
    try {
      if (existingSession == null) {
        await AppApi.post('admin/session', body).then(AppApi.unwrap);
      } else {
        await AppApi.put(
          'admin/session/${existingSession.id}',
          body,
        ).then(AppApi.unwrap);
      }
      await _loadData();
      return true;
    } catch (error) {
      _showError('บันทึก Session ไม่สำเร็จ: $error');
      return false;
    }
  }

  Future<void> _showSessionForm([SessionItemData? session]) async {
    if (_skills.isEmpty) {
      _showError('ยังไม่มี Skill ให้เลือก กรุณาเพิ่ม Skill ก่อน');
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionFormDialog(
        existingSession: session,
        skills: _skills,
        exercises: _exercises,
        onSubmit: (body) => _saveSession(session, body),
      ),
    );
  }

  Future<void> _deleteSession(SessionItemData session) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'ลบ Session',
      itemName: session.name,
    );
    if (!confirmed) return;
    try {
      AppApi.unwrap(await AppApi.delete('admin/session/${session.id}'));
      await _loadData();
    } catch (error) {
      _showError('ลบ Session ไม่สำเร็จ: $error');
    }
  }

  List<SessionItemData> get _filteredSessions {
    final query = _searchQuery.toLowerCase();
    return _sessions.where((session) {
      return session.name.toLowerCase().contains(query) ||
          session.skillName.toLowerCase().contains(query) ||
          session.exerciseNames.any(
            (name) => name.toLowerCase().contains(query),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 860;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPageHeader(
              icon: Icons.view_list_rounded,
              title: 'จัดการ Session',
              subtitle: 'Session ทั้งหมด ${_sessions.length} รายการ',
            ),
            const SizedBox(height: 20),
            AdminActionBar(
              isMobile: isMobile,
              searchHint: 'ค้นหา Session, Skill หรือ Exercise...',
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              filters: const [],
              addLabel: 'เพิ่ม Session ใหม่',
              addColor: const Color(0xFF0F766E),
              onAdd: () => _showSessionForm(),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const AdminLoadingView()
            else if (isMobile)
              AdminCardList<SessionItemData>(
                items: _filteredSessions,
                itemBuilder: _buildSessionCard,
              )
            else
              AdminTableCard(
                minWidth: 860,
                columns: const [
                  DataColumn(label: Text('SESSION')),
                  DataColumn(label: Text('SKILL')),
                  DataColumn(label: Text('EXERCISES')),
                  DataColumn(label: Text('จัดการ')),
                ],
                rows: _filteredSessions.map(_buildSessionRow).toList(),
              ),
          ],
        ),
      ),
    );
  }

  DataRow _buildSessionRow(SessionItemData session) {
    return DataRow(
      cells: [
        DataCell(Text(session.name)),
        DataCell(Text(session.skillName)),
        DataCell(Text('${session.exerciseIds.length} รายการ')),
        DataCell(_sessionActions(session)),
      ],
    );
  }

  Widget _buildSessionCard(SessionItemData session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text('Skill: ${session.skillName}'),
        Text('Exercise: ${session.exerciseIds.length} รายการ'),
        if (session.exerciseNames.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            session.exerciseNames.join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        _sessionActions(session),
      ],
    );
  }

  Widget _sessionActions(SessionItemData session) {
    return Wrap(
      spacing: 4,
      children: [
        TextButton.icon(
          onPressed: () => _showSessionForm(session),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('แก้ไข'),
        ),
        TextButton.icon(
          onPressed: () => _deleteSession(session),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('ลบ'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
        ),
      ],
    );
  }
}
