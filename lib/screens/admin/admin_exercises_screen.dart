import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:halalsefllearning/api/app_api.dart';

class ExerciseItemData {
  int id;
  String script;
  int skillId;
  int sessionId;
  bool isActive;
  List<ChoiceItemData> choices;

  ExerciseItemData({
    required this.id,
    required this.script,
    required this.skillId,
    required this.sessionId,
    required this.isActive,
    required this.choices,
  });
}

class ChoiceItemData {
  int? id;
  String script;
  bool isAnswer;

  ChoiceItemData({
    this.id,
    required this.script,
    required this.isAnswer,
  });
}

class AdminExercisesScreen extends StatefulWidget {
  const AdminExercisesScreen({super.key});

  @override
  State<AdminExercisesScreen> createState() => _AdminExercisesScreenState();
}

class _AdminExercisesScreenState extends State<AdminExercisesScreen> {
  List<ExerciseItemData> _exercises = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final response = await AppApi.get('exercise/1');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] != null && json['data'] is List) {
          final List list = json['data'];
          setState(() {
            _exercises = list.map((item) {
              final choicesList = (item['choices'] as List? ?? []).map((ch) {
                return ChoiceItemData(
                  id: ch['choice_id'],
                  script: ch['choice_script'] ?? '',
                  isAnswer: ch['isAnswer'] == 1 || ch['isAnswer'] == true,
                );
              }).toList();

              return ExerciseItemData(
                id: item['exercise_id'] ?? 0,
                script: item['exercise_script'] ?? '',
                skillId: item['skill_id'] ?? 1,
                sessionId: 1,
                isActive: item['is_active'] != 0,
                choices: choicesList,
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

    if (_exercises.isEmpty) {
      setState(() {
        _exercises = [
          ExerciseItemData(
            id: 1,
            script: 'ข้อใดคือโครงสร้างข้อมูลแบบเลือกทำในภาษา Dart?',
            skillId: 1,
            sessionId: 1,
            isActive: true,
            choices: [
              ChoiceItemData(id: 1, script: 'if / else', isAnswer: true),
              ChoiceItemData(id: 2, script: 'for loop', isAnswer: false),
            ],
          ),
        ];
        _isLoading = false;
      });
    }
  }

  void _showAddEditExerciseDialog([ExerciseItemData? existing]) {
    final scriptController = TextEditingController(text: existing?.script ?? '');
    int selectedSkillId = existing?.skillId ?? 1;
    bool isActive = existing?.isActive ?? true;
    List<ChoiceItemData> dialogChoices = existing != null
        ? existing.choices.map((c) => ChoiceItemData(id: c.id, script: c.script, isAnswer: c.isAnswer)).toList()
        : [
            ChoiceItemData(script: 'ตัวเลือก 1', isAnswer: true),
            ChoiceItemData(script: 'ตัวเลือก 2', isAnswer: false),
          ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.assignment_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 10),
              Text(existing == null ? 'เพิ่ม Exercise (ข้อสอบ)' : 'แก้ไข Exercise'),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('โจทย์ / คำถาม (Exercise Script)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: scriptController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'ระบุโจทย์คำถาม...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('ผูกกับ Skill (Skill ID): ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                        value: selectedSkillId,
                        items: [1, 2, 3, 4].map((id) => DropdownMenuItem(value: id, child: Text('Skill #$id'))).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedSkillId = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('ตัวเลือกตอบ (Choices)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...dialogChoices.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final ch = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: ch.isAnswer,
                            onChanged: (val) {
                              setDialogState(() {
                                for (var c in dialogChoices) {
                                  c.isAnswer = false;
                                }
                                ch.isAnswer = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: ch.script),
                              onChanged: (val) => ch.script = val,
                              decoration: InputDecoration(
                                hintText: 'ตัวเลือกที่ ${idx + 1}',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
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
                if (scriptController.text.trim().isEmpty) return;

                final body = {
                  'session_id': 1,
                  'skill_id': selectedSkillId,
                  'exercise_script': scriptController.text.trim(),
                  'choices': dialogChoices.map((c) => {
                    if (c.id != null) 'choice_id': c.id,
                    'choice_script': c.script,
                    'isAnswer': c.isAnswer ? 1 : 0,
                  }).toList(),
                };

                try {
                  if (existing == null) {
                    await AppApi.post('admin/exercise', body);
                  } else {
                    await AppApi.put('admin/exercise/${existing.id}', body);
                  }
                } catch (e) {
                  debugPrint('Error saving exercise: $e');
                }

                if (mounted) Navigator.pop(context);
                _loadExercises();
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
                  child: const Icon(Icons.assignment_rounded, color: Color(0xFF2563EB), size: 26),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('จัดการ Exercise (ข้อสอบ)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('ข้อสอบทั้งหมด ${_exercises.length} รายการ', style: const TextStyle(color: Color(0xFF64748B))),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                  onPressed: () => _showAddEditExerciseDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('เพิ่ม Exercise ใหม่'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final item = _exercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(item.script, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Skill ID: ${item.skillId} | Choices: ${item.choices.length} ตัวเลือก'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: item.isActive,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (val) async {
                                  setState(() => item.isActive = val);
                                  try {
                                    await AppApi.patch('admin/exercise/${item.id}/status', {'is_active': val ? 1 : 0});
                                  } catch (e) {
                                    debugPrint('Error updating status: $e');
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
                                onPressed: () => _showAddEditExerciseDialog(item),
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
