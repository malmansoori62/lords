import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/player_state.dart';
import '../state/audio_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerState>();
    final audio = context.read<AudioState>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.panelBg,
        title: Text('Settings', style: AppTheme.title(size: 18)),
        iconTheme: const IconThemeData(color: AppColors.sand),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('Audio'),
          _toggle('Sound Effects', player.sfxEnabled, (v) {
            player.setSfx(v);
            audio.updateSettings(sfx: v, bgm: player.bgmEnabled);
          }),
          _toggle('Background Music', player.bgmEnabled, (v) {
            player.setBgm(v);
            audio.updateSettings(sfx: player.sfxEnabled, bgm: v);
          }),
          const SizedBox(height: 16),
          _section('Accessibility'),
          _toggle('Reduced Motion', player.reducedMotion, player.setReducedMotion),
          const SizedBox(height: 16),
          _section('Difficulty'),
          _difficultySelector(context, player),
          const SizedBox(height: 16),
          _section('Game Version'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Lords of Mirage v1.0.0',
                style: AppTheme.body(size: 12, color: AppColors.subtext)),
          ),
          const SizedBox(height: 32),
          _section('Danger Zone'),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () => _confirmNewGame(context, player),
            child: Text('NEW GAME — Erase All Progress',
                style: AppTheme.title(size: 13, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label.toUpperCase(),
            style: AppTheme.title(size: 12, color: AppColors.sand, spacing: 2)),
      );

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.panelBg,
          border: Border.all(color: AppColors.panelBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SwitchListTile(
          title: Text(label, style: AppTheme.body(size: 14)),
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.gold,
        ),
      );

  Widget _difficultySelector(BuildContext context, PlayerState player) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panelBg,
        border: Border.all(color: AppColors.panelBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ['Easy', 'Normal', 'Hard'].map((d) {
          final selected = player.difficulty == d;
          return GestureDetector(
            onTap: () => player.setDifficulty(d),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
                border: Border.all(
                    color: selected ? AppColors.gold : AppColors.panelBorder),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  if (selected)
                    const Icon(Icons.check, color: AppColors.gold, size: 16),
                  if (selected) const SizedBox(width: 8),
                  Text(d,
                      style: AppTheme.body(
                          size: 14,
                          color: selected ? AppColors.gold : AppColors.text)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _confirmNewGame(BuildContext context, PlayerState player) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.panelBg,
        title: Text('Start Over?', style: AppTheme.title(size: 18)),
        content: Text(
          'All progress, gold, relics, and upgrades will be permanently erased.',
          style: AppTheme.body(size: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.body(color: AppColors.sand)),
          ),
          TextButton(
            onPressed: () async {
              await player.resetAll();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/hub', (_) => false);
              }
            },
            child: Text('Erase & Restart',
                style: AppTheme.body(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
