import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CircleArrowButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const CircleArrowButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 42,
        height: 42,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            shape: const CircleBorder(
              side: BorderSide(color: Color(0xFFD7DEE8)),
            ),
          ),
        ),
      ),
    );
  }
}
