import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CharacterSelectHeader extends StatelessWidget {
  final VoidCallback onBack;

  const CharacterSelectHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 72),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D5BE1), Color(0xFF0647B9)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                color: AppColors.white,
                tooltip: 'Back',
              ),
            ),
            const Expanded(
              child: Text(
                'Select Character',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
