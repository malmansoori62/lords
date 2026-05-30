import 'dart:math';
import 'package:flutter/material.dart';
import '../models/enemy_model.dart';
import '../models/relic_model.dart';
import '../models/skill_model.dart';

enum BattlePhase { playerTurn, resolving, enemyTurn, playerWon, playerLost }

class BattleEvent {
  final String type;
  final int? value;
  final String? target;
  final bool isCrit;

  const BattleEvent({
    required this.type,
    this.value,
    this.target,
    this.isCrit = false,
  });
}

class BattleState extends ChangeNotifier {
  BattlePhase phase = BattlePhase.playerTurn;

  late EnemyData _baseEnemy;
  int enemyCurrentHP = 0;
  int enemyMaxHP = 0;
  bool enemyDefending = false;
  int enemyPoisonTurns = 0;
  int enemyPoisonDamage = 0;
  bool isBossPhase2 = false;

  int playerCurrentHP = 0;
  int playerMaxHP = 0;
  int playerBaseAttack = 0;
  int currentEnergy = 2;
  static const int maxEnergy = 8;

  bool playerEvade = false;
  int playerPoisonTurns = 0;
  int playerPoisonDamage = 0;
  bool playerDehydrated = false;
  bool animaDrainActive = false;
  int animaDrainTurnsLeft = 0;
  bool boneShieldUsed = false;

  int turnCount = 0;
  int biggestHit = 0;
  int goldEarned = 0;
  int waterEarned = 0;

  List<RelicData> activeRelics = [];
  late int thirstTurn;
  HazardData? hazard;
  int hazardTurnCounter = 0;

  BattleEvent? lastEvent;

  final _rng = Random();

  String get currentIntent {
    if (isBossPhase2) {
      final phase2Patterns = ['slash', 'heavy', 'slash', 'special'];
      return phase2Patterns[turnCount % phase2Patterns.length];
    }
    final pattern = _baseEnemy.intentPattern;
    return pattern[turnCount % pattern.length];
  }

  String get enemyName =>
      isBossPhase2 ? 'The Burning God' : _baseEnemy.name;
  bool get isBoss => _baseEnemy.isBoss;

  int get scaledEnemyAttack {
    if (isBossPhase2) return _baseEnemy.phase2Attack ?? _baseEnemy.attackMax;
    return _baseEnemy.attackMin + _rng.nextInt(
        (_baseEnemy.attackMax - _baseEnemy.attackMin + 1).clamp(1, 100));
  }

  void initBattle({
    required EnemyData enemy,
    required int playerHP,
    required int playerMaxHP,
    required int playerAttack,
    required List<RelicData> relics,
    required int thirstTurnValue,
    required double hpMod,
    required double atkMod,
    HazardData? hazardData,
  }) {
    _baseEnemy = enemy;
    final scaledHP = (enemy.hp * hpMod).round();
    enemyCurrentHP = scaledHP;
    enemyMaxHP = scaledHP;
    enemyDefending = false;
    enemyPoisonTurns = 0;
    enemyPoisonDamage = 0;
    isBossPhase2 = false;

    playerCurrentHP = playerHP;
    this.playerMaxHP = playerMaxHP;
    playerBaseAttack = playerAttack;
    activeRelics = relics;

    int bonusEnergy =
        relics.any((r) => r.effect == 'bonus_energy') ? 2 : 0;
    currentEnergy = min(2 + bonusEnergy, maxEnergy);

    playerEvade = false;
    playerPoisonTurns = 0;
    playerPoisonDamage = 0;
    playerDehydrated = false;
    animaDrainActive = false;
    animaDrainTurnsLeft = 0;
    boneShieldUsed = false;

    turnCount = 0;
    biggestHit = 0;
    goldEarned = 0;
    waterEarned = 0;
    thirstTurn = thirstTurnValue;
    hazard = hazardData;
    hazardTurnCounter = 0;
    lastEvent = null;
    phase = BattlePhase.playerTurn;

    notifyListeners();
  }

