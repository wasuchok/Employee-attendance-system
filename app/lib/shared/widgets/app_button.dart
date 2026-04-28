import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AppButtonType { primary, danger, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled;
  final double height;
  final Widget? icon;
  final AppButtonType type;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.height = 48,
    this.icon,
    this.type = AppButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || isLoading;

    Color backgroundColor;
    Color textColor;
    BorderSide? border;

    switch (type) {
      case AppButtonType.primary:
        backgroundColor = AppColors.primary;
        textColor = Colors.white;
        break;

      case AppButtonType.danger:
        backgroundColor = AppColors.danger;
        textColor = Colors.white;
        break;

      case AppButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primary;
        border = const BorderSide(color: AppColors.primary);
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: border ?? BorderSide.none,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
