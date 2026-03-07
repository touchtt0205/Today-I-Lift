import 'package:flutter/material.dart';

class RoutineExerciseCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> item;
  final VoidCallback onRemove;
  final void Function(int exerciseIndex) onAddSet;
  final void Function(int exerciseIndex, int setIndex) onRemoveSet;

  const RoutineExerciseCard({
    super.key,
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onAddSet,
    required this.onRemoveSet,
  });

  @override
  State<RoutineExerciseCard> createState() => _RoutineExerciseCardState();
}

class _RoutineExerciseCardState extends State<RoutineExerciseCard> {
  final Map<String, TextEditingController> _controllers = {};

  int _version = 0;

  TextEditingController _getController(String key, String initialValue) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initialValue),
    );
  }

  void _bumpVersion() {
    _version++;
    _controllers.removeWhere((key, ctrl) {
      ctrl.dispose();
      return true;
    });
  }

  String _formatWeight(dynamic value) {
    final num n = value ?? 0;
    if (n % 1 == 0) {
      return n.toInt().toString();
    }
    return n.toString();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sets = widget.item['sets'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildHeader(sets.length),
          if (sets.isNotEmpty) _buildSetList(sets),
          _buildAddSetButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(int setCount) {
    return Container(
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
              widget.item['exercises']['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8551),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$setCount Sets',
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
            onPressed: widget.onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSetList(List sets) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: const [
                Expanded(
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
                SizedBox(width: 8),
                Expanded(
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
                SizedBox(width: 32),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...sets.asMap().entries.map((e) => _buildSetRow(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildSetRow(int setIndex, Map<String, dynamic> set) {
    final repsCtrl = _getController(
      'reps_${_version}_$setIndex',
      set['reps'].toString(),
    );
    final weightCtrl = _getController(
      'weight_${_version}_$setIndex',
      _formatWeight(set['weight']),
    );

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
            child: _buildInput(
              weightCtrl,
              (v) => set['weight'] = num.tryParse(v) ?? 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildInput(
              repsCtrl,
              (v) => set['reps'] = num.tryParse(v) ?? 10,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () {
              setState(() => _bumpVersion());
              widget.onRemoveSet(widget.index, setIndex);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFFF8551),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: ctrl,
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
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAddSetButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            setState(() => _bumpVersion());
            widget.onAddSet(widget.index);
          },
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
    );
  }
}
