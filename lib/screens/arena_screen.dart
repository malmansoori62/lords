import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/skill_model.dart';
import '../state/battle_state.dart';
import '../state/player_state.dart';
import '../state/audio_state.dart';
import '../theme/app_theme.dart';
import '../widgets/hp_bar.dart';
import '../widgets/energy_bar.dart';
import '../widgets/skill_button.dart';

class ArenaScreen extends StatefulWidget {
  const ArenaScreen({super.key});

  @override
  State<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroLunge;
  late AnimationController _enemyKnockback;
  late AnimationController _screenShake;

  // Damage popup system
  final List<_DamagePopup> _popups = [];
  String? _statusMessage;
  bool _phase2Banner = false;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _heroLunge = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _enemyKnockback = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _screenShake = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _setupBattle();
    }
  }

  void _setupBattle() {
    final player = context.read<PlayerState>();
    final battle = context.read<BattleState>();
    final audio = context.read<AudioState>();

    final enemy = player.randomEnemyFromZone();
    final zone = player.zone;

    battle.initBattle(
      enemy: enemy,
      playerHP: player.maxHP,
      playerMaxHP: player.maxHP,
      playerAttack: player.baseAttack,
      relics: player.relics,
      thirstTurnValue: player.thirstTurn,
      hpMod: player.difficultyHpMod,
      atkMod: player.difficultyAtkMod,
      hazardData: zone.hazard,
    );

    audio.startBattle();

    context.read<BattleState>().addListener(_onBattleChanged);
  }

  void _onBattleChanged() {
    final battle = context.read<BattleState>();
    final event = battle.lastEvent;
    if (event == null) return;

    switch (event.type) {
      case 'playerHit':
        _heroLunge.forward(from: 0);
        if (event.isCrit) _screenShake.forward(from: 0);
        _addPopup(event.value ?? 0, isPlayer: false, isCrit: event.isCrit);
        context.read<AudioState>().playSfx('sfx_slash.wav');
      case 'enemyHit':
        _enemyKnockback.forward(from: 0);
        if (event.isCrit) _screenShake.forward(from: 0);
        _addPopup(event.value ?? 0, isPlayer: true);
      case 'evade':
        setState(() => _statusMessage = 'EVADE ACTIVE');
        context.read<AudioState>().playSfx('sfx_mirage_step.wav');
      case 'dodged':
        setState(() => _statusMessage = 'DODGED!');
      case 'animaDrain':
        setState(() => _statusMessage = 'ANIMA DRAIN — 2 turns');
      case 'phase2Trigger':
        setState(() {
          _phase2Banner = true;
          _statusMessage = 'THE SUN EATER AWAKENS HIS TRUE FORM!';
        });
        context.read<AudioState>().triggerBossPhase2();
      case 'sandstorm':
        setState(() => _statusMessage = 'SANDSTORM! -${event.value} HP all');
      case 'crystalReflect':
        setState(() => _statusMessage = 'CRYSTAL ARMOR — 5 reflected!');
    }

    if (battle.phase == BattlePhase.playerWon) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/victory');
      });
    } else if (battle.phase == BattlePhase.playerLost) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/gameover');
      });
    }
  }

  void _addPopup(int value, {required bool isPlayer, bool isCrit = false}) {
    setState(() {
      _popups.add(_DamagePopup(
        value: value,
        isPlayer: isPlayer,
        isCrit: isCrit,
        id: Random().nextDouble(),
      ));
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _popups.removeWhere((p) => p.value == value));
    });
  }

  @override
  void dispose() {
    context.read<BattleState>().removeListener(_onBattleChanged);
    _heroLunge.dispose();
    _enemyKnockback.dispose();
    _screenShake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final battle = context.watch<BattleState>();
    final player = context.watch<PlayerState>();
    final isPlayerTurn = battle.phase == BattlePhase.playerTurn;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedBuilder(
        animation: _screenShake,
        builder: (ctx, child) {
          final shakeOffset = _screenShake.isAnimating
              ? sin(_screenShake.value * pi * 4) * 6
              : 0.0;
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // TOP 40% — Cinema frame
              Expanded(
                flex: 40,
                child: _buildCinemaFrame(battle, player),
              ),
              // Divider
              Container(height: 2, color: AppColors.panelBorder),
              // BOTTOM 60% — Controls
              Expanded(
                flex: 60,
                child: _buildControlFrame(battle, player, isPlayerTurn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCinemaFrame(BattleState battle, PlayerState player) {
    final bgColor = player.currentZone == 1
        ? const Color(0xFF2C1A08)
        : player.currentZone == 2
            ? const Color(0xFF0A1A2C)
            : const Color(0xFF2C0A0A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      color: battle.playerDehydrated
          ? AppColors.thirst.withOpacity(0.2)
          : _phase2Banner
              ? Colors.black
              : bgColor,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // HP bars row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('The Outcast',
                              style: AppTheme.body(size: 11, color: AppColors.subtext)),
                          HpBar(
                            current: battle.playerCurrentHP,
                            max: battle.playerMaxHP,
                            color: AppColors.water,
                          ),
                          _statusBadges(battle),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(battle.enemyName,
                              style: AppTheme.body(size: 11, color: AppColors.subtext)),
                          HpBar(
                            current: battle.enemyCurrentHP,
                            max: battle.enemyMaxHP,
                            color: AppColors.enemyHit,
                          ),
                          _intentIcon(battle.currentIntent),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Sprite row
                Expanded(
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _heroSprite(battle),
                          _enemySprite(battle),
                        ],
                      ),
                      // Damage popups
                      ..._popups.map((p) => _buildPopupWidget(p)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Status message banner
          if (_statusMessage != null)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: AppTheme.body(size: 11, color: AppColors.gold),
                  ),
                ),
              ).animate()
                  .fadeIn(duration: 200.ms)
                  .then(delay: 1.5.seconds)
                  .fadeOut(duration: 400.ms)
                  .callback(callback: (_) {
                    if (mounted) setState(() => _statusMessage = null);
                  }),
            ),
        ],
      ),
    );
  }

  Widget _heroSprite(BattleState battle) {
    return AnimatedBuilder(
      animation: _heroLunge,
      builder: (_, child) => Transform.translate(
        offset: Offset(
            _heroLunge.isAnimating
                ? sin(_heroLunge.value * pi) * 30
                : 0,
            0),
        child: child,
      ),
      child: Container(
        width: 90,
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.anima.withOpacity(0.2),
          border: Border.all(
            color: battle.playerEvade ? AppColors.anima : AppColors.panelBorder,
            width: battle.playerEvade ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🗡️', style: const TextStyle(fontSize: 32)),
            Text('Outcast',
                style: AppTheme.body(size: 10, color: AppColors.subtext)),
          ],
        ),
      ),
    );
  }

  Widget _enemySprite(BattleState battle) {
    return AnimatedBuilder(
      animation: _enemyKnockback,
      builder: (_, child) => Transform.translate(
        offset: Offset(
            _enemyKnockback.isAnimating
                ? _enemyKnockback.value * 15
                : 0,
            0),
        child: child,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: 90,
        height: 110,
        decoration: BoxDecoration(
          color: battle.isBossPhase2
              ? AppColors.bossPhase2.withOpacity(0.2)
              : AppColors.danger.withOpacity(0.1),
          border: Border.all(
            color: battle.isBossPhase2
                ? AppColors.bossPhase2
                : AppColors.panelBorder,
            width: battle.isBoss ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              battle.isBoss ? '☀️' : battle.isBossPhase2 ? '🔥' : '👹',
              style: const TextStyle(fontSize: 32),
            ),
            Text(
              '${battle.enemyCurrentHP}/${battle.enemyMaxHP}',
              style: AppTheme.body(size: 9, color: AppColors.subtext),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupWidget(_DamagePopup p) {
    return Positioned(
      left: p.isPlayer ? 20 : null,
      right: p.isPlayer ? null : 20,
      top: 30,
      child: Text(
        '${p.isPlayer ? "" : "-"}${p.value}',
        style: p.isPlayer
            ? AppTheme.damage(isCrit: p.isCrit)
            : AppTheme.enemyDamage(isCrit: p.isCrit),
      )
          .animate()
          .fadeIn(duration: 100.ms)
          .slideY(begin: 0, end: -1, duration: 800.ms)
          .fadeOut(delay: 500.ms, duration: 300.ms),
    );
  }

  Widget _statusBadges(BattleState battle) {
    final badges = <String>[];
    if (battle.playerEvade) badges.add('EVADE 💨');
    if (battle.playerDehydrated) badges.add('THIRST 🌡️');
    if (battle.playerPoisonTurns > 0) badges.add('POISON ☠️×${battle.playerPoisonTurns}');
    if (battle.animaDrainActive) badges.add('DRAIN ⚡×${battle.animaDrainTurnsLeft}');

    return Wrap(
      spacing: 4,
      children: badges.map((b) => Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(b, style: AppTheme.body(size: 8, color: AppColors.danger)),
      )).toList(),
    );
  }

  Widget _intentIcon(String intent) {
    final icons = {
      'slash': '⚔️ Attack',
      'poison': '🧪 Poison',
      'defend': '🛡️ Defend',
      'heavy': '💥 Heavy',
      'debuff': '🌀 Debuff',
      'special': '🔥 Special',
    };
    final label = icons[intent] ?? '❓';
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.panelBorder,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: AppTheme.body(size: 9, color: AppColors.text)),
    );
  }

  Widget _buildControlFrame(
      BattleState battle, PlayerState player, bool isPlayerTurn) {
    return Container(
      color: AppColors.panelBg,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Turn info + hazard
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Turn ${battle.turnCount + 1}',
                  style: AppTheme.title(size: 12, color: AppColors.subtext)),
              _hazardBadge(player),
              Text(
                battle.phase == BattlePhase.playerTurn
                    ? 'YOUR TURN'
                    : battle.phase == BattlePhase.enemyTurn
                        ? 'ENEMY TURN'
                        : '...',
                style: AppTheme.title(
                    size: 12,
                    color: battle.phase == BattlePhase.playerTurn
                        ? AppColors.water
                        : AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Energy bar
          EnergyBar(
            current: battle.currentEnergy,
            drained: battle.animaDrainActive,
          ),
          const SizedBox(height: 16),
          // Skill buttons
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: Skills.all.map((skill) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SkillButton(
                        skill: skill,
                        currentEnergy: battle.currentEnergy,
                        enabled: isPlayerTurn,
                        onTap: () =>
                            context.read<BattleState>().useSkill(skill),
                      ),
                    ),
                  )).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Relics row
          if (player.relics.isNotEmpty)
            Row(
              children: [
                Text('Relics: ', style: AppTheme.body(size: 11, color: AppColors.subtext)),
                ...player.relics.map((r) => Tooltip(
                      message: '${r.name}: ${r.description}',
                      child: Text(r.icon,
                          style: const TextStyle(fontSize: 18)),
                    )),
              ],
            ),
        ],
      ),
    );
  }

  Widget _hazardBadge(PlayerState player) {
    final hazard = player.zone.hazard;
    final icons = {
      'sandstorm': '🌪️',
      'mirage_mirrors': '🪞',
      'solar_flare': '☀️',
    };
    final icon = icons[hazard.type] ?? '';
    return Tooltip(
      message: _hazardDesc(hazard.type),
      child: Text(icon, style: const TextStyle(fontSize: 16)),
    );
  }

  String _hazardDesc(String type) {
    switch (type) {
      case 'sandstorm':
        return 'Sandstorm: every 3 turns deals 3 dmg to all';
      case 'mirage_mirrors':
        return 'Mirage Mirrors: 30% chance to reflect debuffs';
      case 'solar_flare':
        return 'Solar Heat: Thirst triggers 1 turn earlier';
      default:
        return '';
    }
  }
}

class _DamagePopup {
  final int value;
  final bool isPlayer;
  final bool isCrit;
  final double id;

  const _DamagePopup({
    required this.value,
    required this.isPlayer,
    required this.isCrit,
    required this.id,
  });
}
