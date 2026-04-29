import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CharacterCircle extends StatelessWidget {
  final String asset;
  final String name;

  const CharacterCircle({required this.asset, required this.name});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Container(
        key: ValueKey(asset),
        width: 168,
        height: 168,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFEAF1FF),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: ClipOval(
          child: Container(
            color: AppColors.background,
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              semanticLabel: name,
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, color: AppColors.grey, size: 58),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
