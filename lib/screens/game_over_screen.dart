import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  static const _flavors = [
    'The desert claimed you today.\nThe trainer dragged you back.',
    'Sand filled your lungs.\nSomeone — or something — pulled you free.',
    'Even the scavengers left you alone.\nYou owe someone a debt.',
  ];

  late String _flavor;
  late int _penalty;

  @override
  void initState() {
    super.initState();
    _flavor = _flavors[Random().nextInt(_flavors.length)];
    final player = context.read<PlayerState>();
    _penalty = player.deathGoldPenalty();
    player.recordDeath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('☠', style: TextStyle(fontSize: 60))
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms),
              const SizedBox(height: 24),
              Text(
                'FALLEN IN THE SAND',
                style: AppTheme.title(size: 22, color: AppColors.danger),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
              const SizedBox(height: 20),
              Text(
                _flavor,
                style: AppTheme.body(size: 15, color: AppColors.subtext),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.panelBg,
                  border: Border.all(color: AppColors.danger.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text('RESCUE PENALTY',
                        style: AppTheme.title(
                            size: 13,
                            color: AppColors.danger,
                            spacing: 2)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Gold Lost: ',
                            style: AppTheme.body(size: 15)),
                        Text('-$_penalty 🪙',
                            style: AppTheme.title(
                                size: 18, color: AppColors.danger)),
                      ],
                    ),
                  ],
                ),
              ).animate().slideY(
                    begin: 0.4,
                    delay: 1600.ms,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamedAndRemoveUntil(context, '/hub', (_) => false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.sand),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('RETURN TO HUB',
                      style: AppTheme.title(size: 14, color: AppColors.sand)),
                ),
              ).animate().fadeIn(delay: 2200.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
