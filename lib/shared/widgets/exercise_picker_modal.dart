import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:today_i_lift/shared/widgets/gradient_app_bar.dart';

class ExercisePickerModal extends StatefulWidget {
  const ExercisePickerModal({super.key});

  @override
  State<ExercisePickerModal> createState() => _ExercisePickerModalState();
}

class _ExercisePickerModalState extends State<ExercisePickerModal> {
  final _client = Supabase.instance.client;
  final _search = TextEditingController();

  List<Map<String, dynamic>> _exercises = [];
  List<String> _muscleGroups = [];

  bool _loading = true;
  String? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _client.from('exercises').select();

    final list = List<Map<String, dynamic>>.from(res);

    final groups =
        list
            .map((e) => (e['muscle_group'] ?? 'Other') as String)
            .toSet()
            .toList()
          ..sort();

    setState(() {
      _exercises = list;
      _muscleGroups = groups;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered() {
    final q = _search.text.toLowerCase();

    return _exercises.where((e) {
      final matchGroup =
          _selectedGroup == null || e['muscle_group'] == _selectedGroup;

      final matchSearch = e['name'].toString().toLowerCase().contains(q);

      return matchGroup && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Workout  List',
        showDate: false,
        showCloseButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search exercise...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            if (_loading)
              const CircularProgressIndicator()
            else ...[
              DropdownButtonFormField<String>(
                value: _selectedGroup,
                hint: const Text('Select muscle group'),
                items: _muscleGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedGroup = v);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Builder(
                  builder: (_) {
                    final list = _filtered();

                    if (list.isEmpty) {
                      return const Center(child: Text('No exercises'));
                    }

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final e = list[i];

                        return ListTile(
                          title: Text(e['name'] ?? ''),
                          subtitle: Text(e['muscle_group'] ?? ''),
                          onTap: () => Navigator.pop(context, e),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
