import 'package:app/core/auth/auth_session.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/character/data/character_mock_data.dart';
import 'package:app/features/character/presentation/bloc/character_bloc.dart';
import 'package:app/features/character/presentation/bloc/character_event.dart';
import 'package:app/features/character/presentation/bloc/character_state.dart';
import 'package:app/features/character/presentation/widgets/character_select_card.dart';
import 'package:app/features/character/presentation/widgets/character_select_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    final selectedCharacter = characterOptions[selectedIndex];

    context.read<CharacterBloc>().add(
      CreateEmployeeProfileRequested(
        employeeCode: employeeCodeController.text.trim(),
        fullName: fullNameController.text.trim(),
        position: positionController.text.trim(),
        phone: phoneController.text.trim(),
        avatarUrl: selectedCharacter.asset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCharacter = characterOptions[selectedIndex];

    return BlocListener<CharacterBloc, CharacterState>(
      listener: (context, state) async {
        final authSession = context.read<AuthSession>();
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        if (state is CharacterSuccess) {
          await authSession.refreshCurrentUser();

          if (context.mounted) {
            context.go('/home');
          }
        }

        if (state is CharacterFailure) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },

      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            CharacterSelectHeader(onBack: () => context.go('/home')),
            BlocBuilder<CharacterBloc, CharacterState>(
              builder: (context, state) {
                return CharacterSelectCard(
                  selectedCharacter: selectedCharacter,
                  selectedIndex: selectedIndex,
                  characterCount: characterOptions.length,
                  formKey: formKey,
                  employeeCodeController: employeeCodeController,
                  fullNameController: fullNameController,
                  positionController: positionController,
                  phoneController: phoneController,
                  isLoading: state is CharacterLoading,
                  onPrevious: _showPreviousCharacter,
                  onNext: _showNextCharacter,
                  onContinue: _continue,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
