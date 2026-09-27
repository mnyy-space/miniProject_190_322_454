import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:halalsefllearning/api/app_api.dart';

// ============================================================
// Model
// ============================================================
class ExerciseItemData {
  int id;
  String description;
  String codeSnippet; // โค้ดประกอบโจทย์ (ไม่บังคับ) อาจมี ____ เป็นช่องว่าง
  String language; // ภาษาของโค้ด เช่น Python
  int level;
  String skill;
  int expectedTime; // เวลาที่คาดหวัง
  String timeUnit; // หน่วยเวลา เช่น นาที (minute)
  String type; // CHOICE หรือ FILL_IN_BLANK
  String correctAnswer; // คำตอบที่ถูกต้อง (สำหรับ FILL_IN_BLANK)
  bool caseSensitive; // ตรวจตัวพิมพ์เล็ก/ใหญ่
  List<String> choices; // ตัวเลือก (สำหรับ CHOICE)
  int correctChoiceIndex; // index ของตัวเลือกที่ถูกต้อง (สำหรับ CHOICE)
  bool isActive;

  ExerciseItemData({
    required this.id,
    required this.description,
    this.codeSnippet = '',
    this.language = 'Python',
    required this.level,
    required this.skill,
    this.expectedTime = 3,
    this.timeUnit = 'นาที (minute)',
    required this.type,
    this.correctAnswer = '',
    this.caseSensitive = false,
    List<String>? choices,
    this.correctChoiceIndex = 0,
    required this.isActive,
  }) : choices = choices ?? [];
}

// ============================================================
// Screen
// ============================================================
class AdminExercisesScreen extends StatefulWidget {
  const AdminExercisesScreen({super.key});

  @override
  State<AdminExercisesScreen> createState() => _AdminExercisesScreenState();
}

