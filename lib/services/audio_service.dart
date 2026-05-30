import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final AudioPlayer _bgmBase = AudioPlayer();
  final AudioPlayer _bgmStrings = AudioPlayer();
  final AudioPlayer _bgmDrums = AudioPlayer();
  final AudioPlayer _bgmIntensity = AudioPlayer();
  final AudioPlayer _bgmBoss = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool sfxEnabled = true;
  bool bgmEnabled = true;

  Future<void> init() async {
    await _bgmBase.setReleaseMode(ReleaseMode.loop);
    await _bgmStrings.setReleaseMode(ReleaseMode.loop);
    await _bgmDrums.setReleaseMode(ReleaseMode.loop);
    await _bgmIntensity.setReleaseMode(ReleaseMode.loop);
    await _bgmBoss.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> startHub() async {
    if (!bgmEnabled) return;
    await _stopBattle();
    await _safePlay(_bgmBase, 'audio/bgm/bgm_base_ambient.mp3');
    await _safePlay(_bgmStrings, 'audio/bgm/bgm_layer_strings.mp3');
  }

  Future<void> startBattle() async {
    if (!bgmEnabled) return;
    await _bgmStrings.setVolume(0);
    await _safePlay(_bgmDrums, 'audio/bgm/bgm_layer_drums.mp3');
  }

  Future<void> triggerIntensity() async {
    if (!bgmEnabled) return;
    await _safePlay(_bgmIntensity, 'audio/bgm/bgm_layer_intensity.mp3');
  }

  Future<void> triggerBossPhase2() async {
    if (!bgmEnabled) return;
    await _safePlay(_bgmBoss, 'audio/bgm/bgm_layer_boss_phase2.mp3');
  }

  Future<void> _stopBattle() async {
    await _bgmDrums.stop();
    await _bgmIntensity.stop();
    await _bgmBoss.stop();
    await _bgmStrings.setVolume(1.0);
  }

  Future<void> playSfx(String file) async {
    if (!sfxEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/$file'));
  }

  Future<void> _safePlay(AudioPlayer player, String path) async {
    try {
      await player.play(AssetSource(path));
    } catch (_) {
      // Audio file not found — silent failure for development
    }
  }

  Future<void> stopAll() async {
    await _bgmBase.stop();
    await _bgmStrings.stop();
    await _bgmDrums.stop();
    await _bgmIntensity.stop();
    await _bgmBoss.stop();
  }
}
