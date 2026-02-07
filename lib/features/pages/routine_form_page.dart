import 'package:flutter/material.dart';
import 'package:today_i_lift/shared/widgets/gradient_app_bar.dart';
import '../repositories/routine_repository.dart';
import '../repositories/routine_item_repository.dart';
import 'package:today_i_lift/shared/widgets/exercise_picker_modal.dart';

class RoutineFormPage extends StatefulWidget {
  final Map<String, dynamic>? routine;

  const RoutineFormPage({super.key, this.routine});

  @override
  State<RoutineFormPage> createState() => _RoutineFormPageState();
}

class _RoutineFormPageState extends State<RoutineFormPage> {
  final _routineRepo = RoutineRepository();
  final _itemRepo = RoutineItemRepository();

  final _nameCtrl = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  bool _loading = false;

  bool get _isEdit => widget.routine != null;

  @override
  void initState() {
    super.initState();

    if (_isEdit) {
      _nameCtrl.text = widget.routine!['name'];
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    final res = await _itemRepo.getItems(widget.routine!['id']);
    setState(() => _items = res);
  }

  Future<void> _addExercise() async {
    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ExercisePickerModal(),
    );

    if (picked == null) return;

    setState(() {
      _items.add({
        'exercise_id': picked['id'],
        'exercises': picked,
        'sets': 3,
        'reps': 10,
        'weight': 0,
        'order_index': _items.length,
      });
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    setState(() => _loading = true);

    String routineId;

    if (_isEdit) {
      routineId = widget.routine!['id'];
    } else {
      routineId = await _routineRepo.createRoutineReturnId(
        _nameCtrl.text.trim(),
      );
    }

    final items = _items
        .asMap()
        .entries
        .map(
          (e) => {
            'routine_id': routineId,
            'exercise_id': e.value['exercise_id'],
            'sets': e.value['sets'],
            'reps': e.value['reps'],
            'weight': e.value['weight'],
            'order_index': e.key,
          },
        )
        .toList();

    await _itemRepo.replaceItems(routineId, items);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: _isEdit ? 'Edit Routine' : 'Create Routine',
        subtitle: 'Design your custom workout routine',
        showDate: false,
        showCloseButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Routine name'),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Exercise'),
                onTap: _addExercise,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];

                  return Card(
                    child: ListTile(
                      title: Text(item['exercises']['name']),
                      subtitle: Row(
                        children: [
                          _numberField(item, 'sets', 'Sets'),
                          _numberField(item, 'reps', 'Reps'),
                          _numberField(item, 'weight', 'Kg'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() => _items.removeAt(i));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: InkWell(
                onTap: _loading ? null : _save,
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF8551), // ส้ม
                        Color(0xFFEF4444), // แดง
                      ],
                    ),
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Your Routine',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(Map<String, dynamic> item, String key, String label) {
    return SizedBox(
      width: 70,
      child: TextFormField(
        initialValue: item[key].toString(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        onChanged: (v) => item[key] = num.tryParse(v) ?? 0,
      ),
    );
  }
}
