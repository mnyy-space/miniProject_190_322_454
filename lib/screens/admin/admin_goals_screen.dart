import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/admin/goal_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_action_bar.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_list_widgets.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_page_header.dart';
import 'package:halalsefllearning/widgets/admin/goal/goal_detail_dialog.dart';
import 'package:halalsefllearning/widgets/admin/goal/goal_form_dialog.dart';
import 'package:halalsefllearning/widgets/admin/goal/goal_list_views.dart';

class AdminGoalsScreen extends StatefulWidget {
  const AdminGoalsScreen({super.key});

  @override
  State<AdminGoalsScreen> createState() => _AdminGoalsScreenState();
}

class _AdminGoalsScreenState extends State<AdminGoalsScreen> {
  List<GoalItemData> _goals = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatusFilter = 'ทุกสถานะ';

  // รายการ Skill ทั้งหมดที่มีให้เลือกใน Dropdown ของฟอร์ม (โหลดจาก admin/skill)
  List<GoalRequiredSkill> _availableSkills = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _loadAvailableSkills();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    try {
      final List list = AppApi.unwrap(await AppApi.get('admin/goal')) ?? [];
      if (!mounted) return;
      setState(() => _goals = list.map((item) => GoalItemData.fromJson(item)).toList());
    } catch (e) {
      _showError('โหลดข้อมูล Goal ไม่สำเร็จ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailableSkills() async {
    try {
      final List list = AppApi.unwrap(await AppApi.get('admin/skill')) ?? [];
      if (!mounted) return;
      setState(() {
        _availableSkills = list.map((s) => GoalRequiredSkill.fromJson(s)).toList();
      });
    } catch (e) {
      _showError('โหลดรายการ Skill ไม่สำเร็จ: $e');
    }
  }

  void _showError(String message) {
    if (mounted) showAdminError(context, message);
  }

  Future<void> _changeGoalStatus(GoalItemData goal, bool val) async {
    setState(() => goal.isActive = val);
    try {
      AppApi.unwrap(await AppApi.patch('admin/goal/${goal.id}/status', {
        'is_active': val ? 1 : 0,
      }));
    } catch (e) {
      if (mounted) setState(() => goal.isActive = !val);
      _showError('เปลี่ยนสถานะไม่สำเร็จ: $e');
    }
  }

  Future<void> _confirmDeleteGoal(GoalItemData goal) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'ลบ Goal',
      itemName: goal.name,
    );
    if (!confirmed) return;
    try {
      AppApi.unwrap(await AppApi.delete('admin/goal/${goal.id}'));
      _loadGoals();
    } catch (e) {
      _showError('ลบ Goal ไม่สำเร็จ: $e');
    }
  }

  Future<bool> _saveGoal(GoalItemData? existingGoal, Map<String, dynamic> body) async {
    try {
      if (existingGoal == null) {
        AppApi.unwrap(await AppApi.post('admin/goal', body));
      } else {
        AppApi.unwrap(await AppApi.put('admin/goal/${existingGoal.id}', body));
      }
    } catch (e) {
      _showError('บันทึก Goal ไม่สำเร็จ: $e');
      return false;
    }
    _loadGoals();
    return true;
  }

  void _showGoalFormDialog([GoalItemData? existingGoal]) {
    showDialog(
      context: context,
      builder: (context) => GoalFormDialog(
        existingGoal: existingGoal,
        availableSkills: _availableSkills,
        onSubmit: (body) => _saveGoal(existingGoal, body),
      ),
    );
  }

  void _showGoalDetailDialog(GoalItemData goal) {
    showDialog(
      context: context,
      builder: (context) => GoalDetailDialog(
        goal: goal,
        onEdit: () => _showGoalFormDialog(goal),
        onDelete: () => _confirmDeleteGoal(goal),
      ),
    );
  }

  List<GoalItemData> get _filteredGoals {
    final query = _searchQuery.toLowerCase();
    return _goals.where((goal) {
      final matchesSearch = goal.name.toLowerCase().contains(query) ||
          goal.code.toLowerCase().contains(query) ||
          goal.requiredSkills.any((s) => s.skillName.toLowerCase().contains(query));

      final matchesStatus = _selectedStatusFilter == 'ทุกสถานะ' ||
          (_selectedStatusFilter == 'Active' && goal.isActive) ||
          (_selectedStatusFilter == 'Inactive' && !goal.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 860;
    final callbacks = GoalRowCallbacks(
      onView: _showGoalDetailDialog,
      onEdit: _showGoalFormDialog,
      onDelete: _confirmDeleteGoal,
      onStatusChanged: _changeGoalStatus,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPageHeader(
              icon: Icons.track_changes_rounded,
              title: 'จัดการ Goal',
              subtitle: 'Goal ทั้งหมด ${_goals.length} รายการ',
            ),
            const SizedBox(height: 20),
            AdminActionBar(
              isMobile: isMobile,
              searchHint: 'ค้นหาชื่อ Goal...',
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              filters: [
                AdminFilter(
                  value: _selectedStatusFilter,
                  items: const ['ทุกสถานะ', 'Active', 'Inactive'],
                  onChanged: (val) => setState(() => _selectedStatusFilter = val),
                ),
              ],
              addLabel: 'เพิ่ม Goal ใหม่',
              addColor: const Color(0xFF0256B8),
              onAdd: () => _showGoalFormDialog(),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const AdminLoadingView()
            else if (isMobile)
              AdminCardList<GoalItemData>(
                items: _filteredGoals,
                itemBuilder: (goal) => GoalMobileCard(goal: goal, callbacks: callbacks),
              )
            else
              GoalDataTable(goals: _filteredGoals, callbacks: callbacks),
          ],
        ),
      ),
    );
  }
}
