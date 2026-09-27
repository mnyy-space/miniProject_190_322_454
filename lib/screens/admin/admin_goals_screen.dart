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
  String _searchQuery = '';
  String _selectedStatusFilter = 'ทุกสถานะ';

  // รายการ Skill ทั้งหมดที่มีให้เลือกใน Dropdown ของฟอร์ม
  final List<String> _availableSkills = [
    'Arrays & Linked Lists',
    'Classes & Objects',
    'Control Flow',
    'Database Design',
    'midterm_skill',
    'Functions for test',
    'Recursion & Sorting',
    'stack',
    'tree',
    'supabase',
    'Test Skill Alpha',
  ];

  @override
  void initState() {
    super.initState();
    _loadSampleGoals();
  }

  void _loadSampleGoals() {
    // ข้อมูลเริ่มต้นตรงตามภาพตัวอย่างที่ให้มา
    setState(() {
      _goals = [
        GoalItemData(
          id: 1,
          name: 'goal_for_midterm_test',
          description: 'test goal',
          isActive: false,
          requiredSkills: [
            GoalRequiredSkill(skillName: 'Arrays & Linked Lists', level: 3),
            GoalRequiredSkill(skillName: 'midterm_skill', level: 3),
            GoalRequiredSkill(skillName: 'Functions for test', level: 1),
          ],
        ),
        GoalItemData(
          id: 2,
          name: 'present-goal',
          description: 'เป้าหมายสำหรับการนำเสนอโปรเจกต์',
          isActive: true,
          requiredSkills: [
            GoalRequiredSkill(skillName: 'Arrays & Linked Lists', level: 2),
            GoalRequiredSkill(skillName: 'Recursion & Sorting', level: 2),
            GoalRequiredSkill(skillName: 'Control Flow', level: 1),
          ],
        ),
        GoalItemData(
          id: 3,
          name: 'Data Structures & Algorithms',
          description: 'โครงสร้างข้อมูลและอัลกอริทึมพื้นฐาน',
          isActive: true,
          requiredSkills: [
            GoalRequiredSkill(skillName: 'Arrays & Linked Lists', level: 3),
            GoalRequiredSkill(skillName: 'stack', level: 2),
            GoalRequiredSkill(skillName: 'tree', level: 2),
            GoalRequiredSkill(skillName: 'Recursion & Sorting', level: 3),
          ],
        ),
        GoalItemData(
          id: 4,
          name: 'testGoal',
          description: 'ทดสอบเชื่อมต่อฐานข้อมูลและการสร้างโกล',
          isActive: false,
          requiredSkills: [
            GoalRequiredSkill(skillName: 'supabase', level: 1),
            GoalRequiredSkill(skillName: 'Test Skill Alpha', level: 1),
          ],
        ),
      ];
    });
  }

  List<GoalItemData> get _filteredGoals {
    return _goals.where((goal) {
      final matchesSearch = goal.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          goal.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          goal.requiredSkills.any((s) =>
              s.skillName.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesStatus = _selectedStatusFilter == 'ทุกสถานะ' ||
          (_selectedStatusFilter == 'Active' && goal.isActive) ||
          (_selectedStatusFilter == 'Inactive' && !goal.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Dialog สำหรับ "+ เพิ่ม Goal ใหม่" และ "แก้ไข Goal" (ตรงตาม Image 2)
  void _showAddOrEditGoalDialog([GoalItemData? existingGoal]) {
    final nameController =
        TextEditingController(text: existingGoal?.name ?? '');
    final descController =
        TextEditingController(text: existingGoal?.description ?? '');

    String? selectedSkill;
    int selectedLevel = 1;
    final List<GoalRequiredSkill> currentRequiredSkills = existingGoal != null
        ? List.from(existingGoal.requiredSkills)
        : [];
    bool isActive = existingGoal?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          title: Text(
            existingGoal == null ? '+ เพิ่ม Goal ใหม่' : '✏️ แก้ไข Goal',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A8A),
            ),
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อ GOAL
                  const Text(
                    'ชื่อ GOAL',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'กรอกชื่อ Goal...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // คำอธิบาย
                  const Text(
                    'คำอธิบาย',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'กรอกคำอธิบายของ Goal...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.all(12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // SKILL ที่ต้องใช้
                  const Text(
                    'SKILL ที่ต้องใช้',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dropdown เลือก Skill + Level + ปุ่ม "+ เพิ่ม"
                  Row(
                    children: [
                      // Dropdown: เลือก Skill
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSkill,
                              hint: const Text(
                                '-- เลือก Skill --',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              isExpanded: true,
                              items: _availableSkills
                                  .map((skill) => DropdownMenuItem(
                                        value: skill,
                                        child: Text(
                                          skill,
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setDialogState(() => selectedSkill = val);
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Dropdown: Level
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedLevel,
                              isExpanded: true,
                              items: [1, 2, 3, 4, 5]
                                  .map((lvl) => DropdownMenuItem(
                                        value: lvl,
                                        child: Text(
                                          'Level $lvl',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() => selectedLevel = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // ปุ่ม "+ เพิ่ม"
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0256B8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (selectedSkill == null || selectedSkill!.isEmpty) {
                            return;
                          }
                          // ป้องกันเพิ่มซ้ำ
                          final exists = currentRequiredSkills.any(
                              (item) => item.skillName == selectedSkill);
                          if (!exists) {
                            setDialogState(() {
                              currentRequiredSkills.add(
                                GoalRequiredSkill(
                                  skillName: selectedSkill!,
                                  level: selectedLevel,
                                ),
                              );
                            });
                          }
                        },
                        child: const Text(
                          '+ เพิ่ม',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // แสดงรายการ Skill ที่ถูกเลือก หรือข้อความ "— ยังไม่ได้เลือก Skill —"
                  currentRequiredSkills.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '— ยังไม่ได้เลือก Skill —',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: currentRequiredSkills.map((reqSkill) {
                            return Chip(
                              backgroundColor: const Color(0xFFEFF6FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: Color(0xFFBFDBFE),
                                ),
                              ),
                              label: Text(
                                '${reqSkill.skillName} (Level ${reqSkill.level})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              deleteIcon: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Color(0xFFEF4444),
                              ),
                              onDeleted: () {
                                setDialogState(() {
                                  currentRequiredSkills.remove(reqSkill);
                                });
                              },
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 16),

                  // สวิตช์สถานะเปิดใช้งาน
                  Row(
                    children: [
                      const Text(
                        'สถานะเปิดใช้งาน (Active)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: isActive,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (val) {
                          setDialogState(() => isActive = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF334155),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0256B8),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;

                setState(() {
                  if (existingGoal == null) {
                    _goals.add(
                      GoalItemData(
                        id: _goals.length + 1,
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                        isActive: isActive,
                        requiredSkills: currentRequiredSkills,
                      ),
                    );
                  } else {
                    existingGoal.name = nameController.text.trim();
                    existingGoal.description = descController.text.trim();
                    existingGoal.isActive = isActive;
                    existingGoal.requiredSkills = currentRequiredSkills;
                  }
                });

                Navigator.pop(context);
              },
              child: const Text('บันทึก', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog รายละเอียด Goal (ตรงตาม Image 3: 🔍 รายละเอียด Goal + Learning Tree)
  void _showGoalDetailDialog(GoalItemData goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        title: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF1E3A8A),
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text(
              'รายละเอียด Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),

                // ชื่อ GOAL
                const Text(
                  'ชื่อ GOAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goal.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),

                const SizedBox(height: 18),

                // คำอธิบาย
                const Text(
                  'คำอธิบาย',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goal.description.isEmpty ? '—' : goal.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 18),

                // สถานะ
                const Text(
                  'สถานะ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: goal.isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      goal.isActive ? 'active' : 'inactive',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: goal.isActive
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // SKILL ที่ต้องใช้ (LEVEL ที่ต้องการ)
                const Text(
                  'SKILL ที่ต้องใช้ (LEVEL ที่ต้องการ)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                goal.requiredSkills.isEmpty
                    ? const Text(
                        '— ไม่มีเงื่อนไข Skill —',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: goal.requiredSkills.map((req) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Text(
                              '${req.skillName} (level ${req.level})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 24),

                // LEARNING TREE
                const Text(
                  'LEARNING TREE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                goal.requiredSkills.isEmpty
                    ? const Text(
                        '— ไม่มีผัง Learning Tree —',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: goal.requiredSkills.map((req) {
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(14),
                              width: 170,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    req.skillName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'level ${req.level}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF334155),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0256B8),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showAddOrEditGoalDialog(goal);
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('แก้ไข', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 860;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section: "🎯 จัดการ Goal" + จำนวนรายการ (ตรงตาม Image 1)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Color(0xFF2563EB),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'จัดการ Goal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Goal ทั้งหมด ${_goals.length} รายการ',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action Bar: Search Input + Status Filter + "+ เพิ่ม Goal ใหม่"
            isMobile ? _buildMobileActionBar() : _buildDesktopActionBar(),

            const SizedBox(height: 20),

            // Data Presentation (Desktop Table or Mobile Cards)
            isMobile ? _buildMobileListView() : _buildDesktopDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopActionBar() {
    return Row(
      children: [
        // Search TextField
        Expanded(
          flex: 4,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'ค้นหาชื่อ Goal...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Color(0xFF94A3B8), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Filter Dropdown
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatusFilter,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: ['ทุกสถานะ', 'Active', 'Inactive']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStatusFilter = val);
              },
            ),
          ),
        ),

        const SizedBox(width: 12),

        // "+ เพิ่ม Goal ใหม่" Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0256B8),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _showAddOrEditGoalDialog(),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'เพิ่ม Goal ใหม่',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileActionBar() {
    return Column(
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: const InputDecoration(
              hintText: 'ค้นหาชื่อ Goal...',
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded,
                  color: Color(0xFF94A3B8), size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatusFilter,
                    isExpanded: true,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    items: ['ทุกสถานะ', 'Active', 'Inactive']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedStatusFilter = val);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0256B8),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _showAddOrEditGoalDialog(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'เพิ่มใหม่',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Desktop Table (ตรงตาม Image 1)
  Widget _buildDesktopDataTable() {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 950),
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              horizontalMargin: 24,
              columnSpacing: 28,
              headingTextStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
              columns: const [
                DataColumn(label: Text('Goal')),
                DataColumn(label: Text('Skill Require')),
                DataColumn(label: Text('Actions')),
                DataColumn(label: Text('สถานะ')),
              ],
              rows: _filteredGoals.map((goal) {
                return DataRow(
                  cells: [
                    // Goal Name
                    DataCell(
                      Text(
                        goal.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: goal.isActive
                              ? const Color(0xFF1E3A8A)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),

                    // Skill Require (Tags แสดงผลแนวนอน)
                    DataCell(
                      SizedBox(
                        width: 320,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: goal.requiredSkills.map((req) {
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Text(
                                  req.skillName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    // Actions: ดู / แก้ไข
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPillButton(
                            icon: Icons.visibility_outlined,
                            label: 'ดู',
                            onTap: () => _showGoalDetailDialog(goal),
                          ),
                          const SizedBox(width: 8),
                          _buildPillButton(
                            icon: Icons.edit_outlined,
                            label: 'แก้ไข',
                            onTap: () => _showAddOrEditGoalDialog(goal),
                          ),
                        ],
                      ),
                    ),

                    // สถานะ (Active / Inactive Toggle Switch)
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: goal.isActive,
                            activeThumbColor: const Color(0xFF10B981),
                            onChanged: (val) {
                              setState(() => goal.isActive = val);
                            },
                          ),
                          const SizedBox(width: 4),
                          Text(
                            goal.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: goal.isActive
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // Mobile Cards ListView (สไตล์ WS06 ListTile Layout ของอาจารย์)
  Widget _buildMobileListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredGoals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final goal = _filteredGoals[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: goal.isActive
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFF475569),
                          ),
                        ),
                        if (goal.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            goal.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Switch(
                    value: goal.isActive,
                    activeThumbColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() => goal.isActive = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tags
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: goal.requiredSkills.map((req) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        '${req.skillName} (L${req.level})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 8),

              // Action buttons on mobile
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildPillButton(
                    icon: Icons.visibility_outlined,
                    label: 'ดู',
                    onTap: () => _showGoalDetailDialog(goal),
                  ),
                  const SizedBox(width: 8),
                  _buildPillButton(
                    icon: Icons.edit_outlined,
                    label: 'แก้ไข',
                    onTap: () => _showAddOrEditGoalDialog(goal),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPillButton({
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
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF2563EB)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalItemData {
  int id;
  String name;
  String description;
  List<GoalRequiredSkill> requiredSkills;
  bool isActive;

  GoalItemData({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredSkills,
    required this.isActive,
  });
}

class GoalRequiredSkill {
  String skillName;
  int level;

  GoalRequiredSkill({
    required this.skillName,
    required this.level,
  });
}
