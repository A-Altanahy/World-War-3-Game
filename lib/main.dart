import 'package:custom_risk/pages/configuration_selection_page.dart';
import 'package:custom_risk/services/question_service.dart';
import 'package:custom_risk/theme/app_theme.dart';
import 'package:custom_risk/utils/fullscreen_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

bool get _isDesktopPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_isDesktopPlatform) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Set system UI overlay style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A0A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize QuestionService
  final questionService = QuestionService();
  await questionService.initialize();

  // Start in windowed mode (user can toggle with F11 or ESC)
  await FullscreenHelper.exitFullscreen();

  runApp(
    ChangeNotifierProvider.value(
      value: questionService,
      child: const StrategicCommandApp(),
    ),
  );
}

class StrategicCommandApp extends StatelessWidget {
  const StrategicCommandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          // Check for F11 key to toggle fullscreen
          if (event.logicalKey == LogicalKeyboardKey.f11) {
            FullscreenHelper.toggleFullscreen();
          }
          // Check for ESC key to exit fullscreen
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            if (FullscreenHelper.isFullscreen) {
              FullscreenHelper.exitFullscreen();
            }
          }
        }
      },
      child: MaterialApp(
        title: 'الحرب العالميه |||',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'), // Set locale to Arabic for RTL
        supportedLocales: const [
          Locale('ar'), // Arabic
          Locale('en'), // English (fallback)
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.darkCommandTheme,
        home: const CommandCenterLanding(),
      ),
    );
  }
}

class CommandCenterLanding extends StatefulWidget {
  const CommandCenterLanding({super.key});

  @override
  State<CommandCenterLanding> createState() => _CommandCenterLandingState();
}

class _CommandCenterLandingState extends State<CommandCenterLanding>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _glowController.repeat(reverse: true);

    // Auto-navigate to configuration after intro
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ConfigurationSelectionPage(),
            transitionDuration: const Duration(milliseconds: 1000),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeAnimation, _glowAnimation]),
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF0A0A0A),
                ],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Command Center Logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFF00D4AA)
                              .withOpacity(_glowAnimation.value),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00D4AA)
                                .withOpacity(_glowAnimation.value * 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shield,
                        size: 80,
                        color:
                            Color(0xFF00D4AA).withOpacity(_glowAnimation.value),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Title
                    Text(
                      'الحرب العالميه |||',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(_fadeAnimation.value),
                        shadows: [
                          Shadow(
                            color: Color(0xFF00D4AA)
                                .withOpacity(_glowAnimation.value * 0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      'الحرب العالميه |||',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white60.withOpacity(_fadeAnimation.value),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Loading indicator
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00D4AA).withOpacity(_glowAnimation.value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'تهيئة النظام...',
                      style: TextStyle(
                        color: Colors.white60.withOpacity(_fadeAnimation.value),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
