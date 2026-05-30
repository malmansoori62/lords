class HazardData {
  final String type;
  final int? triggerEveryTurns;
  final int? damage;
  final double? reflectChance;
  final int? thirstTurnReduction;

  const HazardData({
    required this.type,
    this.triggerEveryTurns,
    this.damage,
    this.reflectChance,
    this.thirstTurnReduction,
  });

  factory HazardData.fromJson(Map<String, dynamic> j) => HazardData(
        type: j['type'] as String,
        triggerEveryTurns: j['triggerEveryTurns'] as int?,
        damage: j['damage'] as int?,
        reflectChance: (j['reflectChance'] as num?)?.toDouble(),
        thirstTurnReduction: j['thirstTurnReduction'] as int?,
      );
}

class EnemyData {
  final String id;
  final String name;
  final int hp;
  final int attackMin;
  final int attackMax;
  final int poisonDamage;
  final List<String> intentPattern;
  final String weakness;
  final int goldReward;
  final int waterReward;
  final bool isBoss;
  final int? phase2HP;
  final int? phase2Attack;

  const EnemyData({
    required this.id,
    required this.name,
    required this.hp,
    required this.attackMin,
    required this.attackMax,
    required this.poisonDamage,
    required this.intentPattern,
    required this.weakness,
    required this.goldReward,
    required this.waterReward,
    required this.isBoss,
    this.phase2HP,
    this.phase2Attack,
  });

  factory EnemyData.fromJson(Map<String, dynamic> j) => EnemyData(
        id: j['id'] as String,
        name: j['name'] as String,
        hp: j['hp'] as int,
        attackMin: j['attackMin'] as int,
        attackMax: j['attackMax'] as int,
        poisonDamage: (j['poisonDamage'] as int?) ?? 0,
        intentPattern: List<String>.from(j['intentPattern'] as List),
        weakness: j['weakness'] as String,
        goldReward: j['goldReward'] as int,
        waterReward: j['waterReward'] as int,
        isBoss: (j['isBoss'] as bool?) ?? false,
        phase2HP: j['phase2HP'] as int?,
        phase2Attack: j['phase2Attack'] as int?,
      );
}

class ZoneData {
  final int id;
  final String name;
  final int caravanGoldCost;
  final int caravanWaterCost;
  final HazardData hazard;
  final List<EnemyData> enemies;

  const ZoneData({
    required this.id,
    required this.name,
    required this.caravanGoldCost,
    required this.caravanWaterCost,
    required this.hazard,
    required this.enemies,
  });

  factory ZoneData.fromJson(Map<String, dynamic> j) => ZoneData(
        id: j['id'] as int,
        name: j['name'] as String,
        caravanGoldCost: j['caravanGoldCost'] as int,
        caravanWaterCost: j['caravanWaterCost'] as int,
        hazard: HazardData.fromJson(j['hazard'] as Map<String, dynamic>),
        enemies: (j['enemies'] as List)
            .map((e) => EnemyData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
