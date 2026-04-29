import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  int selectedIndex = 0;

  final characters = [
    {
      'id': 'avatar_1',
      'name': 'Character 1',
      'asset': 'lib/assets/image/profile/p1.png',
    },
    {
      'id': 'avatar_2',
      'name': 'Character 2',
      'asset': 'lib/assets/image/profile/p2.png',
    },
    {
      'id': 'avatar_3',
      'name': 'Character 3',
      'asset': 'lib/assets/image/profile/p3.png',
    },
  ];

  void _showPreviousCharacter() {
    setState(() {
      selectedIndex = selectedIndex == 0
          ? characters.length - 1
          : selectedIndex - 1;
    });
  }

  void _showNextCharacter() {
    setState(() {
      selectedIndex = selectedIndex == characters.length - 1
          ? 0
          : selectedIndex + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCharacter = characters[selectedIndex];
    final selectedName = selectedCharacter['name']!;
    final selectedAsset = selectedCharacter['asset']!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
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
                      onPressed: () {
                        context.go('/home');
                      },
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
          ),
          Expanded(
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
                            const Spacer(),
                            Row(
                              children: [
                                _CircleArrowButton(
                                  icon: Icons.chevron_left,
                                  tooltip: 'Previous character',
                                  onPressed: _showPreviousCharacter,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _CharacterCircle(
                                        asset: selectedAsset,
                                        name: selectedName,
                                      ),
                                      const SizedBox(height: 18),
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        child: Text(
                                          selectedName,
                                          key: ValueKey(selectedName),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          characters.length,
                                          (index) => AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 160,
                                            ),
                                            width: selectedIndex == index
                                                ? 18
                                                : 6,
                                            height: 6,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: selectedIndex == index
                                                  ? AppColors.primary
                                                  : const Color(0xFFE5E7EB),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _CircleArrowButton(
                                  icon: Icons.chevron_right,
                                  tooltip: 'Next character',
                                  onPressed: _showNextCharacter,
                                ),
                              ],
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.go('/home');
                                },
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterCircle extends StatelessWidget {
  final String asset;
  final String name;

  const _CharacterCircle({required this.asset, required this.name});

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

class _CircleArrowButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _CircleArrowButton({
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
