import 'package:flutter/material.dart';
import 'package:today_i_lift/shared/widgets/rest_time_modal.dart';

class ExerciseCard extends StatefulWidget {
  final String title;
  final int exerciseNumber;
  final List<SetData> initialSets;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final Future<void> Function(SetData set, int setNumber)? onSetCompleted;
  final Future<void> Function(SetData set)? onSetEdited; 
  final Future<void> Function(SetData set)? onSetDeleted; 
  final void Function(int completedSets)? onSetsChanged; 
  final void Function(int restSeconds)? onRestSecondsChanged;

  const ExerciseCard({
    super.key,
    required this.title,
    required this.exerciseNumber,
    required this.initialSets,
    this.isExpanded = false,
    this.onToggle,
    this.onSetCompleted,
    this.onSetEdited,
    this.onSetDeleted,
    this.onSetsChanged, 
    this.onRestSecondsChanged,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  late List<SetData> _sets;
  int _restSeconds = 60;

  String get _restLabel {
    final m = (_restSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_restSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void initState() {
    super.initState();
    _sets = widget.initialSets
        .map((e) => SetData(prev: e.prev, kg: e.kg, reps: e.reps, done: e.done))
        .toList();
  }

  @override
  void dispose() {
    for (final s in _sets) s.dispose();
    super.dispose();
  }

  Future<void> _pickRestTime() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (_) {
        final options = [30, 45, 60, 90, 120, 180];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((sec) {
              final m = (sec ~/ 60).toString().padLeft(2, '0');
              final s = (sec % 60).toString().padLeft(2, '0');
              return ListTile(
                title: Text('$m:$s'),
                onTap: () => Navigator.pop(context, sec),
              );
            }).toList(),
          ),
        );
      },
    );
    if (result != null) {
      setState(() => _restSeconds = result);
      widget.onRestSecondsChanged?.call(result); 
    }
  }

  void _notifyParent() {
    final completed = _sets.where((s) => s.done).length;
    widget.onSetsChanged?.call(completed);
  }

  void _toggleDone(int index) async {
    final set = _sets[index];
    final newDone = !set.done;

    setState(() => set.done = newDone);

    if (newDone) {
      // tick → INSERT
      await widget.onSetCompleted?.call(set, index + 1);

      if (!mounted) return;
      await showRestTimerPopup(
        context,
        initialSeconds: _restSeconds,
        onSkip: () {},
      );
    } else {
      // untick → DELETE
      if (set.setId != null) {
        await widget.onSetDeleted?.call(set);
        set.setId = null; // clear setId
      }
    }

    _notifyParent();
  }

  void _addSet() {
    if (_sets.isEmpty) return;
    final last = _sets.last;
    setState(() {
      _sets.add(
        SetData(
          prev: "${last.kg} x ${last.reps}",
          kg: last.kg,
          reps: last.reps,
          done: false,
        ),
      );
    });

    _notifyParent();
  }

  void _deleteSet(int index) {
    if (_sets.length <= 1) return;
    final set = _sets[index];
    setState(() => _sets.removeAt(index));
    // ถ้า done แล้ว → DELETE ใน DB ด้วย
    if (set.done && set.setId != null) {
      widget.onSetDeleted?.call(set);
    }

    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (widget.isExpanded) _buildExerciseDetails(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isExpanded ? const Color(0xFFFFF1EB) : Colors.white,
        borderRadius: widget.isExpanded
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: widget.onToggle,
        child: Row(
          children: [
            _buildBadge(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: _pickRestTime,
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.orangeAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _restLabel,
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              widget.isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: widget.isExpanded ? Colors.orangeAccent : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isExpanded ? Colors.orangeAccent : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${widget.exerciseNumber}',
        style: TextStyle(
          color: widget.isExpanded ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExerciseDetails() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Row(
            children: [
              SizedBox(
                width: 25,
                child: Text(
                  'SET',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'PREVIOUS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'KG',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'REPS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Icon(Icons.check, size: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_sets.length, (i) => _buildSetRow(i)),
          const SizedBox(height: 12),
          _buildAddSetButton(),
        ],
      ),
    );
  }

  Widget _buildSetRow(int index) {
    final set = _sets[index];

    return Dismissible(
      key: Key('set_${index}_${set.hashCode}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async {
        if (_sets.length <= 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ต้องมีอย่างน้อย 1 เซ็ต'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      onDismissed: (_) {
        _deleteSet(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบเซ็ตที่ ${index + 1} แล้ว'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 25,
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: _buildInputBox(set.prev, isGhost: true)),
            const SizedBox(width: 8),
            Expanded(
              child: _buildEditableBox(set.kgController, (v) {
                setState(() => set.kg = v);
                if (set.done && set.setId != null) {
                  widget.onSetEdited?.call(set); // update ถ้า done แล้ว
                }
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildEditableBox(set.repsController, (v) {
                setState(() => set.reps = v);
                if (set.done && set.setId != null) {
                  widget.onSetEdited?.call(set); // update ถ้า done แล้ว
                }
              }),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _toggleDone(index),
              child: _buildCheckSquare(set.done),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox(String text, {bool isGhost = false}) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: isGhost ? Colors.grey[50] : Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isGhost ? Colors.grey[400] : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableBox(
    TextEditingController controller,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCheckSquare(bool done) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: done ? const Color(0xFF10B981) : Colors.white,
        border: Border.all(
          color: done ? Colors.transparent : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: done
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : null,
    );
  }

  Widget _buildAddSetButton() {
    return GestureDetector(
      onTap: _addSet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            '+ Add Set',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

//ui state
class SetData {
  String prev;
  String kg;
  String reps;
  bool done;
  String? setId;
  late final TextEditingController kgController;
  late final TextEditingController repsController;

  SetData({
    required this.prev,
    required this.kg,
    required this.reps,
    this.done = false,
    this.setId,
  }) {
    kgController = TextEditingController(text: kg);
    repsController = TextEditingController(text: reps);
  }

  void dispose() {
    kgController.dispose();
    repsController.dispose();
  }
}
