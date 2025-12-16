// lib/widgets/mode_button.dart

import 'package:flutter/material.dart';

class ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ModeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.grey[300],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.yellow : Colors.transparent,
                width: isSelected ? 3 : 1,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 30,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
