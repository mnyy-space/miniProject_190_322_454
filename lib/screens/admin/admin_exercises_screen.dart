import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/admin/exercise_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_action_bar.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_list_widgets.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_page_header.dart';
import 'package:halalsefllearning/widgets/admin/exercise/exercise_detail_dialog.dart';
import 'package:halalsefllearning/widgets/admin/exercise/exercise_form_dialog.dart';
import 'package:halalsefllearning/widgets/admin/exercise/exercise_list_views.dart';

class AdminExercisesScreen extends StatefulWidget {
  const AdminExercisesScreen({super.key});

  @override
  State<AdminExercisesScreen> createState() => _AdminExercisesScreenState();
}

class _AdminExercisesScreenState extends State<AdminExercisesScreen> {
  List<ExerciseItemData> _exercises = [];
  List<ExerciseSkillOption> _skillOptions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSkillFilter = 'ทุก Skill';
  String _selectedTypeFilter = 'ทุกประเภท';
  String _selectedStatusFilter = 'ทุกสถานะ';

  List<String> get _skillFilterItems =>
      ['ทุก Skill', ..._skillOptions.map((s) => s.name).toSet()];

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _loadSkillOptions();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final List list = AppApi.unwrap(await AppApi.get('admin/exercise')) ?? [];
      if (!mounted) return;
      setState(() {
        _exercises = list.map((item) => ExerciseItemData.fromJson(item)).toList();
      });
    } catch (e) {
      _showError('โหลดข้อมูล Exercise ไม่สำเร็จ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSkillOptions() async {
    try {
      final List list = AppApi.unwrap(await AppApi.get('admin/skill')) ?? [];
      if (!mounted) return;
      setState(() {
        _skillOptions = list.map((s) => ExerciseSkillOption.fromJson(s)).toList();
        if (!_skillFilterItems.contains(_selectedSkillFilter)) {
          _selectedSkillFilter = 'ทุก Skill';
        }
      });
    } catch (e) {
      _showError('โหลดรายการ Skill ไม่สำเร็จ: $e');
    }
  }

  void _showError(String message) {
    if (mounted) showAdminError(context, message);
  }

  Future<void> _changeExerciseStatus(ExerciseItemData exercise, bool val) async {
    setState(() => exercise.isActive = val);
    try {
      AppApi.unwrap(await AppApi.patch('admin/exercise/${exercise.id}/status', {
        'is_active': val ? 1 : 0,
      }));
    } catch (e) {
      if (mounted) setState(() => exercise.isActive = !val);
      _showError('เปลี่ยนสถานะไม่สำเร็จ: $e');
    }
  }

  Future<void> _showExerciseFormDialog([ExerciseItemData? existingExercise]) async {
    if (_skillOptions.isEmpty) {
      _showError('ยังไม่มี Skill ให้เลือก กรุณาเพิ่ม Skill ก่อน');
      return;
    }

    final result = await showDialog<ExerciseItemData>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExerciseFormDialog(
        existingExercise: existingExercise,
        skillOptions: _skillOptions,
      ),
    );
    if (result == null) return;

    try {
      final body = result.toRequestBody();
      int exerciseId;
      if (existingExercise == null) {
        final data = AppApi.unwrap(await AppApi.post('admin/exercise', body));
        exerciseId = data['exercise_id'];
      } else {
        AppApi.unwrap(await AppApi.put('admin/exercise/${existingExercise.id}', body));
        exerciseId = existingExercise.id;
      }

      // สร้างใหม่จะเป็น active เสมอ จึงต้องอัปเดตสถานะแยกถ้าไม่ตรงกับที่เลือก
      final previousActive = existingExercise?.isActive ?? true;
      if (result.isActive != previousActive) {
        AppApi.unwrap(await AppApi.patch('admin/exercise/$exerciseId/status', {
          'is_active': result.isActive ? 1 : 0,
        }));
      }
    } catch (e) {
      _showError('บันทึก Exercise ไม่สำเร็จ: $e');
    }
    _loadExercises();
  }

  void _showExerciseDetailDialog(ExerciseItemData exercise) {
    showDialog(
      context: context,
      builder: (context) => ExerciseDetailDialog(exercise: exercise),
    );
  }

  List<ExerciseItemData> get _filteredExercises {
    return _exercises.where((exercise) {
      final matchesSearch =
          exercise.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesSkill =
          _selectedSkillFilter == 'ทุก Skill' || exercise.skill == _selectedSkillFilter;

      final matchesType =
          _selectedTypeFilter == 'ทุกประเภท' || exercise.type == _selectedTypeFilter;

      final matchesStatus = _selectedStatusFilter == 'ทุกสถานะ' ||
          (_selectedStatusFilter == 'Active' && exercise.isActive) ||
          (_selectedStatusFilter == 'Inactive' && !exercise.isActive);

      return matchesSearch && matchesSkill && matchesType && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 860;
    final callbacks = ExerciseRowCallbacks(
      onView: _showExerciseDetailDialog,
      onEdit: _showExerciseFormDialog,
      onStatusChanged: _changeExerciseStatus,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPageHeader(
              icon: Icons.edit_note_rounded,
              title: 'จัดการ Exercise',
              subtitle: 'Exercise ทั้งหมด ${_exercises.length} รายการ',
            ),
            const SizedBox(height: 20),
            AdminActionBar(
              isMobile: isMobile,
              searchHint: 'ค้นหาคำอธิบายโจทย์...',
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              filters: [
                AdminFilter(
                  value: _selectedSkillFilter,
                  items: _skillFilterItems,
                  onChanged: (val) => setState(() => _selectedSkillFilter = val),
                ),
                AdminFilter(
                  value: _selectedTypeFilter,
                  items: const ['ทุกประเภท', 'CHOICE', 'FILL_IN_BLANK'],
                  onChanged: (val) => setState(() => _selectedTypeFilter = val),
                ),
                AdminFilter(
                  value: _selectedStatusFilter,
                  items: const ['ทุกสถานะ', 'Active', 'Inactive'],
                  onChanged: (val) => setState(() => _selectedStatusFilter = val),
                ),
              ],
              addLabel: 'เพิ่ม Exercise ใหม่',
              addColor: const Color(0xFF1D4ED8),
              onAdd: () => _showExerciseFormDialog(),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const AdminLoadingView()
            else if (isMobile)
              AdminCardList<ExerciseItemData>(
                items: _filteredExercises,
                itemBuilder: (exercise) =>
                    ExerciseMobileCard(exercise: exercise, callbacks: callbacks),
              )
            else
              ExerciseDataTable(exercises: _filteredExercises, callbacks: callbacks),
          ],
        ),
      ),
    );
  }
}
