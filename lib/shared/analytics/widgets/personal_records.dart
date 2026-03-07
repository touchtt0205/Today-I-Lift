import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today_i_lift/features/services/analytics_service.dart';

class PersonalRecords extends StatefulWidget {
  const PersonalRecords({super.key});

  @override
  State<PersonalRecords> createState() => _PersonalRecordsState();
}

class _PersonalRecordsState extends State<PersonalRecords> {
  final _service = AnalyticsService();

  List<Map<String, dynamic>> _records = [];
  bool _loading = true;
  final Set<String> _expandedGroups = {};

  static const _groupColors = {
    'Chest': Color(0xFFFF7043),
    'Back': Color(0xFF42A5F5),
    'Legs': Color(0xFF66BB6A),
    'Shoulders': Color(0xFFAB47BC),
    'Arms': Color(0xFFFFCA28),
    'Core': Color(0xFF26C6DA),
  };

  static const _groupOrder = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.getPersonalRecords();
    if (!mounted) return;
    setState(() {
      _records = data;
      _loading = false;
    });
  }

  // จัดกลุ่มตาม muscle group
  Map<String, List<Map<String, dynamic>>> get _groupedRecords {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final pr in _records) {
      final group = pr['muscle_group'] as String? ?? 'Other';
      grouped.putIfAbsent(group, () => []).add(pr);
    }
    return grouped;
  }

  // เรียง groups ตาม _groupOrder
  List<String> get _sortedGroups {
    final grouped = _groupedRecords;
    final ordered = _groupOrder.where((g) => grouped.containsKey(g)).toList();
    final others = grouped.keys.where((g) => !_groupOrder.contains(g)).toList();
    return [...ordered, ...others];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Records 🏆',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _records.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No records yet',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                )
              : Column(
                  children: _sortedGroups
                      .map((g) => _buildGroupSection(g, _groupedRecords[g]!))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildGroupSection(String group, List<Map<String, dynamic>> records) {
    final isExpanded = _expandedGroups.contains(group);
    final color = _groupColors[group] ?? const Color(0xFF9E9E9E);

    // PR สูงสุดของกลุ่ม
    final topPR = records.first;
    final topWeight = topPR['weight'];
    final topName = topPR['name'] ?? '-';

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() {
            if (isExpanded) {
              _expandedGroups.remove(group);
            } else {
              _expandedGroups.add(group);
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // group name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$topWeight kg — $topName',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                // badge จำนวนท่า
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${records.length} exercises',
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expanded list
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 16, bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: color.withOpacity(0.3), width: 2),
              ),
            ),
            child: Column(
              children: records.map((pr) => _buildPRItem(pr, color)).toList(),
            ),
          ),

        Divider(color: Colors.grey[100], height: 1),
      ],
    );
  }

  Widget _buildPRItem(Map<String, dynamic> pr, Color color) {
    final date = pr['date'] != null
        ? DateFormat('d MMM yyyy').format(DateTime.parse(pr['date']).toLocal())
        : '-';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              pr['name'] ?? '-',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${pr['weight']} kg × ${pr['reps']} reps',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: color,
                ),
              ),
              Text(
                date,
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
