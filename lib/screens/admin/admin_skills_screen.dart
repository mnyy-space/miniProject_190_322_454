import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/admin/skill_item_data.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_action_bar.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_form_widgets.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_list_widgets.dart';
import 'package:halalsefllearning/widgets/admin/common/admin_page_header.dart';
import 'package:halalsefllearning/widgets/admin/skill/skill_detail_dialog.dart';
import 'package:halalsefllearning/widgets/admin/skill/skill_form_dialog.dart';
import 'package:halalsefllearning/widgets/admin/skill/skill_list_views.dart';

class AdminSkillsScreen extends StatefulWidget {
  const AdminSkillsScreen({super.key});

  @override
  State<AdminSkillsScreen> createState() => _AdminSkillsScreenState();
}

class _AdminSkillsScreenState extends State<AdminSkillsScreen> {
  List<SkillItemData> _skills = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatusFilter = 'ทุกสถานะ';

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() => _isLoading = true);
    try {
      final List list = AppApi.unwrap(await AppApi.get('admin/skill')) ?? [];
      if (!mounted) return;
      setState(() => _skills = list.map((item) => SkillItemData.fromJson(item)).toList());
    } catch (e) {
      _showError('โหลดข้อมูล Skill ไม่สำเร็จ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) showAdminError(context, message);
  }

  Future<void> _changeSkillStatus(SkillItemData skill, bool val) async {
    setState(() => skill.isActive = val);
    try {
      AppApi.unwrap(await AppApi.patch('admin/skill/${skill.id}/status', {
        'is_active': val ? 1 : 0,
      }));
    } catch (e) {
      if (mounted) setState(() => skill.isActive = !val);
      _showError('เปลี่ยนสถานะไม่สำเร็จ: $e');
    }
  }

  Future<void> _confirmDeleteSkill(SkillItemData skill) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'ลบ Skill',
      itemName: skill.name,
    );
    if (!confirmed) return;
    try {
      AppApi.unwrap(await AppApi.delete('admin/skill/${skill.id}'));
      _loadSkills();
    } catch (e) {
      _showError('ลบ Skill ไม่สำเร็จ: $e');
    }
  }

  Future<bool> _saveSkill(SkillItemData? existingSkill, Map<String, dynamic> body) async {
    try {
      if (existingSkill == null) {
        AppApi.unwrap(await AppApi.post('admin/skill', body));
      } else {
        AppApi.unwrap(await AppApi.put('admin/skill/${existingSkill.id}', body));
      }
    } catch (e) {
      _showError('บันทึก Skill ไม่สำเร็จ: $e');
      return false;
    }
    _loadSkills();
    return true;
  }

  void _showSkillFormDialog([SkillItemData? existingSkill]) {
    showDialog(
      context: context,
      builder: (context) => SkillFormDialog(
        existingSkill: existingSkill,
        onSubmit: (body) => _saveSkill(existingSkill, body),
      ),
    );
  }

  void _showSkillDetailDialog(SkillItemData skill) {
    showDialog(
      context: context,
      builder: (context) => SkillDetailDialog(skill: skill),
    );
  }

  List<SkillItemData> get _filteredSkills {
    final query = _searchQuery.toLowerCase();
    return _skills.where((skill) {
      final matchesSearch = skill.name.toLowerCase().contains(query) ||
          skill.code.toLowerCase().contains(query) ||
          skill.tier.toLowerCase().contains(query);

      final matchesStatus = _selectedStatusFilter == 'ทุกสถานะ' ||
          (_selectedStatusFilter == 'Active' && skill.isActive) ||
          (_selectedStatusFilter == 'Inactive' && !skill.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 860;
    final callbacks = SkillRowCallbacks(
      onView: _showSkillDetailDialog,
      onEdit: _showSkillFormDialog,
      onDelete: _confirmDeleteSkill,
      onStatusChanged: _changeSkillStatus,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPageHeader(
              icon: Icons.folder_rounded,
              title: 'จัดการ Skill',
              subtitle: 'Skill ทั้งหมด ${_skills.length} รายการ',
            ),
            const SizedBox(height: 20),
            AdminActionBar(
              isMobile: isMobile,
              searchHint: 'ค้นหาชื่อ Skill, Tier...',
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              filters: [
                AdminFilter(
                  value: _selectedStatusFilter,
                  items: const ['ทุกสถานะ', 'Active', 'Inactive'],
                  onChanged: (val) => setState(() => _selectedStatusFilter = val),
                ),
              ],
              addLabel: 'เพิ่ม Skill ใหม่',
              onAdd: () => _showSkillFormDialog(),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const AdminLoadingView()
            else if (isMobile)
              AdminCardList<SkillItemData>(
                items: _filteredSkills,
                itemBuilder: (skill) => SkillMobileCard(skill: skill, callbacks: callbacks),
              )
            else
              SkillDataTable(skills: _filteredSkills, callbacks: callbacks),
          ],
        ),
      ),
    );
  }
}
