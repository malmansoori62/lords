import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'state/player_state.dart';
import 'state/battle_state.dart';
import 'state/audio_state.dart';
import 'screens/hub_screen.dart';
import 'screens/arena_screen.dart';
import 'screens/victory_screen.dart';
import 'screens/game_over_screen.dart';
import 'screens/cinematic_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LordsOfMirageApp());
}

class LordsOfMirageApp extends StatelessWidget {
  const LordsOfMirageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerState()),
        ChangeNotifierProvider(create: (_) => BattleState()),
        ChangeNotifierProvider(create: (_) => AudioState()),
      ],
      child: MaterialApp(
        title: 'Lords of Mirage',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => const _InitScreen(),
          '/hub': (_) => const HubScreen(),
          '/arena': (_) => const ArenaScreen(),
          '/victory': (_) => const VictoryScreen(),
          '/gameover': (_) => const GameOverScreen(),
          '/cinematic': (_) => const CinematicScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}

class _InitScreen extends StatefulWidget {
  const _InitScreen();

  @override
  State<_InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<_InitScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final player = context.read<PlayerState>();
    await player.load();

    if (!mounted) return;

    if (player.isNewGame) {
      player.markNewGameSeen();
      Navigator.pushReplacementNamed(
        context,
        '/cinematic',
        arguments: {
          'text':
              'The world died when the seas dried...\n\nThe Sand Lords chain the water.\n\nBut the prophecy foretells an Outcast binding the Anima to break the Scorched Sun.',
          'isEpilogue': false,
          'nextRoute': '/hub',
        },
      );
    } else {
      Navigator.pushReplacementNamed(context, '/hub');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0A07),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LORDS OF MIRAGE',
              style: TextStyle(
                color: Color(0xFFF5C518),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Color(0xFFF5C518),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
