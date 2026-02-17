import 'package:flutter/material.dart';
import 'package:today_i_lift/features/model/set_data.dart';

class SetRow extends StatelessWidget {
  final int index;
  final SetData set;
  final VoidCallback onToggleDone;
  final VoidCallback onDelete;
  final ValueChanged<String> onKgChanged;
  final ValueChanged<String> onRepsChanged;

  const SetRow({
    super.key,
    required this.index,
    required this.set,
    required this.onToggleDone,
    required this.onDelete,
    required this.onKgChanged,
    required this.onRepsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 25, child: Text('${index + 1}')),
        Expanded(child: Text(set.prev)),
        Expanded(child: TextField(onChanged: onKgChanged)),
        Expanded(child: TextField(onChanged: onRepsChanged)),
        IconButton(icon: Icon(Icons.check), onPressed: onToggleDone),
      ],
    );
  }
}
