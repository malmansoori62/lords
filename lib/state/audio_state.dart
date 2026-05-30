import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class AudioState extends ChangeNotifier {
  final AudioService _audio = AudioService();
  bool _initialized = false;

  Future<void> init({required bool sfx, required bool bgm}) async {
    if (_initialized) return;
    _audio.sfxEnabled = sfx;
    _audio.bgmEnabled = bgm;
    await _audio.init();
    _initialized = true;
  }

  void updateSettings({required bool sfx, required bool bgm}) {
    _audio.sfxEnabled = sfx;
    _audio.bgmEnabled = bgm;
  }

  Future<void> startHub() => _audio.startHub();
  Future<void> startBattle() => _audio.startBattle();
  Future<void> triggerIntensity() => _audio.triggerIntensity();
  Future<void> triggerBossPhase2() => _audio.triggerBossPhase2();
  Future<void> stopAll() => _audio.stopAll();

  Future<void> playSfx(String file) => _audio.playSfx(file);
}
