import 'package:flutter/material.dart';
import 'package:today_i_lift/features/pages/routine_form_page.dart';
import 'package:today_i_lift/features/repositories/routine_item_repository.dart';
import 'package:today_i_lift/shared/widgets/routine_card.dart';

class RoutineList extends StatelessWidget {
  final List<Map<String, dynamic>> routines;
  final Map<String, DateTime> lastPlayedPerRoutine;
  final VoidCallback onChanged;

  const RoutineList({
    super.key,
    required this.routines,
    required this.lastPlayedPerRoutine,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Routines',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          routines.isEmpty
              ? _buildEmpty()
              : Column(
                  children: routines.map((routine) {
                    return _RoutineCardWithCount(
                      routine: routine,
                      lastPlayed: lastPlayedPerRoutine[routine['id']],
                      onChanged: onChanged,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'No routines yet\nCreate your first routine!',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}

class _RoutineCardWithCount extends StatefulWidget {
  final Map<String, dynamic> routine;
  final DateTime? lastPlayed;
  final VoidCallback onChanged;

  const _RoutineCardWithCount({
    required this.routine,
    required this.lastPlayed,
    required this.onChanged,
  });

  @override
  State<_RoutineCardWithCount> createState() => _RoutineCardWithCountState();
}

class _RoutineCardWithCountState extends State<_RoutineCardWithCount> {
  final _itemRepo = RoutineItemRepository();
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _itemRepo.getItems(widget.routine['id']).then((items) {
      if (mounted) setState(() => _count = items.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RoutineCard(
      routine: widget.routine,
      exerciseCount: _count,
      lastPlayed: widget.lastPlayed,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoutineFormPage(routine: widget.routine),
          ),
        );
        widget.onChanged();
      },
    );
  }
}
