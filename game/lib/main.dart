import 'package:flutter/material.dart';
import 'models/game_manager.dart';
import 'services/audio_service.dart';
import 'services/stats_service.dart';
import 'widgets/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioService = AudioService();
  final statsService = StatsService();

  runApp(MyApp(
    audioService: audioService,
    statsService: statsService,
  ));
}

class MyApp extends StatelessWidget {
  final AudioService audioService;
  final StatsService statsService;

  const MyApp({
    super.key,
    required this.audioService,
    required this.statsService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bangla Guti Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: GameWrapper(
        audioService: audioService,
        statsService: statsService,
      ),
    );
  }
}

class GameWrapper extends StatefulWidget {
  final AudioService audioService;
  final StatsService statsService;

  const GameWrapper({
    super.key,
    required this.audioService,
    required this.statsService,
  });

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  late GameManager gameManager;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    gameManager = GameManager(
      audioService: widget.audioService,
      statsService: widget.statsService,
    );
    _initAsync();
  }

  Future<void> _initAsync() async {
    await widget.statsService.loadStats();
    gameManager.init();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => initialized = true);
    }
  }

  @override
  void dispose() {
    widget.audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return const SplashScreen();
    }
    return GameScreen(gameManager: gameManager);
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _scaleController,
                  curve: Curves.elasticOut,
                ),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF5252),
                          Color(0xFFFF1744),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.circle,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _slideController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Column(
                    children: [
                      const Text(
                        'BANGLA',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GUTI GAME',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF50A897).withValues(alpha: 0.9),
                          letterSpacing: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
              FadeTransition(
                opacity: _fadeController,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF50A897).withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
