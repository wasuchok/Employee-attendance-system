import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/character/data/character_mock_data.dart';
import 'package:app/features/character/domain/models/character_option.dart';
import 'package:app/features/character/presentation/widgets/character_circle.dart';
import 'package:app/features/character/presentation/widgets/circle_arrow_button.dart';
import 'package:app/features/character/presentation/widgets/mock_profile_input.dart';
import 'package:flutter/material.dart';

class CharacterSelectCard extends StatelessWidget {
  final CharacterOption selectedCharacter;
  final int selectedIndex;
  final int characterCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onContinue;

  const CharacterSelectCard({
    super.key,
    required this.selectedCharacter,
    required this.selectedIndex,
    required this.characterCount,
    required this.onPrevious,
    required this.onNext,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, -46),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Choose your character',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pick one avatar for your attendance profile.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            CircleArrowButton(
                              icon: Icons.chevron_left,
                              tooltip: 'Previous character',
                              onPressed: onPrevious,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CharacterCircle(
                                    asset: selectedCharacter.asset,
                                    name: selectedCharacter.name,
                                  ),
                                  const SizedBox(height: 18),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    child: Text(
                                      selectedCharacter.name,
                                      key: ValueKey(selectedCharacter.name),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      characterOptions.length,
                                      (index) => AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 160,
                                        ),
                                        width: selectedIndex == index ? 18 : 6,
                                        height: 6,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedIndex == index
                                              ? AppColors.primary
                                              : const Color(0xFFE5E7EB),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircleArrowButton(
                              icon: Icons.chevron_right,
                              tooltip: 'Next character',
                              onPressed: onNext,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const MockProfileInput(
                          label: 'Employee Code',
                          initialValue: 'EMP001',
                        ),
                        const SizedBox(height: 12),
                        const MockProfileInput(
                          label: 'Full Name',
                          initialValue: 'Wasuchok Jainam',
                        ),
                        const SizedBox(height: 12),
                        const MockProfileInput(
                          label: 'Position',
                          initialValue: 'Backend Developer',
                        ),
                        const SizedBox(height: 12),
                        const MockProfileInput(
                          label: 'Phone',
                          initialValue: '0999999999',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: onContinue,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
