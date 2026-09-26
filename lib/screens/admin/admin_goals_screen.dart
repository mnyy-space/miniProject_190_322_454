import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:halalsefllearning/api/app_api.dart';

class GoalItemData {
  int id;
  String code;
  String name;
  bool isActive;
  List<SkillBadgeData> skills;

  GoalItemData({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.skills,
  });
}

class SkillBadgeData {
  int id;
  String name;
  SkillBadgeData({required this.id, required this.name});
}

class AdminGoalsScreen extends StatefulWidget {
  const AdminGoalsScreen({super.key});

  @override
  State<AdminGoalsScreen> createState() => _AdminGoalsScreenState();
}

class _AdminGoalsScreenState extends State<AdminGoalsScreen> {
  List<GoalItemData> _goals = [];
  List<SkillBadgeData> _availableSkills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch available skills
      final skillsRes = await AppApi.get('admin/skill');
      if (skillsRes.statusCode == 200) {
        final skJson = jsonDecode(skillsRes.body);
        if (skJson['data'] != null && skJson['data'] is List) {
          final List skList = skJson['data'];
          _availableSkills = skList.map((item) {
            return SkillBadgeData(
              id: item['skill_id'] ?? 0,
              name: item['skill_name'] ?? '',
            );
          }).toList();
        }
      }

      // 2. Fetch goals
      final goalsRes = await AppApi.get('admin/goal');
      if (goalsRes.statusCode == 200) {
        final gJson = jsonDecode(goalsRes.body);
        if (gJson['data'] != null && gJson['data'] is List) {
          final List list = gJson['data'];
          setState(() {
            _goals = list.map((item) {
              final List skList = item['skills'] as List? ?? [];
              final skills = skList.map((s) {
                return SkillBadgeData(
                  id: s['skill_id'] ?? 0,
                  name: s['skill_name'] ?? '',
                );
              }).toList();

              return GoalItemData(
                id: item['goal_id'] ?? 0,
                code: item['goal_code'] ?? '',
                name: item['goal_name'] ?? '',
                isActive: item['is_active'] != 0,
                skills: skills,
              );
            }).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading goals data: $e');
    }

    if (_goals.isEmpty) {
      setState(() {
        _goals = [
          GoalItemData(
            id: 1,
            code: 'FULLSTACK_DEV',
            name: 'Fullstack Developer Goal',
            isActive: true,
            skills: [
              SkillBadgeData(id: 1, name: 'function'),
              SkillBadgeData(id: 2, name: 'loop'),
            ],
          ),
        ];
        _isLoading = false;
      });
    }
  }

  void _showAddEditGoalDialog([GoalItemData? existing]) {
    final codeController = TextEditingController(text: existing?.code ?? '');
    final nameController = TextEditingController(text: existing?.name ?? '');
    bool isActive = existing?.isActive ?? true;
    List<int> selectedSkillIds = existing != null
        ? existing.skills.map((s) => s.id).toList()
        : [1];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.track_changes_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 10),
              Text(existing == null ? 'เพิ่ม Goal ใหม่' : 'แก้ไข Goal'),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Goal Code (รหัส)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: 'เช่น FULLSTACK_DEV',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Goal Name (ชื่อเป้าหมาย)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'เช่น Fullstack Developer Goal',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('ผูก Skills (Many-to-Many)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 160),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _availableSkills.isEmpty
                          ? 4
                          : _availableSkills.length,
                      itemBuilder: (context, idx) {
                        final skId = _availableSkills.isNotEmpty
                            ? _availableSkills[idx].id
                            : idx + 1;
                        final skName = _availableSkills.isNotEmpty
                            ? _availableSkills[idx].name
                            : 'Skill #$skId';

                        final isSelected = selectedSkillIds.contains(skId);
                        return CheckboxListTile(
                          title: Text(skName),
                          value: isSelected,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                selectedSkillIds.add(skId);
                              } else {
                                selectedSkillIds.remove(skId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('สถานะเปิดใช้งาน (Active)'),
                      const Spacer(),
                      Switch(
                        value: isActive,
                        activeColor: const Color(0xFF10B981),
                        onChanged: (val) => setDialogState(() => isActive = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              onPressed: () async {
                final nameText = nameController.text.trim();
                final codeText = codeController.text.trim();
                if (nameText.isEmpty) return;

                final body = {
                  'goal_code': codeText.isEmpty ? nameText.toUpperCase() : codeText,
                  'goal_name': nameText,
                  'is_active': isActive ? 1 : 0,
                  'skill_ids': selectedSkillIds,
                };

                try {
                  if (existing == null) {
                    await AppApi.post('admin/goal', body);
                  } else {
                    await AppApi.put('admin/goal/${existing.id}', body);
                  }
                } catch (e) {
                  debugPrint('Error saving goal: $e');
                }

                if (mounted) Navigator.pop(context);
                _loadData();
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.track_changes_rounded, color: Color(0xFF2563EB), size: 26),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('จัดการ Goal (เป้าหมายการเรียน)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Goal ทั้งหมด ${_goals.length} รายการ', style: const TextStyle(color: Color(0xFF64748B))),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                  onPressed: () => _showAddEditGoalDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('เพิ่ม Goal ใหม่'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final item = _goals[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.code,
                                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Switch(
                                    value: item.isActive,
                                    activeColor: const Color(0xFF10B981),
                                    onChanged: (val) async {
                                      setState(() => item.isActive = val);
                                      try {
                                        await AppApi.patch('admin/goal/${item.id}/status', {'is_active': val ? 1 : 0});
                                      } catch (e) {
                                        debugPrint('Error updating goal status: $e');
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
                                    onPressed: () => _showAddEditGoalDialog(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () async {
                                      try {
                                        await AppApi.delete('admin/goal/${item.id}');
                                        _loadData();
                                      } catch (e) {
                                        debugPrint('Error deleting goal: $e');
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: item.skills.map((s) {
                                  return Chip(
                                    label: Text(s.name, style: const TextStyle(fontSize: 12)),
                                    backgroundColor: const Color(0xFFEFF6FF),
                                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
