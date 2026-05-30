import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../state/player_state.dart';
import '../state/battle_state.dart';
import '../state/audio_state.dart';
import '../models/relic_model.dart';
import '../theme/app_theme.dart';

class VictoryScreen extends StatefulWidget {
  const VictoryScreen({super.key});

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> {
  RelicData? _dropRelic;
  late int _stars;
  late int _gold;
  late int _water;
  late int _biggestHit;
  late int _turns;
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
  }

  void _apply() {
    if (_applied) return;
    _applied = true;

    final battle = context.read<BattleState>();
    final player = context.read<PlayerState>();
    final audio = context.read<AudioState>();

    _stars = battle.victoryStars;
    _gold = battle.goldEarned;
    _water = battle.waterEarned;
    _biggestHit = battle.biggestHit;
    _turns = battle.turnCount;

    player.earnGold(_gold);
    player.earnWater(_water);
    player.markEnemyDefeated(battle.isBoss ? 'sun_eater' : '');

    if (battle.isBoss) {
      player.clearZone(player.currentZone);
      if (player.currentZone == 3) {
        audio.playSfx('sfx_victory_sun.wav');
      }
    } else {
      final sfx = player.currentZone == 1
          ? 'sfx_victory_bones.wav'
          : player.currentZone == 2
              ? 'sfx_victory_mirage.wav'
              : 'sfx_victory_sun.wav';
      audio.playSfx(sfx);
    }

    if (_stars == 3) player.mark3StarVictory();

    // Relic drop check
    final zone = player.currentZone;
    final zoneRelics = player.allRelics
        .where((r) => r.zone == zone && !player.relics.any((p) => p.id == r.id))
        .toList();
    if (zoneRelics.isNotEmpty) {
      _dropRelic = zoneRelics.first;
      player.addRelic(_dropRelic!);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerState>();
    final isBoss = context.read<BattleState>().isBoss;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Text('VICTORY',
                      style: AppTheme.title(size: 30, color: AppColors.gold))
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scaleXY(begin: 0.8),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => Text(
                          i < _stars ? '⭐' : '☆',
                          style: const TextStyle(fontSize: 28),
                        )),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
              _statCard([
                _statRow('Turns Taken', '$_turns'),
                _statRow('Biggest Hit', '$_biggestHit dmg'),
              ]),
              const SizedBox(height: 12),
              _statCard([
                _statRow('Gold Earned', '+$_gold 🪙', color: AppColors.gold),
                _statRow('Water Earned', '+$_water 💧', color: AppColors.water),
              ]).animate().slideY(begin: 0.3, delay: 600.ms, duration: 400.ms),
              if (_dropRelic != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.panelBg,
                    border: Border.all(color: AppColors.gold),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text('RELIC ACQUIRED',
                          style: AppTheme.title(
                              size: 12, color: AppColors.gold, spacing: 2)),
                      const SizedBox(height: 8),
                      Text(_dropRelic!.icon,
                          style: const TextStyle(fontSize: 32)),
                      Text(_dropRelic!.name, style: AppTheme.title(size: 15)),
                      const SizedBox(height: 4),
                      Text(_dropRelic!.description,
                          style: AppTheme.body(
                              size: 12, color: AppColors.subtext),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ).animate().slideY(
                      begin: -0.5,
                      delay: 800.ms,
                      duration: 600.ms,
                      curve: Curves.bounceOut,
                    ),
              ],
              const Spacer(),
              if (isBoss && player.currentZone == 3)
                _actionButton('SEE EPILOGUE', AppColors.gold, () {
                  Navigator.pushReplacementNamed(context, '/cinematic',
                      arguments: {
                        'text':
                            'Screen flashes white.\n\nThe Citadel cracks open, releasing an explosion of pure, crystal-clear fresh water that floods the desert.\n\nTHE SUN RISES UPON A FREE OASIS.\nYOU ARE NO LONGER AN OUTCAST.\nYOU ARE THE LORD OF THE MIRAGE.',
                        'isEpilogue': true,
                        'nextRoute': '/hub',
                      });
                })
              else
                _actionButton('RETURN TO HUB', AppColors.sand, () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/hub', (_) => false);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(List<Widget> rows) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.panelBg,
          border: Border.all(color: AppColors.panelBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: rows),
      );

  Widget _statRow(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTheme.body(size: 13, color: AppColors.subtext)),
            Text(value,
                style: AppTheme.title(
                    size: 14, color: color ?? AppColors.text)),
          ],
        ),
      );

  Widget _actionButton(String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(label, style: AppTheme.title(size: 14, color: color)),
        ),
      ).animate().fadeIn(delay: 1.seconds);
}
