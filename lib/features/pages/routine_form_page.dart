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

  // Appearance settings
  int _selectedColorIndex = 0;
  int _selectedIconIndex = 0;

  final List<Color> _colors = const [
    Color(0xFFEF4444), // Red
    Color(0xFFFF8551), // Orange
    Color(0xFFFBBF24), // Yellow
    Color(0xFF22C55E), // Green
    Color(0xFF3B82F6), // Light Blue
    Color(0xFF2563EB), // Blue
    Color(0xFF9333EA), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF6B7280), // Gray
  ];

  final List<IconData> _icons = const [
    Icons.fitness_center,
    Icons.local_fire_department,
    Icons.sports_gymnastics,
    Icons.self_improvement,
    Icons.apps,
    Icons.flash_on,
    Icons.favorite,
    Icons.star,
  ];

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
    final convertedItems = res.map((item) {
      final setsCount = item['sets'] as int? ?? 3;
      final reps = item['reps'] as int? ?? 10;
      final weight = item['weight'] as num? ?? 0;

      return {
        ...item,
        'sets': List.generate(
          setsCount,
          (index) => {'reps': reps, 'weight': weight},
        ),
      };
    }).toList();

    setState(() => _items = convertedItems);
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
        'sets': [],
        'order_index': _items.length,
      });
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      if (_items[exerciseIndex]['sets'] is! List) {
        _items[exerciseIndex]['sets'] = [];
      }
      (_items[exerciseIndex]['sets'] as List).add({'reps': 12, 'weight': 60});
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      (_items[exerciseIndex]['sets'] as List).removeAt(setIndex);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _items.removeAt(index);
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
    final items = _items.asMap().entries.map((e) {
      final sets = e.value['sets'] as List? ?? [];
      return {
        'routine_id': routineId,
        'exercise_id': e.value['exercise_id'],
        'sets': sets.isNotEmpty ? sets.length : 3,
        'reps': sets.isNotEmpty ? sets.first['reps'] : 10,
        'weight': sets.isNotEmpty ? sets.first['weight'] : 0,
        'order_index': e.key,
      };
    }).toList();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('1', 'Name Your Routine'),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
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
            _buildAppearancePreview(),

            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Color :',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildColorPicker(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Icon :',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIconPicker(),
                    ],
                  ),
                ),
              ],
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
              ..._items.asMap().entries.map((entry) {
                return _buildExerciseCard(entry.key, entry.value);
              }),

            const SizedBox(height: 16),

            const Text(
              'Quick Templates',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTemplateButton(
                    '💪 Push',
                    const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTemplateButton(
                    '🔥 Pull',
                    const Color(0xFFFF8551),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTemplateButton(
                    '🦵 Leg',
                    const Color(0xFFFBBF24),
                  ),
                ),
              ],
            ),

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

  Widget _buildAppearancePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _colors[_selectedColorIndex],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _icons[_selectedIconIndex],
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameCtrl.text.isEmpty ? 'Routine Name' : _nameCtrl.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'exercises: ${_items.length}  •  Last workout',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _colors.asMap().entries.map((entry) {
        final isSelected = _selectedColorIndex == entry.key;
        return GestureDetector(
          onTap: () => setState(() => _selectedColorIndex = entry.key),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: entry.value,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: entry.value.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _icons.asMap().entries.map((entry) {
        final isSelected = _selectedIconIndex == entry.key;
        return GestureDetector(
          onTap: () => setState(() => _selectedIconIndex = entry.key),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF8551) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              entry.value,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyExercises() {
    return Container(
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

  Widget _buildExerciseCard(int index, Map<String, dynamic> item) {
    final sets = item['sets'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item['exercises']['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8551),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${sets.length} Sets',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _removeExercise(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          if (sets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Reps',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Kg',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Sets
                  ...sets.asMap().entries.map((setEntry) {
                    return _buildSetRow(index, setEntry.key, setEntry.value);
                  }),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _addSet(index),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Set'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF8551),
                  side: const BorderSide(color: Color(0xFFFF8551)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(
    int exerciseIndex,
    int setIndex,
    Map<String, dynamic> set,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFFF8551),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${setIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8551),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: TextFormField(
                  initialValue: set['reps'].toString(),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) {
                    setState(() {
                      set['reps'] = num.tryParse(v) ?? 12;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Weight Input
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8551),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: TextFormField(
                  initialValue: set['weight'].toString(),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) {
                    setState(() {
                      set['weight'] = num.tryParse(v) ?? 60;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () => _removeSet(exerciseIndex, setIndex),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateButton(String label, Color color) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
