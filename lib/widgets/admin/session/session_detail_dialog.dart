import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/admin/session_history_data.dart';
import 'package:halalsefllearning/models/admin/session_item_data.dart';

/// Dialog แสดงรายละเอียด Session แบ่งเป็นแท็บ รายละเอียด / ประวัติการทำ
class SessionDetailDialog extends StatelessWidget {
  final SessionItemData session;

  const SessionDetailDialog({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(session.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        content: SizedBox(
          width: 520,
          height: 460,
          child: Column(
            children: [
              const TabBar(
                labelColor: Color(0xFF0F766E),
                unselectedLabelColor: Color(0xFF64748B),
                indicatorColor: Color(0xFF0F766E),
                tabs: [
                  Tab(text: 'รายละเอียด'),
                  Tab(text: 'ประวัติการทำ'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _SessionInfoTab(session: session),
                    SessionHistoryTab(sessionId: session.id),
                  ],
                ),
              ),
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

class _SessionInfoTab extends StatelessWidget {
  final SessionItemData session;

  const _SessionInfoTab({required this.session});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skill: ${session.skillName}'),
          const SizedBox(height: 6),
          Text('Exercise: ${session.exerciseIds.length} รายการ'),
          for (final name in session.exerciseNames)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text('• $name'),
            ),
        ],
      ),
    );
  }
}

/// แท็บประวัติ: จำนวนครั้งที่ผู้ใช้ทำ session นี้ + log แต่ละรอบพร้อมจำนวนข้อถูก/ผิด
class SessionHistoryTab extends StatefulWidget {
  final int sessionId;

  const SessionHistoryTab({super.key, required this.sessionId});

  @override
  State<SessionHistoryTab> createState() => _SessionHistoryTabState();
}

class _SessionHistoryTabState extends State<SessionHistoryTab>
    with AutomaticKeepAliveClientMixin {
  SessionHistoryData? _history;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = AppApi.unwrap(
        await AppApi.get('admin/session/${widget.sessionId}/history'),
      );
      if (!mounted) return;
      setState(() => _history = SessionHistoryData.fromJson(data));
    } catch (e) {
      if (mounted) setState(() => _error = 'โหลดประวัติไม่สำเร็จ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFDC2626))));
    }
    final history = _history;
    if (history == null) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'ทำไปแล้วทั้งหมด',
                value: '${history.attemptCount} ครั้ง',
                icon: Icons.replay_rounded,
                color: const Color(0xFF0F766E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: 'จำนวนผู้ใช้',
                value: '${history.userCount} คน',
                icon: Icons.people_outline,
                color: const Color(0xFF1D4ED8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Log การทำ Session',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: history.logs.isEmpty
              ? const Center(
                  child: Text('ยังไม่มีผู้ใช้ทำ Session นี้', style: TextStyle(color: Color(0xFF64748B))),
                )
              : ListView.separated(
                  itemCount: history.logs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _AttemptLogTile(log: history.logs[index]),
                ),
        ),
      ],
    );
  }
}

class _AttemptLogTile extends StatelessWidget {
  final SessionAttemptLog log;

  const _AttemptLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final name = log.fullName.isEmpty ? log.username : '${log.username} (${log.fullName})';
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person_outline),
      title: Text(name),
      subtitle: Text('ครั้งที่ ${log.attemptNo} • ${log.createDate}'),
      trailing: log.correctCount == null
          ? const Text('ไม่มีคะแนน', style: TextStyle(color: Color(0xFF64748B)))
          : Wrap(
              spacing: 6,
              children: [
                _CountChip(
                  text: 'ถูก ${log.correctCount}',
                  color: const Color(0xFF16A34A),
                ),
                _CountChip(
                  text: 'ผิด ${log.incorrectCount}',
                  color: const Color(0xFFDC2626),
                ),
              ],
            ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String text;
  final Color color;

  const _CountChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 12)),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
