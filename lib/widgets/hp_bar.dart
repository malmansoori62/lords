import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HpBar extends StatelessWidget {
  final int current;
  final int max;
  final Color color;
  final double height;

  const HpBar({
    super.key,
    required this.current,
    required this.max,
    this.color = AppColors.danger,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final barColor = ratio < 0.3 ? AppColors.danger : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('HP', style: AppTheme.body(size: 10, color: AppColors.subtext)),
            Text('$current / $max',
                style: AppTheme.body(size: 10, color: AppColors.text)),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: height,
            color: AppColors.panelBorder,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: ratio),
              duration: const Duration(milliseconds: 300),
              builder: (_, v, __) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: v,
                child: Container(color: barColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
