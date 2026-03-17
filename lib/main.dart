// lib/main.dart
// Shows OnboardingScreen on first launch, ChatScreen after that

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

// ── ThemeNotifier ─────────────────────────────────────────────────────────────
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness:
      _isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness:
      _isDark ? Brightness.light : Brightness.dark,
    ));
    notifyListeners();
  }
}

// ── Entry Point ───────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));

  // Check if onboarding has been completed before
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: AIChatApp(showOnboarding: !onboardingComplete),
    ),
  );
}

// ── App Root ──────────────────────────────────────────────────────────────────
class AIChatApp extends StatelessWidget {
  final bool showOnboarding;
  const AIChatApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return MaterialApp(
      title: 'Chattr',
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Show onboarding only on first launch
      home: showOnboarding ? const OnboardingScreen() : const ChatScreen(),
    );
  }
}