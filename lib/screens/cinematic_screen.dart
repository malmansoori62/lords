import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class CinematicScreen extends StatefulWidget {
  const CinematicScreen({super.key});

  @override
  State<CinematicScreen> createState() => _CinematicScreenState();
}

class _CinematicScreenState extends State<CinematicScreen> {
  String _displayText = '';
  bool _finished = false;
  Timer? _timer;
  int _charIndex = 0;
  late String _fullText;
  late bool _isEpilogue;
  late String _nextRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _fullText = args['text'] as String;
    _isEpilogue = (args['isEpilogue'] as bool?) ?? false;
    _nextRoute = args['nextRoute'] as String? ?? '/hub';
    _startTypewriter();
  }

  void _startTypewriter() {
    _timer = Timer.periodic(const Duration(milliseconds: 40), (t) {
      if (_charIndex < _fullText.length) {
        setState(() {
          _displayText = _fullText.substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        t.cancel();
        setState(() => _finished = true);
      }
    });
  }

  void _onTap() {
    if (!_finished) {
      _timer?.cancel();
      setState(() {
        _displayText = _fullText;
        _finished = true;
      });
    } else {
      Navigator.pushReplacementNamed(context, _nextRoute);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isEpilogue ? null : _onTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _displayText,
                      style: AppTheme.body(
                          size: 16, color: const Color(0xFFD4C5A0)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (_finished && !_isEpilogue)
                  GestureDetector(
                    onTap: _onTap,
                    child: Text(
                      '[ CONTINUE ]',
                      style: AppTheme.title(
                          size: 14, color: AppColors.gold, spacing: 3),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 800.ms)
                      .then()
                      .fadeOut(duration: 800.ms),
                if (_isEpilogue && _finished)
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, _nextRoute),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold),
                    child: Text('PLAY AGAIN',
                        style: AppTheme.title(
                            size: 14, color: Colors.black)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
