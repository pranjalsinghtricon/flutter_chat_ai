import 'package:flutter/material.dart';

class BottomDrawerOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  BottomDrawerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class BottomDrawerOptions extends StatelessWidget {
  final List<BottomDrawerOption> options;

  const BottomDrawerOptions({
    Key? key,
    required this.options,
  }) : super(key: key);

  Widget _buildOption(BottomDrawerOption option) {
    return GestureDetector(
      onTap: option.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(option.icon, size: 30, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(option.label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map(_buildOption).toList(),
      ),
    );
  }
}