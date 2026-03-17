// lib/main.dart
// Entry point with upgraded theme system

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';

// ThemeNotifier — controls dark/light toggle globally
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = true; // start in dark mode for wow factor
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    // Update system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness:
      _isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness:
      _isDark ? Brightness.light : Brightness.dark,
    ));
    notifyListeners();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Start with dark status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const AIChatApp(),
    ),
  );
}

class AIChatApp extends StatelessWidget {
  const AIChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return MaterialApp(
      title: 'AI Chat',
      debugShowCheckedModeBanner: false,
      themeMode:
      themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const ChatScreen(),
    );
  }
}