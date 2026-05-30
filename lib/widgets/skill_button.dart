import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/skill_model.dart';
import '../theme/app_theme.dart';

class SkillButton extends StatefulWidget {
  final SkillData skill;
  final int currentEnergy;
  final bool enabled;
  final VoidCallback onTap;

  const SkillButton({
    super.key,
    required this.skill,
    required this.currentEnergy,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<SkillButton> createState() => _SkillButtonState();
}

class _SkillButtonState extends State<SkillButton> {
  bool _pressed = false;

  bool get _canUse =>
      widget.enabled && widget.currentEnergy >= widget.skill.energyCost;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _canUse ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _canUse
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: _canUse ? AppColors.panelBg : AppColors.bg,
            border: Border.all(
              color: _canUse ? AppColors.sand : AppColors.disabled,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.skill.name,
                style: AppTheme.title(
                  size: 13,
                  color: _canUse ? AppColors.text : AppColors.disabled,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.skill.description,
                style: AppTheme.body(
                  size: 10,
                  color: _canUse ? AppColors.subtext : AppColors.disabled,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('⚡', style: AppTheme.body(size: 11)),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.skill.energyCost}',
                    style: AppTheme.body(
                      size: 12,
                      color: _canUse ? AppColors.anima : AppColors.disabled,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate(
        onPlay: (c) => _canUse ? null : c.repeat(reverse: true),
      ).then(delay: 1.seconds),
    );
  }
}
