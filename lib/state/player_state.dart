import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/enemy_model.dart';
import '../models/relic_model.dart';
import '../models/upgrade_model.dart';
import '../services/save_service.dart';

class PlayerState extends ChangeNotifier {
  // Resources
  int gold = 0;
  int water = 5;
  int maxWater = 5;

  // Combat stats
  int maxHP = 100;
  int baseAttack = 12;

  // Progression
  int currentZone = 1;
  bool isNewGame = true;
  bool zone1Cleared = false;
  bool zone2Cleared = false;
  bool zone3Cleared = false;
  Set<String> defeatedEnemies = {};

  // Upgrades
  int upgradeAttackLevel = 0;
  int upgradeHPLevel = 0;
  int upgradeFlaskLevel = 0;

  // Relics (max 3)
  List<RelicData> relics = [];

  // World memory
  String noticeBoardText = '';
  int totalDeaths = 0;

  // Settings
  String difficulty = 'Normal';
  bool sfxEnabled = true;
  bool bgmEnabled = true;
  bool reducedMotion = false;

  // Loaded data
  List<ZoneData> zones = [];
  List<RelicData> allRelics = [];
  List<UpgradeData> upgrades = [];

  int get thirstTurn {
    int base;
    switch (difficulty) {
      case 'Easy':
        base = 7;
      case 'Hard':
        base = 4;
      default:
        base = 5;
    }
    if (currentZone == 3) base -= 1;
    return base;
  }

  double get difficultyHpMod =>
      difficulty == 'Easy' ? 0.8 : (difficulty == 'Hard' ? 1.3 : 1.0);

  double get difficultyAtkMod => difficultyHpMod;

  double get difficultyRewardMod => difficulty == 'Easy' ? 1.2 : 1.0;

  ZoneData get zone => zones.firstWhere((z) => z.id == currentZone);

  bool get canTravelToNext =>
      (currentZone == 1 && zone1Cleared) ||
      (currentZone == 2 && zone2Cleared);

  Future<void> load() async {
    await _loadJsonData();
    gold = await SaveService.getInt('playerGold', 0);
    water = await SaveService.getInt('playerWater', 5);
    maxWater = await SaveService.getInt('playerMaxWater', 5);
    maxHP = await SaveService.getInt('playerMaxHP', 100);
    baseAttack = await SaveService.getInt('playerBaseAttack', 12);
    currentZone = await SaveService.getInt('currentZone', 1);
    isNewGame = await SaveService.getBool('isNewGame', true);
    zone1Cleared = await SaveService.getBool('zone1Cleared', false);
    zone2Cleared = await SaveService.getBool('zone2Cleared', false);
    zone3Cleared = await SaveService.getBool('zone3Cleared', false);
    upgradeAttackLevel = await SaveService.getInt('upgradeAttackLevel', 0);
    upgradeHPLevel = await SaveService.getInt('upgradeHPLevel', 0);
    upgradeFlaskLevel = await SaveService.getInt('upgradeFlaskLevel', 0);
    noticeBoardText = await SaveService.getString('noticeBoardText', '');
    totalDeaths = await SaveService.getInt('totalDeaths', 0);
    difficulty = await SaveService.getString('difficultyMode', 'Normal');
    sfxEnabled = await SaveService.getBool('sfxEnabled', true);
    bgmEnabled = await SaveService.getBool('bgmEnabled', true);
    reducedMotion = await SaveService.getBool('reducedMotion', false);

    final relicSlot1 = await SaveService.getString('relicSlot1', '');
    final relicSlot2 = await SaveService.getString('relicSlot2', '');
    final relicSlot3 = await SaveService.getString('relicSlot3', '');
    relics = [relicSlot1, relicSlot2, relicSlot3]
        .where((s) => s.isNotEmpty)
        .map((id) => allRelics.firstWhere((r) => r.id == id,
            orElse: () => allRelics.first))
        .toList();

    final defeated = await SaveService.getString('defeatedEnemies', '');
    defeatedEnemies = defeated.isEmpty ? {} : Set<String>.from(defeated.split(','));

    notifyListeners();
  }

  Future<void> save() async {
    await SaveService.setInt('playerGold', gold);
    await SaveService.setInt('playerWater', water);
    await SaveService.setInt('playerMaxWater', maxWater);
    await SaveService.setInt('playerMaxHP', maxHP);
    await SaveService.setInt('playerBaseAttack', baseAttack);
    await SaveService.setInt('currentZone', currentZone);
    await SaveService.setBool('isNewGame', isNewGame);
    await SaveService.setBool('zone1Cleared', zone1Cleared);
    await SaveService.setBool('zone2Cleared', zone2Cleared);
    await SaveService.setBool('zone3Cleared', zone3Cleared);
    await SaveService.setInt('upgradeAttackLevel', upgradeAttackLevel);
    await SaveService.setInt('upgradeHPLevel', upgradeHPLevel);
    await SaveService.setInt('upgradeFlaskLevel', upgradeFlaskLevel);
    await SaveService.setString('noticeBoardText', noticeBoardText);
    await SaveService.setInt('totalDeaths', totalDeaths);
    await SaveService.setString('difficultyMode', difficulty);
    await SaveService.setBool('sfxEnabled', sfxEnabled);
    await SaveService.setBool('bgmEnabled', bgmEnabled);
    await SaveService.setBool('reducedMotion', reducedMotion);
    await SaveService.setString(
        'relicSlot1', relics.isNotEmpty ? relics[0].id : '');
    await SaveService.setString(
        'relicSlot2', relics.length > 1 ? relics[1].id : '');
    await SaveService.setString(
        'relicSlot3', relics.length > 2 ? relics[2].id : '');
    await SaveService.setString(
        'defeatedEnemies', defeatedEnemies.join(','));
  }