  Future<void> useSkill(SkillData skill) async {
    if (phase != BattlePhase.playerTurn) return;
    if (currentEnergy < skill.energyCost) return;

    phase = BattlePhase.resolving;
    currentEnergy -= skill.energyCost;
    notifyListeners();

    await _executePlayerSkill(skill);

    if (enemyCurrentHP <= 0) {
      _setWon();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    phase = BattlePhase.enemyTurn;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    await _executeEnemyAction();

    if (playerCurrentHP <= 0) {
      phase = BattlePhase.playerLost;
      notifyListeners();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 400));
    _endOfTurn();

    if (playerCurrentHP <= 0) {
      phase = BattlePhase.playerLost;
      notifyListeners();
      return;
    }

    phase = BattlePhase.playerTurn;
    notifyListeners();
  }

  Future<void> _executePlayerSkill(SkillData skill) async {
    if (skill.effect == 'evade') {
      playerEvade = true;
      int mirageDmg = activeRelics.any((r) => r.effect == 'mirage_damage') ? 8 : 0;
      if (mirageDmg > 0) {
        _dealDamageToEnemy(mirageDmg);
      }
      lastEvent = const BattleEvent(type: 'evade', target: 'player');
      notifyListeners();
      return;
    }

    int rawDamage = (playerBaseAttack * skill.damageMultiplier).round();

    if (skill.id == 'sand_storm') {
      if (activeRelics.any((r) => r.effect == 'sandstorm_bonus')) {
        rawDamage += 15;
      }
    }

    if (skill.id == 'basic_slash' &&
        activeRelics.any((r) => r.effect == 'slash_poison')) {
      enemyPoisonTurns = 3;
      enemyPoisonDamage = 2;
    }

    if (isBossPhase2 && skill.id == 'basic_slash') {
      playerCurrentHP -= 5;
      lastEvent = const BattleEvent(type: 'crystalReflect', value: 5, target: 'player');
      notifyListeners();
    }

    _dealDamageToEnemy(rawDamage);
  }

  void _dealDamageToEnemy(int rawDamage) {
    int damage = rawDamage;
    if (enemyDefending) {
      damage = (damage * 0.5).round();
      enemyDefending = false;
    }
    if (damage > biggestHit) biggestHit = damage;
    enemyCurrentHP = max(0, enemyCurrentHP - damage);

    final isCrit = damage > (enemyMaxHP * 0.2);
    lastEvent = BattleEvent(
        type: 'playerHit', value: damage, target: 'enemy', isCrit: isCrit);
    notifyListeners();

    _checkBossPhase2();
  }

  void _checkBossPhase2() {
    if (_baseEnemy.isBoss &&
        !isBossPhase2 &&
        _baseEnemy.phase2HP != null &&
        enemyCurrentHP <= _baseEnemy.phase2HP!) {
      isBossPhase2 = true;
      lastEvent = const BattleEvent(type: 'phase2Trigger');
      notifyListeners();
    }
  }

