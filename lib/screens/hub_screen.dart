import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../state/player_state.dart';
import '../state/audio_state.dart';
import '../models/upgrade_model.dart';
import '../theme/app_theme.dart';

class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  bool _audioStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_audioStarted) {
      _audioStarted = true;
      final player = context.read<PlayerState>();
      context.read<AudioState>().init(
            sfx: player.sfxEnabled,
            bgm: player.bgmEnabled,
          );
      context.read<AudioState>().startHub();
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerState>();

    final zoneColor = player.currentZone == 1
        ? const Color(0xFF2C1A08)
        : player.currentZone == 2
            ? const Color(0xFF0A1A2C)
            : const Color(0xFF2C0A0A);

    return Scaffold(
      backgroundColor: zoneColor,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context, player),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    _zoneHeader(player),
                    const SizedBox(height: 8),
                    if (player.noticeBoardText.isNotEmpty)
                      _noticeBoard(player.noticeBoardText),
                    const SizedBox(height: 16),
                    _relicsRow(player),
                    const SizedBox(height: 16),
                    _upgradeShop(context, player),
                    const SizedBox(height: 12),
                    _waterRefill(context, player),
                    const SizedBox(height: 16),
                    _enterArenaButton(context, player),
                    const SizedBox(height: 12),
                    if (player.canTravelToNext) _travelButton(context, player),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, PlayerState player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.panelBg.withOpacity(0.8),
      child: Row(
        children: [
          _resourceChip('💧', '${player.water}/${player.maxWater}', AppColors.water),
          const SizedBox(width: 12),
          _resourceChip('🪙', '${player.gold}', AppColors.gold),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.sand, size: 22),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }

  Widget _resourceChip(String icon, String value, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(value, style: AppTheme.title(size: 13, color: color)),
          ],
        ),
      );

  Widget _zoneHeader(PlayerState player) => Column(
        children: [
          Text(
            player.zone.name.toUpperCase(),
            style: AppTheme.title(size: 20, color: AppColors.gold, spacing: 3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _zoneSubtitle(player.currentZone),
            style: AppTheme.body(size: 12, color: AppColors.subtext),
            textAlign: TextAlign.center,
          ),
        ],
      );

  String _zoneSubtitle(int zone) {
    switch (zone) {
      case 1:
        return 'Tier I — Skeletal dunes and scattered bones';
      case 2:
        return 'Tier II — Shimmering fog over water mirrors';
      case 3:
        return 'Tier III — Red burning sky. The Citadel looms.';
      default:
        return '';
    }
  }

  Widget _noticeBoard(String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.panelBg,
          border: Border.all(color: AppColors.panelBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 ', style: TextStyle(fontSize: 14)),
            Expanded(
              child: Text(
                '"$text"',
                style: AppTheme.body(size: 12, color: AppColors.subtext),
              ),
            ),
          ],
        ),
      ).animate().slideX(begin: -0.2, duration: 300.ms);

  Widget _relicsRow(PlayerState player) {
    if (player.relics.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active Relics',
            style: AppTheme.title(size: 12, color: AppColors.sand, spacing: 1)),
        const SizedBox(height: 6),
        Row(
          children: player.relics.map((r) => Tooltip(
                message: '${r.name}: ${r.description}',
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.panelBg,
                    border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(r.icon, style: const TextStyle(fontSize: 22)),
                ),
              )).toList(),
        ),
      ],
    );
  }

  Widget _upgradeShop(BuildContext context, PlayerState player) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelBg,
        border: Border.all(color: AppColors.panelBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('UPGRADE TRAINER',
              style: AppTheme.title(size: 13, color: AppColors.sand, spacing: 2)),
          const SizedBox(height: 12),
          ...player.upgrades.map((u) => _upgradeRow(context, player, u)),
        ],
      ),
    );
  }

  Widget _upgradeRow(BuildContext context, PlayerState player, UpgradeData u) {
    final level = player.levelFor(u);
    final maxed = level >= u.maxLevel;
    final cost = maxed ? 0 : u.costForLevel(level);
    final canAfford = !maxed && player.gold >= cost;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(u.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.label, style: AppTheme.body(size: 13)),
                Row(
                  children: List.generate(u.maxLevel, (i) => Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: i < level ? AppColors.gold : AppColors.panelBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: canAfford
                ? () {
                    final bought = player.buyUpgrade(u);
                    if (bought) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${u.name} upgraded!',
                            style: AppTheme.body(color: AppColors.gold)),
                        backgroundColor: AppColors.panelBg,
                        duration: const Duration(seconds: 1),
                      ));
                    }
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: maxed
                    ? AppColors.disabled.withOpacity(0.2)
                    : canAfford
                        ? AppColors.gold.withOpacity(0.15)
                        : Colors.transparent,
                border: Border.all(
                  color: maxed
                      ? AppColors.disabled
                      : canAfford
                          ? AppColors.gold
                          : AppColors.panelBorder,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                maxed ? 'MAX' : '🪙 $cost',
                style: AppTheme.title(
                  size: 12,
                  color: maxed
                      ? AppColors.disabled
                      : canAfford
                          ? AppColors.gold
                          : AppColors.subtext,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _waterRefill(BuildContext context, PlayerState player) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelBg,
        border: Border.all(color: AppColors.panelBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WATER SUPPLY',
              style: AppTheme.title(size: 13, color: AppColors.sand, spacing: 2)),
          const SizedBox(height: 10),
          Row(
            children: [
              _refillBtn(context, player, 1, 15),
              const SizedBox(width: 8),
              _refillBtn(context, player, player.maxWater - player.water, 50,
                  label: 'Full Refill'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _refillBtn(
      BuildContext context, PlayerState player, int amount, int cost,
      {String? label}) {
    final canAfford = player.gold >= cost;
    final hasRoom = player.water < player.maxWater;
    final active = canAfford && hasRoom;

    return Expanded(
      child: GestureDetector(
        onTap: active
            ? () {
                player.spendGold(cost);
                player.earnWater(amount);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Water refilled!',
                      style: AppTheme.body(color: AppColors.water)),
                  backgroundColor: AppColors.panelBg,
                  duration: const Duration(seconds: 1),
                ));
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AppColors.water.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
                color: active ? AppColors.water : AppColors.disabled),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            label ?? '+1 💧 (🪙 $cost)',
            style: AppTheme.body(
                size: 12, color: active ? AppColors.water : AppColors.disabled),
          ),
        ),
      ),
    );
  }

  Widget _enterArenaButton(BuildContext context, PlayerState player) {
    final hasWater = player.water > 0;
    return GestureDetector(
      onTap: hasWater
          ? () {
              player.spendWater();
              Navigator.pushNamed(context, '/arena');
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: hasWater
              ? AppColors.gold.withOpacity(0.15)
              : AppColors.disabled.withOpacity(0.1),
          border: Border.all(
            color: hasWater ? AppColors.gold : AppColors.disabled,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              'ENTER ARENA',
              style: AppTheme.title(
                size: 18,
                color: hasWater ? AppColors.gold : AppColors.disabled,
                spacing: 3,
              ),
            ),
            if (!hasWater)
              Text('No water — refill to fight',
                  style: AppTheme.body(size: 11, color: AppColors.disabled)),
            if (hasWater)
              Text('Costs 1 💧',
                  style: AppTheme.body(size: 11, color: AppColors.subtext)),
          ],
        ),
      )
          .animate(onPlay: hasWater ? (c) => c.repeat(reverse: true) : null)
          .scaleXY(
              begin: 1.0,
              end: 1.03,
              duration: 1500.ms,
              curve: Curves.easeInOut),
    );
  }

  Widget _travelButton(BuildContext context, PlayerState player) {
    final zone = player.zone;
    final cost =
        '🪙 ${zone.caravanGoldCost}  💧 ${zone.caravanWaterCost}';
    final canAfford = player.gold >= zone.caravanGoldCost &&
        player.water >= zone.caravanWaterCost;

    return GestureDetector(
      onTap: canAfford
          ? () {
              final ok = player.travelToNextZone();
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Not enough resources!',
                      style: AppTheme.body(color: AppColors.danger)),
                  backgroundColor: AppColors.panelBg,
                ));
                return;
              }
              final nextZone = player.currentZone;
              final texts = {
                2: 'The sands of the Blue Mirage shift. The air grows cold yet thin. The Anima crystals hum louder.',
                3: 'The sky bleeds crimson. The heat of the Scorched Sun burns through leather. The Citadel looms ahead.',
              };
              if (texts.containsKey(nextZone)) {
                Navigator.pushNamed(context, '/cinematic', arguments: {
                  'text': texts[nextZone],
                  'isEpilogue': false,
                  'nextRoute': '/hub',
                });
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
              color: canAfford ? AppColors.sand : AppColors.disabled),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text('TRAVEL TO NEXT ZONE',
                style: AppTheme.title(
                    size: 13,
                    color: canAfford ? AppColors.sand : AppColors.disabled)),
            const SizedBox(height: 4),
            Text(cost,
                style: AppTheme.body(
                    size: 11,
                    color: canAfford ? AppColors.subtext : AppColors.disabled)),
          ],
        ),
      ),
    );
  }
}