  Future<void> _loadJsonData() async {
    final enemyJson =
        await rootBundle.loadString('assets/data/enemies.json');
    final relicJson =
        await rootBundle.loadString('assets/data/relics.json');
    final upgradeJson =
        await rootBundle.loadString('assets/data/upgrades.json');

    final enemyData = jsonDecode(enemyJson) as Map<String, dynamic>;
    zones = (enemyData['zones'] as List)
        .map((z) => ZoneData.fromJson(z as Map<String, dynamic>))
        .toList();

    final relicData = jsonDecode(relicJson) as Map<String, dynamic>;
    allRelics = (relicData['relics'] as List)
        .map((r) => RelicData.fromJson(r as Map<String, dynamic>))
        .toList();

    final upgradeData = jsonDecode(upgradeJson) as Map<String, dynamic>;
    upgrades = (upgradeData['upgrades'] as List)
        .map((u) => UpgradeData.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  bool hasRelic(String effectId) => relics.any((r) => r.effect == effectId);

  void spendWater() {
    water = max(0, water - 1);
    save();
    notifyListeners();
  }

  void earnGold(int amount) {
    gold += (amount * difficultyRewardMod).round();
    save();
    notifyListeners();
  }

  void earnWater(int amount) {
    water = min(maxWater, water + amount);
    save();
    notifyListeners();
  }

  bool spendGold(int amount) {
    if (gold < amount) return false;
    gold -= amount;
    save();
    notifyListeners();
    return true;
  }

  bool buyUpgrade(UpgradeData upgrade) {
    int level = _levelFor(upgrade);
    if (level >= upgrade.maxLevel) return false;
    int cost = upgrade.costForLevel(level);
    if (!spendGold(cost)) return false;

    switch (upgrade.statKey) {
      case 'attack':
        upgradeAttackLevel++;
        baseAttack += upgrade.effectPerLevel;
      case 'maxHP':
        upgradeHPLevel++;
        maxHP += upgrade.effectPerLevel;
      case 'maxWater':
        upgradeFlaskLevel++;
        maxWater += upgrade.effectPerLevel;
    }
    save();
    notifyListeners();
    return true;
  }

  int _levelFor(UpgradeData u) {
    switch (u.statKey) {
      case 'attack':
        return upgradeAttackLevel;
      case 'maxHP':
        return upgradeHPLevel;
      case 'maxWater':
        return upgradeFlaskLevel;
      default:
        return 0;
    }
  }

  int levelFor(UpgradeData u) => _levelFor(u);

  void addRelic(RelicData relic) {
    if (relics.any((r) => r.id == relic.id)) return;
    if (relics.length >= 3) relics.removeAt(0);
    relics.add(relic);
    save();
    notifyListeners();
  }

  void markEnemyDefeated(String enemyId) {
    defeatedEnemies.add(enemyId);
    save();
    notifyListeners();
  }

  void clearZone(int zoneId) {
    if (zoneId == 1) zone1Cleared = true;
    if (zoneId == 2) zone2Cleared = true;
    if (zoneId == 3) zone3Cleared = true;
    _updateNoticeBoard(zoneId);
    save();
    notifyListeners();
  }

  bool travelToNextZone() {
    final z = zone;
    if (!canTravelToNext) return false;
    if (!spendGold(z.caravanGoldCost)) return false;
    final waterNeeded = z.caravanWaterCost;
    if (water < waterNeeded) return false;
    water -= waterNeeded;
    currentZone++;
    save();
    notifyListeners();
    return true;
  }

  void recordDeath() {
    totalDeaths++;
    if (totalDeaths % 2 == 0) {
      noticeBoardText =
          'The arena whispers your name with pity. The trainer sharpens your blade in silence.';
    }
    final penalty = difficulty == 'Hard' ? 0.5 : 0.4;
    gold = (gold * (1 - penalty)).floor();
    save();
    notifyListeners();
  }

  int deathGoldPenalty() {
    final penalty = difficulty == 'Hard' ? 0.5 : 0.4;
    return (gold * penalty).floor();
  }

  void mark3StarVictory() {
    noticeBoardText =
        'Word spreads of a fighter who ended the bout before the sand settled.';
    save();
    notifyListeners();
  }

  void _updateNoticeBoard(int zoneId) {
    switch (zoneId) {
      case 1:
        noticeBoardText =
            'Rusty Bones fell silent. The scavengers scatter into the deep sands.';
      case 2:
        noticeBoardText =
            'The Blue Mirage dims. Travelers report the fog lifting for the first time in years.';
      case 3:
        noticeBoardText =
            'A tremor shook the Citadel. The Sand Lords\' banner falls. Water flows free.';
    }
  }

  EnemyData randomEnemyFromZone() {
    final enemies = zone.enemies;
    final rng = Random();
    if (!zone1Cleared && currentZone == 1) {
      final notDefeated = enemies.where((e) => !defeatedEnemies.contains(e.id)).toList();
      if (notDefeated.isNotEmpty) return notDefeated.first;
    }
    return enemies[rng.nextInt(enemies.length)];
  }

  void markNewGameSeen() {
    isNewGame = false;
    save();
    notifyListeners();
  }

  Future<void> resetAll() async {
    await SaveService.clear();
    await load();
    isNewGame = true;
    await save();
    notifyListeners();
  }

  void setSfx(bool v) {
    sfxEnabled = v;
    save();
    notifyListeners();
  }

  void setBgm(bool v) {
    bgmEnabled = v;
    save();
    notifyListeners();
  }

  void setReducedMotion(bool v) {
    reducedMotion = v;
    save();
    notifyListeners();
  }

  void setDifficulty(String v) {
    difficulty = v;
    save();
    notifyListeners();
  }
}