  Future<void> _executeEnemyAction() async {
    final intent = currentIntent;

    if (intent == 'defend') {
      enemyDefending = true;
      lastEvent = const BattleEvent(type: 'enemyDefend', target: 'enemy');
      notifyListeners();
      return;
    }

    if (intent == 'special' && isBossPhase2) {
      // Anima Drain — once per battle
      if (!animaDrainActive) {
        animaDrainActive = true;
        animaDrainTurnsLeft = 2;
        lastEvent =
            const BattleEvent(type: 'animaDrain', target: 'player');
        notifyListeners();
      }
      return;
    }

    int baseDamage = scaledEnemyAttack;

    if (intent == 'heavy') baseDamage = (baseDamage * 1.3).round();
    if (intent == 'poison' && _baseEnemy.poisonDamage > 0) {
      playerPoisonTurns = 3;
      playerPoisonDamage = _baseEnemy.poisonDamage;
    }

    // Scorched Earth boss move every 3rd turn
    if (isBossPhase2 && turnCount % 3 == 0) {
      int burnDmg = 20;
      playerCurrentHP = max(0, playerCurrentHP - burnDmg);
      lastEvent = BattleEvent(
          type: 'scorchedEarth', value: burnDmg, target: 'player');
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (playerEvade) {
      playerEvade = false;
      lastEvent = const BattleEvent(type: 'dodged', target: 'player');
      notifyListeners();
      return;
    }

    int finalDamage = baseDamage;

    // Bone Shield relic — absorb first hit
    if (!boneShieldUsed &&
        activeRelics.any((r) => r.effect == 'first_hit_shield')) {
      finalDamage = (finalDamage * 0.5).round();
      boneShieldUsed = true;
    }

    // Mirage Mirrors zone 2 — 30% chance to reflect debuff
    if (hazard?.type == 'mirage_mirrors' &&
        intent == 'poison' &&
        _rng.nextDouble() < (hazard!.reflectChance ?? 0.3)) {
      enemyPoisonTurns = 3;
      enemyPoisonDamage = 2;
      lastEvent =
          const BattleEvent(type: 'mirrorReflect', target: 'enemy');
      notifyListeners();
      return;
    }

    playerCurrentHP = max(0, playerCurrentHP - finalDamage);
    lastEvent = BattleEvent(
        type: 'enemyHit', value: finalDamage, target: 'player');
    notifyListeners();
  }

  void _endOfTurn() {
    // Poison DoT on enemy
    if (enemyPoisonTurns > 0) {
      final dmg = enemyPoisonDamage;
      enemyCurrentHP = max(0, enemyCurrentHP - dmg);
      enemyPoisonTurns--;
    }

    // Poison DoT on player
    if (playerPoisonTurns > 0) {
      final dmg = playerPoisonDamage;
      playerCurrentHP = max(0, playerCurrentHP - dmg);
      playerPoisonTurns--;
    }

    // Dehydration
    if (turnCount >= thirstTurn) {
      if (!playerDehydrated) playerDehydrated = true;
      playerCurrentHP = max(0, playerCurrentHP - 5);
    }

    // Anima Drain timer
    if (animaDrainActive) {
      animaDrainTurnsLeft--;
      if (animaDrainTurnsLeft <= 0) animaDrainActive = false;
    }

    // Zone hazard
    if (hazard?.type == 'sandstorm') {
      hazardTurnCounter++;
      if (hazardTurnCounter >= (hazard!.triggerEveryTurns ?? 3)) {
        final dmg = hazard!.damage ?? 3;
        playerCurrentHP = max(0, playerCurrentHP - dmg);
        enemyCurrentHP = max(0, enemyCurrentHP - dmg);
        hazardTurnCounter = 0;
        lastEvent =
            BattleEvent(type: 'sandstorm', value: dmg, target: 'both');
        notifyListeners();
      }
    }

    // Energy regen
    int regen = animaDrainActive ? 0 : 2;
    currentEnergy = min(maxEnergy, currentEnergy + regen);

    turnCount++;
    notifyListeners();
  }

  void _setWon() {
    goldEarned = _baseEnemy.goldReward;
    waterEarned = _baseEnemy.waterReward;

    // Fast victory bonus
    if (turnCount < 3) waterEarned += 1;

    // Oasis Pearl bonus
    if (activeRelics.any((r) => r.effect == 'victory_water') &&
        playerCurrentHP > playerMaxHP * 0.5) {
      waterEarned += 1;
    }

    phase = BattlePhase.playerWon;
    notifyListeners();
  }

  int get victoryStars {
    if (turnCount <= 3) return 3;
    if (turnCount <= 5) return 2;
    return 1;
  }
}
