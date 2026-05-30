import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/battle_state.dart';

class EnergyBar extends StatelessWidget {
  final int current;
  final bool drained;

  const EnergyBar({super.key, required this.current, this.drained = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('⚡', style: AppTheme.body(size: 13)),
        const SizedBox(width: 4),
        for (int i = 0; i < BattleState.maxEnergy; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 3),
            width: 18,
            height: 12,
            decoration: BoxDecoration(
              color: drained
                  ? AppColors.disabled
                  : (i < current ? AppColors.anima : AppColors.panelBorder),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: AppColors.anima.withOpacity(0.4),
                width: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}
