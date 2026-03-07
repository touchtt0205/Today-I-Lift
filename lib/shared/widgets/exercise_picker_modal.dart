import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:today_i_lift/shared/constants/routine_appearance.dart';
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

  static const _groupColors = {
    'Chest': Color(0xFFFF7043),
    'Back': Color(0xFF42A5F5),
    'Legs': Color(0xFF66BB6A),
    'Shoulders': Color(0xFFAB47BC),
    'Arms': Color(0xFFFFCA28),
  };

  static const _groupImages = {
    'Arms':
        'https://xcyamyjwpabstihnrhos.supabase.co/storage/v1/object/public/Muscle/arm.png',
    'Back':
        'https://xcyamyjwpabstihnrhos.supabase.co/storage/v1/object/public/Muscle/back.png',
    'Chest':
        'https://xcyamyjwpabstihnrhos.supabase.co/storage/v1/object/public/Muscle/chest.png',
    'Legs':
        'https://xcyamyjwpabstihnrhos.supabase.co/storage/v1/object/public/Muscle/leg.png',
    'Shoulders':
        'https://xcyamyjwpabstihnrhos.supabase.co/storage/v1/object/public/Muscle/shoulder.png',
  };

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

  Color _groupColor(String? group) {
    return _groupColors[group] ?? const Color(0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const GradientAppBar(
        title: 'Exercise List',
        showDate: false,
        showCloseButton: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildSearchBar(),
          if (!_loading) _buildChips(),
          const SizedBox(height: 8),
          _loading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildList(),
        ],
      ),
    );
  }

  // ─── SEARCH BAR ───────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _search,
          decoration: InputDecoration(
            hintText: 'Search exercise...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: _search.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[400]),
                    onPressed: () {
                      _search.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  // ─── MUSCLE GROUP CHIPS ───────────────────────────────────
  Widget _buildChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedGroup = null),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _selectedGroup == null
                      ? const Color(0xFFFF7043)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedGroup == null
                        ? const Color(0xFFFF7043)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  'All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _selectedGroup == null
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          // Group chips
          ..._muscleGroups.map((g) {
            final selected = _selectedGroup == g;
            final color = _groupColor(g);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedGroup = g),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? color : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    g,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── EXERCISE LIST ────────────────────────────────────────
  Widget _buildList() {
    final list = _filtered();

    if (list.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'No exercises found',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final e = list[i];
          final group = e['muscle_group'] as String?;
          final color = _groupColor(group);

          return GestureDetector(
            onTap: () => Navigator.pop(context, e),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _groupImages[group] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _groupImages[group]!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.fitness_center,
                                color: color,
                                size: 22,
                              ),
                            ),
                          )
                        : Icon(Icons.fitness_center, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Name + group
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            group ?? '-',
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.grey[300],
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
