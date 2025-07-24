
import 'package:flutter/material.dart';

class EmojiData {
  final String icon;
  final Color color;

  EmojiData({required this.icon, required this.color});
}

class EmojiSelectorField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final void Function(String) onChanged;

  const EmojiSelectorField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<EmojiSelectorField> createState() => _EmojiSelectorFieldState();
}

class _EmojiSelectorFieldState extends State<EmojiSelectorField>
    with TickerProviderStateMixin {
  int? selectedIndex;
  late List<AnimationController> _controllers;

  final List<EmojiData> emojis = [
    EmojiData(icon: '😡', color: Colors.red),
    EmojiData(icon: '😟', color: Colors.orange),
    EmojiData(icon: '😐', color: Colors.amber),
    EmojiData(icon: '😊', color: Colors.lightGreen),
    EmojiData(icon: '😁', color: Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = int.tryParse(widget.initialValue ?? '') != null
        ? int.parse(widget.initialValue!)
        : null;

    _controllers = List.generate(emojis.length, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        lowerBound: 1.0,
        upperBound: 1.3,
      );
    });

    if (selectedIndex != null && selectedIndex! >= 1 && selectedIndex! <= 5) {
      _controllers[selectedIndex! - 1].forward().then((_) {
        _controllers[selectedIndex! - 1].reverse();
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onEmojiTap(int index) {
    setState(() {
      selectedIndex = index + 1;
    });
    widget.onChanged((index + 1).toString());

    _controllers[index].forward().then((_) {
      _controllers[index].reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(emojis.length, (index) {
              final emoji = emojis[index];
              final isSelected = selectedIndex == index + 1;

              return GestureDetector(
                onTap: () => _onEmojiTap(index),
                child: ScaleTransition(
                  scale: _controllers[index],
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? emoji.color.withOpacity(0.2) : null,
                    ),
                    child: Text(
                      emoji.icon,
                      style: TextStyle(
                        fontSize: isSelected ? 36 : 30,
                        color: emoji.color,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
