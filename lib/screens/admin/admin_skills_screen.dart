import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:halalsefllearning/api/app_api.dart';

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
      final response = await AppApi.get('admin/skill');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] != null && json['data'] is List) {
          final List list = json['data'];
          setState(() {
            _skills = list.map((item) {
              final id = item['skill_id'] ?? 0;
              final name = item['skill_name'] ?? '';
              final code = item['skill_code'] ?? _generateSkillCode(name);
              final isActive = (item['is_active'] == 1 || item['is_active'] == true || item['is_active'] == '1');
              return SkillItemData(
                id: id,
                code: code,
                name: name,
                tier: 'Basic',
                prerequisite: '—',
                isActive: isActive,
              );
            }).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading skills: $e');
    }

    // ข้อมูลเริ่มต้นสำหรับแสดงผลให้เหมือนในภาพตัวอย่างหากยังไม่มีใน DB
    if (_skills.isEmpty) {
      setState(() {
        _skills = [
          SkillItemData(
            id: 1,
            code: 'ARRAYS & LINKED LISTS',
            name: 'Arrays & Linked Lists',
            tier: 'Basic',
            prerequisite: 'Inheritance & Polymorphism',
            isActive: true,
          ),
          SkillItemData(
            id: 2,
            code: 'CLASSES & OBJECTS',
            name: 'Classes & Objects',
            tier: 'Basic',
            prerequisite: '—',
            isActive: true,
          ),
          SkillItemData(
            id: 3,
            code: 'Control Flow',
            name: 'Control Flow',
            tier: 'Basic',
            prerequisite: '—',
            isActive: true,
          ),
          SkillItemData(
            id: 4,
            code: 'DATABASE DESIGN',
            name: 'Database Design',
            tier: 'Basic',
            prerequisite: '—',
            isActive: true,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  String _generateSkillCode(String name) {
    if (name.isEmpty) return 'SKILL';
    return name.toUpperCase();
  }

  List<SkillItemData> get _filteredSkills {
    return _skills.where((skill) {
      final matchesSearch = skill.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          skill.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          skill.tier.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatusFilter == 'ทุกสถานะ' ||
          (_selectedStatusFilter == 'Active' && skill.isActive) ||
          (_selectedStatusFilter == 'Inactive' && !skill.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showAddSkillDialog([SkillItemData? existingSkill]) {
    final codeController =
        TextEditingController(text: existingSkill?.code ?? '');
    final nameController =
        TextEditingController(text: existingSkill?.name ?? '');
    String selectedTier = existingSkill?.tier ?? 'Basic';
    String prerequisite = existingSkill?.prerequisite ?? '—';
    bool isActive = existingSkill?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.folder_rounded,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                existingSkill == null ? 'เพิ่ม Skill ใหม่' : 'แก้ไข Skill',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skill Code (รหัส)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: 'เช่น ARRAYS & LINKED LISTS',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Skill Name (ชื่อ Skill)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'เช่น Arrays & Linked Lists',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tier (ระดับ)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedTier,
                                  isExpanded: true,
                                  items: ['Basic', 'Intermediate', 'Advanced']
                                      .map((tier) => DropdownMenuItem(
                                            value: tier,
                                            child: Text(tier),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDialogState(() => selectedTier = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prerequisite',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: prerequisite,
                                  isExpanded: true,
                                  items: [
                                    '—',
                                    'Inheritance & Polymorphism',
                                    'Control Flow',
                                    'Database Design',
                                  ]
                                      .map((pre) => DropdownMenuItem(
                                            value: pre,
                                            child: Text(
                                              pre,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDialogState(() => prerequisite = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'สถานะเปิดใช้งาน (Active)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: isActive,
                        activeColor: const Color(0xFF10B981),
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
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () async {
                final nameText = nameController.text.trim();
                final codeText = codeController.text.trim();
                if (nameText.isEmpty) return;

                final body = {
                  'skill_code': codeText.isEmpty ? nameText.toUpperCase() : codeText,
                  'skill_name': nameText,
                  'is_active': isActive ? 1 : 0,
                };

                try {
                  if (existingSkill == null) {
                    await AppApi.post('admin/skill', body);
                  } else {
                    await AppApi.put('admin/skill/${existingSkill.id}', body);
                  }
                } catch (e) {
                  debugPrint('Error saving skill: $e');
                }

                if (mounted) Navigator.pop(context);
                _loadSkills();
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 860;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section: "🗂️ จัดการ Skill" + จำนวนรายการ
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder_rounded,
                    color: Color(0xFF2563EB),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'จัดการ Skill',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Skill ทั้งหมด ${_skills.length} รายการ',
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

            // Action Bar: Search Input + Status Filter + "+ เพิ่ม Skill ใหม่"
            isMobile ? _buildMobileActionBar() : _buildDesktopActionBar(),

            const SizedBox(height: 20),

            // Content Table or Mobile Cards
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
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
                hintText: 'ค้นหาชื่อ Skill, Tier...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
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

        // "+ เพิ่ม Skill ใหม่" Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _showAddSkillDialog(),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'เพิ่ม Skill ใหม่',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ],
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
              hintText: 'ค้นหาชื่อ Skill, Tier...',
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
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
                      if (val != null) setState(() => _selectedStatusFilter = val);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _showAddSkillDialog(),
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

  // ตารางข้อมูลแบบ Desktop (ตรงตามภาพตัวอย่าง)
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
                DataColumn(label: Text('Skill code')),
                DataColumn(label: Text('Skill')),
                DataColumn(label: Text('Tier')),
                DataColumn(label: Text('Prerequisite')),
                DataColumn(label: Text('Actions')),
                DataColumn(label: Text('สถานะ')),
              ],
              rows: _filteredSkills.map((skill) {
                return DataRow(
                  cells: [
                    // Skill Code
                    DataCell(
                      Text(
                        skill.code,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E3A8A),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Skill Name
                    DataCell(
                      Text(
                        skill.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    // Tier Badge
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          skill.tier,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ),
                    // Prerequisite
                    DataCell(
                      skill.prerequisite == '—'
                          ? const Text(
                              '—',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 16,
                              ),
                            )
                          : Container(
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
                                skill.prerequisite,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                    ),
                    // Actions: ดู / แก้ไข
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.visibility_outlined,
                            label: 'ดู',
                            onTap: () {
                              _showSkillDetailDialog(skill);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: 'แก้ไข',
                            onTap: () {
                              _showAddSkillDialog(skill);
                            },
                          ),
                        ],
                      ),
                    ),
                    // สถานะ Toggle Switch
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: skill.isActive,
                            activeColor: const Color(0xFF10B981),
                            onChanged: (val) async {
                              setState(() {
                                skill.isActive = val;
                              });
                              try {
                                await AppApi.patch('admin/skill/${skill.id}/status', {
                                  'is_active': val ? 1 : 0,
                                });
                              } catch (e) {
                                debugPrint('Error updating skill status: $e');
                              }
                            },
                          ),
                          const SizedBox(width: 4),
                          Text(
                            skill.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: skill.isActive
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

  // การ์ดข้อมูลแบบ Mobile (สไตล์ ListTile ตาม WS06 ของอาจารย์)
  Widget _buildMobileListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredSkills.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final skill = _filteredSkills[index];
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
                          skill.code,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          skill.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: skill.isActive,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() => skill.isActive = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Text(
                      skill.tier,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (skill.prerequisite != '—')
                    Expanded(
                      child: Text(
                        'Req: ${skill.prerequisite}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF2563EB)),
                    onPressed: () => _showAddSkillDialog(skill),
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

  void _showSkillDetailDialog(SkillItemData skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(skill.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skill Code: ${skill.code}'),
            const SizedBox(height: 6),
            Text('Tier: ${skill.tier}'),
            const SizedBox(height: 6),
            Text('Prerequisite: ${skill.prerequisite}'),
            const SizedBox(height: 6),
            Text('สถานะ: ${skill.isActive ? "Active" : "Inactive"}'),
          ],
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

class SkillItemData {
  int id;
  String code;
  String name;
  String tier;
  String prerequisite;
  bool isActive;

  SkillItemData({
    required this.id,
    required this.code,
    required this.name,
    required this.tier,
    required this.prerequisite,
    required this.isActive,
  });
}
