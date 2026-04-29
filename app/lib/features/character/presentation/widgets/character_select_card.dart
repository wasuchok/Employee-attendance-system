import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/character/domain/models/character_option.dart';
import 'package:app/features/character/presentation/widgets/character_circle.dart';
import 'package:app/features/character/presentation/widgets/circle_arrow_button.dart';
import 'package:app/shared/widgets/app_button.dart';
import 'package:app/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class CharacterSelectCard extends StatefulWidget {
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
  State<CharacterSelectCard> createState() => _CharacterSelectCardState();
}

class _CharacterSelectCardState extends State<CharacterSelectCard> {
  final _scrollController = ScrollController();
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicator);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicator();
    });
  }

  @override
  void didUpdateWidget(covariant CharacterSelectCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicator();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicator);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicator() {
    if (!_scrollController.hasClients) {
      return;
    }

    final canScrollDown =
        _scrollController.position.extentAfter > 12 &&
        _scrollController.position.maxScrollExtent > 0;

    if (canScrollDown != _canScrollDown && mounted) {
      setState(() {
        _canScrollDown = canScrollDown;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, -42),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxHeight < 620;
                    final avatarSize = isCompact ? 124.0 : 148.0;
                    final sectionGap = isCompact ? 16.0 : 20.0;

                    return SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.only(bottom: _canScrollDown ? 34 : 0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
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
                            const SizedBox(height: 4),
                            const Text(
                              'Pick one avatar for your attendance profile.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: sectionGap),
                            Row(
                              children: [
                                CircleArrowButton(
                                  icon: Icons.chevron_left,
                                  tooltip: 'Previous character',
                                  onPressed: widget.onPrevious,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CharacterCircle(
                                        asset: widget.selectedCharacter.asset,
                                        name: widget.selectedCharacter.name,
                                        size: avatarSize,
                                      ),
                                      const SizedBox(height: 12),
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        child: Text(
                                          widget.selectedCharacter.name,
                                          key: ValueKey(
                                            widget.selectedCharacter.name,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: AppColors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          widget.characterCount,
                                          (index) => AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 160,
                                            ),
                                            width: widget.selectedIndex == index
                                                ? 18
                                                : 6,
                                            height: 6,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  widget.selectedIndex == index
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
                                CircleArrowButton(
                                  icon: Icons.chevron_right,
                                  tooltip: 'Next character',
                                  onPressed: widget.onNext,
                                ),
                              ],
                            ),
                            SizedBox(height: sectionGap),
                            const AppTextField(
                              label: 'Employee Code',
                              hint: 'EMP001',
                            ),
                            const SizedBox(height: 10),
                            const AppTextField(
                              label: 'Full Name',
                              hint: 'Wasuchok Jainam',
                            ),
                            const SizedBox(height: 10),
                            const AppTextField(
                              label: 'Position',
                              hint: 'Backend Developer',
                            ),
                            const SizedBox(height: 10),
                            const AppTextField(
                              label: 'Phone',
                              hint: '0999999999',
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: sectionGap),
                            AppButton(
                              text: 'Continue',
                              height: 46,
                              onPressed: widget.onContinue,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _canScrollDown ? 1 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: const _ScrollDownIndicator(),
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

class _ScrollDownIndicator extends StatelessWidget {
  const _ScrollDownIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.24),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
