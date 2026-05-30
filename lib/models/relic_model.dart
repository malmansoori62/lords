class RelicData {
  final String id;
  final String name;
  final String icon;
  final int zone;
  final String description;
  final String effect;

  const RelicData({
    required this.id,
    required this.name,
    required this.icon,
    required this.zone,
    required this.description,
    required this.effect,
  });

  factory RelicData.fromJson(Map<String, dynamic> j) => RelicData(
        id: j['id'] as String,
        name: j['name'] as String,
        icon: j['icon'] as String,
        zone: j['zone'] as int,
        description: j['description'] as String,
        effect: j['effect'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'zone': zone,
        'description': description,
        'effect': effect,
      };
}
