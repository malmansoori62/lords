class SkillData {
  final String id;
  final String name;
  final int energyCost;
  final String description;
  final String effect;
  final double damageMultiplier;

  const SkillData({
    required this.id,
    required this.name,
    required this.energyCost,
    required this.description,
    required this.effect,
    required this.damageMultiplier,
  });
}

class Skills {
  static const basicSlash = SkillData(
    id: 'basic_slash',
    name: 'Basic Slash',
    energyCost: 0,
    description: '1.0× ATK — always available',
    effect: 'damage',
    damageMultiplier: 1.0,
  );

  static const sandStorm = SkillData(
    id: 'sand_storm',
    name: 'Sand Storm',
    energyCost: 3,
    description: '2.5× ATK heavy strike',
    effect: 'damage',
    damageMultiplier: 2.5,
  );

  static const mirageStep = SkillData(
    id: 'mirage_step',
    name: 'Mirage Step',
    energyCost: 2,
    description: 'Grants Evade — enemy next attack deals 0',
    effect: 'evade',
    damageMultiplier: 0,
  );

  static const List<SkillData> all = [basicSlash, sandStorm, mirageStep];
}
