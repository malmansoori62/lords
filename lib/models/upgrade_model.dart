class UpgradeData {
  final String id;
  final String name;
  final String icon;
  final String label;
  final int effectPerLevel;
  final List<int> costs;
  final int maxLevel;
  final String statKey;

  const UpgradeData({
    required this.id,
    required this.name,
    required this.icon,
    required this.label,
    required this.effectPerLevel,
    required this.costs,
    required this.maxLevel,
    required this.statKey,
  });

  factory UpgradeData.fromJson(Map<String, dynamic> j) => UpgradeData(
        id: j['id'] as String,
        name: j['name'] as String,
        icon: j['icon'] as String,
        label: j['label'] as String,
        effectPerLevel: j['effectPerLevel'] as int,
        costs: List<int>.from(j['costs'] as List),
        maxLevel: j['maxLevel'] as int,
        statKey: j['statKey'] as String,
      );

  int costForLevel(int level) {
    if (level >= costs.length) return 0;
    return costs[level];
  }
}
