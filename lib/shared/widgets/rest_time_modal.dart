import 'package:flutter/material.dart';

Future<void> showRestTimerPopup(
  BuildContext context, {
  required int initialSeconds,
  required VoidCallback onSkip,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _RestTimerPopup(initialSeconds: initialSeconds, onSkip: onSkip),
  );
}

class _RestTimerPopup extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onSkip;

  const _RestTimerPopup({required this.initialSeconds, required this.onSkip});

  @override
  State<_RestTimerPopup> createState() => _RestTimerPopupState();
}

class _RestTimerPopupState extends State<_RestTimerPopup> {
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _seconds = widget.initialSeconds;
    _tick();
  }

  void _tick() async {
    while (mounted && _seconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _seconds--);
    }

    // หมดเวลา → ปิด modal อัตโนมัติ
    if (mounted && _seconds == 0) {
      Navigator.pop(context);
    }
  }

  void _change(int delta) {
    setState(() {
      _seconds = (_seconds + delta).clamp(0, 60 * 60);
    });
  }

  String get _time {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Rest Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            _time,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleButton('-15', () => _change(-15)),
              const SizedBox(width: 12),
              _circleButton('+15', () => _change(15)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSkip();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Skip Rest'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
