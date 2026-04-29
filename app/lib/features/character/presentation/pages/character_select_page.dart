import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/character/data/character_mock_data.dart';
import 'package:app/features/character/presentation/widgets/character_circle.dart';
import 'package:app/features/character/presentation/widgets/character_select_card.dart';
import 'package:app/features/character/presentation/widgets/character_select_header.dart';
import 'package:app/features/character/presentation/widgets/circle_arrow_button.dart';
import 'package:app/features/character/presentation/widgets/mock_profile_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  int selectedIndex = 0;

  void _showPreviousCharacter() {
    setState(() {
      selectedIndex = selectedIndex == 0
          ? characterOptions.length - 1
          : selectedIndex - 1;
    });
  }

  void _showNextCharacter() {
    setState(() {
      selectedIndex = selectedIndex == characterOptions.length - 1
          ? 0
          : selectedIndex + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCharacter = characterOptions[selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CharacterSelectHeader(onBack: () => context.go('/home')),
          CharacterSelectCard(
            selectedCharacter: selectedCharacter,
            selectedIndex: selectedIndex,
            characterCount: characterOptions.length,
            onPrevious: _showPreviousCharacter,
            onNext: _showNextCharacter,
            onContinue: () {
              context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}
