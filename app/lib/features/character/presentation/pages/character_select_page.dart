import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/character/data/character_mock_data.dart';
import 'package:app/features/character/presentation/widgets/character_select_card.dart';
import 'package:app/features/character/presentation/widgets/character_select_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  int selectedIndex = 0;
  final formKey = GlobalKey<FormState>();
  final employeeCodeController = TextEditingController();
  final fullNameController = TextEditingController();
  final positionController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    employeeCodeController.dispose();
    fullNameController.dispose();
    positionController.dispose();
    phoneController.dispose();
    super.dispose();
  }

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

  void _continue() {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    context.go('/home');
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
            formKey: formKey,
            employeeCodeController: employeeCodeController,
            fullNameController: fullNameController,
            positionController: positionController,
            phoneController: phoneController,
            onPrevious: _showPreviousCharacter,
            onNext: _showNextCharacter,
            onContinue: _continue,
          ),
        ],
      ),
    );
  }
}