class _AdminExercisesScreenState extends State<AdminExercisesScreen> {
  List<ExerciseItemData> _exercises = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSkillFilter = 'ทุก Skill';
  String _selectedTypeFilter = 'ทุกประเภท';
  String _selectedStatusFilter = 'ทุกสถานะ';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final response = await AppApi.get('exercise');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] != null && json['data'] is List) {
          final List list = json['data'];
          setState(() {
            _exercises = list.map((item) {
              final id = item['exercise_id'] ?? 0;
              final description = item['description'] ?? '';
              final skill = item['skill_name'] ?? '';
              final level = item['level'] ?? 1;
              final type = item['type'] ?? 'CHOICE';
              return ExerciseItemData(
                id: id,
                description: description,
                codeSnippet: item['code_snippet'] ?? '',
                language: item['language'] ?? 'Python',
                skill: skill,
                level: level is int ? level : int.tryParse(level.toString()) ?? 1,
                expectedTime: item['expected_time'] is int
                    ? item['expected_time']
                    : int.tryParse('${item['expected_time'] ?? 3}') ?? 3,
                timeUnit: item['time_unit'] ?? 'นาที (minute)',
                type: type,
                correctAnswer: item['correct_answer'] ?? '',
                caseSensitive: item['case_sensitive'] ?? false,
                isActive: true,
              );
            }).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading exercises: $e');
    }

    // ข้อมูลเริ่มต้นสำหรับแสดงผลให้เหมือนในภาพตัวอย่างหากยังไม่มีใน DB
    if (_exercises.isEmpty) {
      setState(() {
        _exercises = [
          ExerciseItemData(
            id: 1,
            description:
                'พิจารณาโค้ดด้านล่างนี้ หากต้องการเปลี่ยนการทำงานจากการดึงข้อมูลแบบ Stack (LIFO) ให้เป็นการดึงข้อมูลแบบ Queue (FIFO) โดยใช้ List เดิม จะต้องแก้ไขบรรทัดที่แสดงผลลัพธ์อย่างไร',
            codeSnippet:
                'data = [1, 2, 3, 4]\n# Current: Stack behavior\nval = data.____\nprint(val)',
            language: 'Python',
            skill: 'stack',
            level: 4,
            expectedTime: 3,
            timeUnit: 'นาที (minute)',
            type: 'FILL_IN_BLANK',
            correctAnswer: 'pop(0)',
            caseSensitive: false,
            isActive: true,
          ),
          ExerciseItemData(
            id: 2,
            description:
                'วิเคราะห์โค้ดต่อไปนี้ ผลลัพธ์สุดท้ายของตัวแปร \'result\' คืออะ...',
            skill: 'stack',
            level: 4,
            type: 'CHOICE',
            choices: const ['1', '2', '3', '4'],
            correctChoiceIndex: 0,
            isActive: true,
          ),
          ExerciseItemData(
            id: 3,
            description:
                'พิจารณาโค้ดการประมวลผลตัวเลขด้วย Stack ต่อไปนี้ หากต้องการให้...',
            skill: 'stack',
            level: 4,
            type: 'CHOICE',
            choices: const ['1', '2', '3', '4'],
            correctChoiceIndex: 0,
            isActive: true,
          ),
          ExerciseItemData(
            id: 4,
            description:
                'พิจารณาโค้ดจำลองการทำงานของ Undo/Redo ด้านล่าง หากต้องการ...',
            skill: 'stack',
            level: 5,
            type: 'CHOICE',
            choices: const ['1', '2', '3', '4'],
            correctChoiceIndex: 0,
            isActive: true,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  List<ExerciseItemData> get _filteredExercises {
    return _exercises.where((exercise) {
      final matchesSearch = exercise.description
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());

      final matchesSkill = _selectedSkillFilter == 'ทุก Skill' ||
          exercise.skill == _selectedSkillFilter;

      final matchesType = _selectedTypeFilter == 'ทุกประเภท' ||
          exercise.type == _selectedTypeFilter;

      final matchesStatus = _selectedStatusFilter == 'ทุกสถานะ' ||
          (_selectedStatusFilter == 'Active' && exercise.isActive) ||
          (_selectedStatusFilter == 'Inactive' && !exercise.isActive);

      return matchesSearch && matchesSkill && matchesType && matchesStatus;
    }).toList();
  }

  Future<void> _showAddExerciseDialog([ExerciseItemData? existingExercise]) async {
    final result = await showDialog<ExerciseItemData>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ExerciseEditDialog(existingExercise: existingExercise),
    );

    if (result != null) {
      setState(() {
        if (existingExercise == null) {
          _exercises.add(result);
        } else {
          final index =
              _exercises.indexWhere((e) => e.id == existingExercise.id);
          if (index != -1) {
            _exercises[index] = result;
          }
        }
      });
    }
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
            // Header Section: "จัดการ Exercise" + จำนวนรายการ
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Color(0xFF2563EB),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'จัดการ Exercise',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Exercise ทั้งหมด ${_exercises.length} รายการ',
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

            // Action Bar: Search + Filters + "+ เพิ่ม Exercise ใหม่"
            isMobile ? _buildMobileActionBar() : _buildDesktopActionBar(),

            const SizedBox(height: 20),

            // Content Table or Mobile Cards
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child:
                          CircularProgressIndicator(color: Color(0xFF2563EB)),
                    ),
                  )
                : isMobile
                    ? _buildMobileListView()
                    : _buildDesktopDataTable(),
          ],
        ),
      ),
    );
  }

  // Action Bar บน Desktop
  Widget _buildDesktopActionBar() {
    return Row(
      children: [
        Expanded(
          flex: 3,
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
                hintText: 'ค้นหาคำอธิบายโจทย์...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon:
                    Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildFilterDropdown(
          value: _selectedSkillFilter,
          items: const ['ทุก Skill', 'stack', 'queue', 'tree'],
          onChanged: (val) => setState(() => _selectedSkillFilter = val),
        ),
        const SizedBox(width: 12),
        _buildFilterDropdown(
          value: _selectedTypeFilter,
          items: const ['ทุกประเภท', 'CHOICE', 'FILL_IN_BLANK'],
          onChanged: (val) => setState(() => _selectedTypeFilter = val),
        ),
        const SizedBox(width: 12),
        _buildFilterDropdown(
          value: _selectedStatusFilter,
          items: const ['ทุกสถานะ', 'Active', 'Inactive'],
          onChanged: (val) => setState(() => _selectedStatusFilter = val),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D4ED8),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _showAddExerciseDialog(),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'เพิ่ม Exercise ใหม่',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: items
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  // Action Bar บน Mobile
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
              hintText: 'ค้นหาคำอธิบายโจทย์...',
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              prefixIcon:
                  Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedSkillFilter,
                items: const ['ทุก Skill', 'stack', 'queue', 'tree'],
                onChanged: (val) => setState(() => _selectedSkillFilter = val),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedTypeFilter,
                items: const ['ทุกประเภท', 'CHOICE', 'FILL_IN_BLANK'],
                onChanged: (val) => setState(() => _selectedTypeFilter = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedStatusFilter,
                items: const ['ทุกสถานะ', 'Active', 'Inactive'],
                onChanged: (val) => setState(() => _selectedStatusFilter = val),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _showAddExerciseDialog(),
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

  // ตารางข้อมูลแบบ Desktop
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
            constraints: const BoxConstraints(minWidth: 900),
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
                DataColumn(label: Text('คำอธิบายโจทย์')),
                DataColumn(label: Text('Skill')),
                DataColumn(label: Text('Level')),
                DataColumn(label: Text('ประเภท')),
                DataColumn(label: Text('Actions')),
                DataColumn(label: Text('สถานะ')),
              ],
              rows: _filteredExercises.map((exercise) {
                return DataRow(
                  cells: [
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Text(
                          exercise.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        exercise.skill,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        exercise.level.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          exercise.type,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.visibility_outlined,
                            label: 'ดู',
                            onTap: () {
                              _showExerciseDetailDialog(exercise);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: 'แก้ไข',
                            onTap: () {
                              _showAddExerciseDialog(exercise);
                            },
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: exercise.isActive,
                            activeColor: const Color(0xFF10B981),
                            onChanged: (val) {
                              setState(() {
                                exercise.isActive = val;
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exercise.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: exercise.isActive
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

  // การ์ดข้อมูลแบบ Mobile
  Widget _buildMobileListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredExercises.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
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
                    child: Text(
                      exercise.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Switch(
                    value: exercise.isActive,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() => exercise.isActive = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      exercise.skill,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      exercise.type,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lv.${exercise.level}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 20, color: Color(0xFF2563EB)),
                    onPressed: () => _showAddExerciseDialog(exercise),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
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

  void _showExerciseDetailDialog(ExerciseItemData exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('รายละเอียด Exercise',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exercise.description),
              const SizedBox(height: 10),
              Text('Skill: ${exercise.skill}'),
              const SizedBox(height: 6),
              Text('Level: ${exercise.level}'),
              const SizedBox(height: 6),
              Text('ประเภท: ${exercise.type}'),
              if (exercise.type == 'FILL_IN_BLANK') ...[
                const SizedBox(height: 6),
                Text('คำตอบที่ถูกต้อง: ${exercise.correctAnswer}'),
              ],
              const SizedBox(height: 6),
              Text('สถานะ: ${exercise.isActive ? "Active" : "Inactive"}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Edit / Add dialog — matches the "แก้ไข Exercise" design
// ============================================================
class _ExerciseEditDialog extends StatefulWidget {
  final ExerciseItemData? existingExercise;

  const _ExerciseEditDialog({this.existingExercise});

  @override
  State<_ExerciseEditDialog> createState() => _ExerciseEditDialogState();
}

class _ExerciseEditDialogState extends State<_ExerciseEditDialog> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _codeController;
  late final TextEditingController _levelController;
  late final TextEditingController _expectedTimeController;
  late final TextEditingController _correctAnswerController;

  String _selectedLanguage = 'Python';
  String _selectedSkill = 'stack';
  String _selectedTimeUnit = 'นาที (minute)';
  String _selectedType = 'FILL_IN_BLANK';
  String _selectedStatus = 'active';
  bool _caseSensitive = false;

  static const List<String> _languages = ['Python', 'JavaScript', 'Java', 'C++', 'Dart'];
  static const List<String> _skills = ['stack', 'queue', 'tree'];
  static const List<String> _timeUnits = ['วินาที (second)', 'นาที (minute)', 'ชั่วโมง (hour)'];
  static const Map<String, String> _typeLabels = {
    'CHOICE': 'CHOICE (ตัวเลือก)',
    'FILL_IN_BLANK': 'FILL_IN_BLANK (เติมคำ)',
  };
  static const Map<String, String> _statusLabels = {
    'active': 'active',
    'inactive': 'inactive',
  };

  @override
  void initState() {
    super.initState();
    final e = widget.existingExercise;
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _codeController = TextEditingController(text: e?.codeSnippet ?? '');
    _levelController = TextEditingController(text: (e?.level ?? 1).toString());
    _expectedTimeController =
        TextEditingController(text: (e?.expectedTime ?? 3).toString());
    _correctAnswerController = TextEditingController(text: e?.correctAnswer ?? '');

    _selectedLanguage = e?.language ?? 'Python';
    _selectedSkill = e?.skill ?? 'stack';
    _selectedTimeUnit = e?.timeUnit ?? 'นาที (minute)';
    _selectedType = e?.type ?? 'FILL_IN_BLANK';
    _selectedStatus = (e?.isActive ?? true) ? 'active' : 'inactive';
    _caseSensitive = e?.caseSensitive ?? false;

    // อัปเดตพรีวิวโค้ดทุกครั้งที่พิมพ์
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _codeController.dispose();
    _levelController.dispose();
    _expectedTimeController.dispose();
    _correctAnswerController.dispose();
    super.dispose();
  }

  // แทรก "____" ที่ตำแหน่งเคอร์เซอร์ในช่องโค้ด
  void _insertBlank() {
    final text = _codeController.text;
    final selection = _codeController.selection;
    final insertPos =
        selection.start >= 0 && selection.start <= text.length ? selection.start : text.length;
    final newText = text.replaceRange(insertPos, insertPos, '____');
    _codeController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: insertPos + 4),
    );
  }

  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: _codeController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('คัดลอกโค้ดแล้ว'), duration: Duration(seconds: 1)),
    );
  }

  void _save() {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกคำอธิบายโจทย์')),
      );
      return;
    }

    final result = ExerciseItemData(
      id: widget.existingExercise?.id ?? DateTime.now().millisecondsSinceEpoch,
      description: _descriptionController.text.trim(),
      codeSnippet: _codeController.text,
      language: _selectedLanguage,
      level: int.tryParse(_levelController.text.trim()) ?? 1,
      skill: _selectedSkill,
      expectedTime: int.tryParse(_expectedTimeController.text.trim()) ?? 3,
      timeUnit: _selectedTimeUnit,
      type: _selectedType,
      correctAnswer: _correctAnswerController.text.trim(),
      caseSensitive: _caseSensitive,
      choices: widget.existingExercise?.choices ?? [],
      correctChoiceIndex: widget.existingExercise?.correctChoiceIndex ?? 0,
      isActive: _selectedStatus == 'active',
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existingExercise != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_rounded : Icons.add_rounded,
                    color: const Color(0xFF1D4ED8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'แก้ไข Exercise' : 'เพิ่ม Exercise ใหม่',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // คำอธิบายโจทย์
                    _fieldLabel('คำอธิบายโจทย์ (DESCRIPTION)'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: _inputDecoration(hint: 'พิมพ์คำอธิบายโจทย์...'),
                    ),
                    const SizedBox(height: 20),

                    // โค้ดประกอบโจทย์ + ปุ่มแทรกช่องว่าง
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _fieldLabel('โค้ดประกอบโจทย์ (ไม่บังคับ)'),
                        ElevatedButton.icon(
                          onPressed: _insertBlank,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text(
                            'แทรกช่องว่าง',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: TextField(
                        controller: _codeController,
                        maxLines: 6,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                          hintText: 'data = [1, 2, 3, 4]\nval = data.pop()\nprint(val)',
                          hintStyle: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'พิมพ์ ____ (ขีดล่างอย่างน้อย 3 ตัว) ตรงจุดที่ต้องการให้ผู้เรียนเติมคำตอบ '
                      'หรือกดปุ่ม "แทรกช่องว่าง" ด้านบนแทนการพิมพ์เอง',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 20),

                    // ตัวอย่างที่ผู้เรียนจะเห็น
                    _fieldLabel('ตัวอย่างที่ผู้เรียนจะเห็น'),
                    const SizedBox(height: 8),
                    _buildCodePreview(),
                    const SizedBox(height: 20),

                    // ภาษาของโค้ด
                    _fieldLabel('ภาษาของโค้ด'),
                    const SizedBox(height: 6),
                    _buildDropdownField<String>(
                      value: _selectedLanguage,
                      items: _languages,
                      onChanged: (val) => setState(() => _selectedLanguage = val),
                    ),
                    const SizedBox(height: 20),

                    // LEVEL / SKILL
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('LEVEL'),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _levelController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('SKILL'),
                              const SizedBox(height: 6),
                              _buildDropdownField<String>(
                                value: _selectedSkill,
                                items: _skills,
                                onChanged: (val) => setState(() => _selectedSkill = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // เวลาที่คาดหวัง / หน่วย
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('เวลาที่คาดหวัง (EXPECTED TIME)'),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _expectedTimeController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('หน่วย (UNIT)'),
                              const SizedBox(height: 6),
                              _buildDropdownField<String>(
                                value: _selectedTimeUnit,
                                items: _timeUnits,
                                onChanged: (val) =>
                                    setState(() => _selectedTimeUnit = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ประเภทโจทย์ / สถานะ
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('ประเภทโจทย์ (TYPE)'),
                              const SizedBox(height: 6),
                              _buildDropdownField<String>(
                                value: _selectedType,
                                items: _typeLabels.keys.toList(),
                                displayLabel: (v) => _typeLabels[v] ?? v,
                                onChanged: (val) => setState(() => _selectedType = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('สถานะ'),
                              const SizedBox(height: 6),
                              _buildDropdownField<String>(
                                value: _selectedStatus,
                                items: _statusLabels.keys.toList(),
                                displayLabel: (v) => _statusLabels[v] ?? v,
                                onChanged: (val) => setState(() => _selectedStatus = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ฟิลด์เฉพาะสำหรับ FILL_IN_BLANK
                    if (_selectedType == 'FILL_IN_BLANK') ...[
                      const SizedBox(height: 20),
                      _fieldLabel('คำตอบที่ถูกต้อง (FILL IN BLANK)'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _correctAnswerController,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                        decoration: _inputDecoration(hint: 'เช่น pop(0)'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _caseSensitive,
                              activeColor: const Color(0xFF2563EB),
                              onChanged: (val) =>
                                  setState(() => _caseSensitive = val ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ตรวจตัวพิมพ์เล็ก/ใหญ่ (Case sensitive)',
                            style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'ยกเลิก',
                      style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('บันทึก', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T> onChanged,
    String Function(T)? displayLabel,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      displayLabel != null ? displayLabel(item) : item.toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  // การ์ดพรีวิวโค้ดสไตล์ตัวแก้ไขโค้ด พร้อมไฮไลต์คำสั่งพื้นฐาน และไฮไลต์ช่องว่าง ____
  Widget _buildCodePreview() {
    final code = _codeController.text.isEmpty
        ? '# ยังไม่มีโค้ดประกอบโจทย์'
        : _codeController.text;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Row(
              children: [
                Text(
                  _selectedLanguage.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _copyCodeToClipboard,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 12, color: Color(0xFFCBD5E1)),
                        SizedBox(width: 4),
                        Text(
                          'คัดลอก',
                          style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SelectableText.rich(
              _highlightCode(code),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ไฮไลต์โค้ดแบบง่าย: คอมเมนต์ (สีเทา), ฟังก์ชันในตัว (สีทอง), ตัวเลข (สีฟ้าอ่อน),
  // และช่องว่าง ____ (กล่องไฮไลต์สีเหลือง)
  TextSpan _highlightCode(String code) {
    const baseStyle = TextStyle(color: Color(0xFFE2E8F0));
    const commentStyle = TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic);
    const functionStyle = TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.w600);
    const numberStyle = TextStyle(color: Color(0xFF7DD3FC));
    const blankStyle = TextStyle(
      color: Color(0xFF0F172A),
      backgroundColor: Color(0xFFFDE68A),
      fontWeight: FontWeight.w700,
    );

    final blankPattern = RegExp(r'_{3,}');
    final functionPattern = RegExp(r'\b(print|pop|push|append|len|range|enqueue|dequeue)\b');
    final numberPattern = RegExp(r'\b\d+\b');

    final List<TextSpan> spans = [];
    for (final line in code.split('\n')) {
      if (line.trim().startsWith('#')) {
        spans.add(TextSpan(text: '$line\n', style: commentStyle));
        continue;
      }

      int cursor = 0;
      // รวมตำแหน่ง match ทั้งหมดของ blank / function / number แล้วเรียงตามตำแหน่ง
      final matches = <_Match>[
        ...blankPattern.allMatches(line).map((m) => _Match(m.start, m.end, blankStyle)),
        ...functionPattern.allMatches(line).map((m) => _Match(m.start, m.end, functionStyle)),
        ...numberPattern.allMatches(line).map((m) => _Match(m.start, m.end, numberStyle)),
      ]..sort((a, b) => a.start.compareTo(b.start));

      for (final m in matches) {
        if (m.start < cursor) continue; // ข้าม overlap
        if (m.start > cursor) {
          spans.add(TextSpan(text: line.substring(cursor, m.start), style: baseStyle));
        }
        spans.add(TextSpan(text: line.substring(m.start, m.end), style: m.style));
        cursor = m.end;
      }
      if (cursor < line.length) {
        spans.add(TextSpan(text: line.substring(cursor), style: baseStyle));
      }
      spans.add(const TextSpan(text: '\n'));
    }

    return TextSpan(children: spans);
  }
}

class _Match {
  final int start;
  final int end;
  final TextStyle style;
  _Match(this.start, this.end, this.style);
}