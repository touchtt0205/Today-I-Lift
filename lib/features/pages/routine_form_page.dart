import 'package:flutter/material.dart';
import 'package:today_i_lift/features/services/routine_service.dart';
import 'package:today_i_lift/shared/constants/routine_appearance.dart';
import 'package:today_i_lift/shared/widgets/exercise_picker_modal.dart';
import 'package:today_i_lift/shared/widgets/gradient_app_bar.dart';
import 'package:today_i_lift/shared/widgets/routine_appearance_section.dart';
import 'package:today_i_lift/shared/widgets/routine_exercise_card.dart';
import 'package:today_i_lift/shared/widgets/routine_quick_templates.dart';

class RoutineFormPage extends StatefulWidget {
  final Map<String, dynamic>? routine;

  const RoutineFormPage({super.key, this.routine});

  @override
  State<RoutineFormPage> createState() => _RoutineFormPageState();
}

class _RoutineFormPageState extends State<RoutineFormPage> {
  final _service = RoutineService();
  final _nameCtrl = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  bool _loading = false;
  int _selectedColorIndex = 0;
  int _selectedIconIndex = 0;

  bool get _isEdit => widget.routine != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameCtrl.text = widget.routine!['name'];

      final colorIndex = RoutineAppearance.colors.indexOf(
        RoutineAppearance.getColor(
          widget.routine!['color'],
          widget.routine!['name'],
        ),
      );
      final iconIndex = RoutineAppearance.icons.indexOf(
        RoutineAppearance.getIcon(
          widget.routine!['icon'],
          widget.routine!['name'],
        ),
      );
      if (colorIndex != -1) _selectedColorIndex = colorIndex;
      if (iconIndex != -1) _selectedIconIndex = iconIndex;

      _loadItems();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await _service.getItems(widget.routine!['id']);
    setState(() => _items = items);
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
        'sets': <Map<String, dynamic>>[
          {'weight': 60, 'reps': 10},
          {'weight': 60, 'reps': 10},
          {'weight': 60, 'reps': 10},
        ],
        'order_index': _items.length,
      });
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final sets = _items[exerciseIndex]['sets'] as List<Map<String, dynamic>>;

      final last = sets.isNotEmpty ? sets.last : {'weight': 60, 'reps': 10};

      sets.add({'weight': last['weight'], 'reps': last['reps']});
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      (_items[exerciseIndex]['sets'] as List).removeAt(setIndex);
    });
  }

  void _removeExercise(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _applyTemplate(String type) async {
    final exercises = await _service.getTemplateExercises(type);
    setState(() {
      _items = exercises
          .asMap()
          .entries
          .map(
            (e) => {
              'exercise_id': e.value['id'],
              'exercises': e.value,
              'sets': [
                {'reps': 10, 'weight': 60},
                {'reps': 10, 'weight': 60},
                {'reps': 10, 'weight': 60},
              ],
              'order_index': e.key,
            },
          )
          .toList();
      if (_nameCtrl.text.isEmpty) {
        _nameCtrl.text = switch (type) {
          'push' => 'Push Day',
          'pull' => 'Pull Day',
          'legs' => 'Legs Day',
          _ => '',
        };
      }
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await _service.saveRoutine(
        name: _nameCtrl.text.trim(),
        icon: RoutineAppearance.icons[_selectedIconIndex].codePoint,
        color: RoutineAppearance.colors[_selectedColorIndex].toARGB32(),
        items: _items,
        routineId: _isEdit ? widget.routine!['id'] : null,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('1', 'Name Your Routine'),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'e.g. Push Day, Upper Body, Leg Day...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('2', 'Appearance (Preview)'),
            const SizedBox(height: 12),
            RoutineAppearanceSection(
              routineName: _nameCtrl.text,
              exerciseCount: _items.length,
              colors: RoutineAppearance.colors,
              icons: RoutineAppearance.icons,
              selectedColorIndex: _selectedColorIndex,
              selectedIconIndex: _selectedIconIndex,
              onColorChanged: (i) => setState(() => _selectedColorIndex = i),
              onIconChanged: (i) => setState(() => _selectedIconIndex = i),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              '3',
              'Selected Exercises (${_items.length})',
              trailing: TextButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF8551),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_items.isEmpty)
              _buildEmptyExercises()
            else
              ..._items.asMap().entries.map(
                (e) => RoutineExerciseCard(
                  key: ValueKey('exercise_${e.key}'),
                  index: e.key,
                  item: e.value,
                  onRemove: () => _removeExercise(e.key),
                  onAddSet: _addSet,
                  onRemoveSet: _removeSet,
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Quick Templates',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            RoutineQuickTemplates(onApply: _applyTemplate),
            const SizedBox(height: 24),
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
                      colors: [Color(0xFFFF8551), Color(0xFFEF4444)],
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFFF8551),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildEmptyExercises() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No exercises selected yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
