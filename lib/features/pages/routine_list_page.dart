import 'package:flutter/material.dart';
import 'package:today_i_lift/shared/widgets/gradient_app_bar.dart';
import 'package:today_i_lift/shared/widgets/routine_card.dart';
import '../repositories/routine_repository.dart';
import '../repositories/routine_item_repository.dart';
import 'routine_form_page.dart';

class RoutineListPage extends StatefulWidget {
  const RoutineListPage({super.key});

  @override
  State<RoutineListPage> createState() => _RoutineListPageState();
}

class _RoutineListPageState extends State<RoutineListPage> {
  final _repo = RoutineRepository();
  final _itemRepo = RoutineItemRepository();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repo.getRoutines();
    });
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8551), Color(0xFFEF4444)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8551).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RoutineFormPage()),
              );
              _refresh();
            },
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Create New Routine',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(String routineId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Routine?'),
        content: const Text('Are you sure you want to delete this routine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repo.deleteRoutine(routineId);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: 'My Routine',
        subtitle: 'Design your custom workout routine',
        showDate: false,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final routines = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: routines.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) return _buildAddButton();

              final routine = routines[i - 1];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder(
                  future: _itemRepo.getItems(routine['id']),
                  builder: (context, itemSnapshot) {
                    final exerciseCount = itemSnapshot.hasData
                        ? (itemSnapshot.data as List).length
                        : 0;

                    return RoutineCard(
                      routine: routine,
                      exerciseCount: exerciseCount,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoutineFormPage(routine: routine),
                          ),
                        );
                        _refresh();
                      },
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoutineFormPage(routine: routine),
                          ),
                        );
                        _refresh();
                      },
                      onDelete: () => _confirmAndDelete(routine['id']),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
