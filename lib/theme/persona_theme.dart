// lib/theme/persona_theme.dart
// Each AI persona has its own unique color palette, gradient, and style

import 'package:flutter/material.dart';

class PersonaTheme {
  final String name;
  final String emoji;
  final String subtitle;
  final Color primary;       // main accent color
  final Color secondary;     // secondary accent
  final Color bubbleColor;   // user bubble gradient start
  final Color bubbleEnd;     // user bubble gradient end
  final Color glowColor;     // avatar glow
  final Color chipColor;     // feature chip bg
  final List<Color> gradientColors; // appbar/background gradient
  final IconData icon;

  const PersonaTheme({
    required this.name,
    required this.emoji,
    required this.subtitle,
    required this.primary,
    required this.secondary,
    required this.bubbleColor,
    required this.bubbleEnd,
    required this.glowColor,
    required this.chipColor,
    required this.gradientColors,
    required this.icon,
  });
}

// ── All Persona Themes ────────────────────────────────────────────────────────
class PersonaThemes {

  // 🤖 Assistant — Cool Neon Blue / Purple (default Chattr theme)
  static const PersonaTheme assistant = PersonaTheme(
    name: 'Assistant',
    emoji: '🤖',
    subtitle: 'General AI Assistant',
    primary: Color(0xFF00D4FF),
    secondary: Color(0xFF7C3AED),
    bubbleColor: Color(0xFF00D4FF),
    bubbleEnd: Color(0xFF7C3AED),
    glowColor: Color(0xFF00D4FF),
    chipColor: Color(0xFF0D1A2A),
    gradientColors: [Color(0xFF00D4FF), Color(0xFF7C3AED)],
    icon: Icons.smart_toy_rounded,
  );

  // 👨‍🏫 Tutor — Deep Blue / Indigo (calm, intellectual)
  static const PersonaTheme tutor = PersonaTheme(
    name: 'Tutor',
    emoji: '👨‍🏫',
    subtitle: 'Learn anything, step by step',
    primary: Color(0xFF4F8EF7),
    secondary: Color(0xFF1E3A8A),
    bubbleColor: Color(0xFF4F8EF7),
    bubbleEnd: Color(0xFF1E3A8A),
    glowColor: Color(0xFF4F8EF7),
    chipColor: Color(0xFF0A0F1E),
    gradientColors: [Color(0xFF4F8EF7), Color(0xFF1E3A8A)],
    icon: Icons.school_rounded,
  );

  // 👨‍🍳 Chef — Warm Orange / Red (energetic, appetizing)
  static const PersonaTheme chef = PersonaTheme(
    name: 'Chef',
    emoji: '👨‍🍳',
    subtitle: 'Recipes & cooking tips',
    primary: Color(0xFFFF6B35),
    secondary: Color(0xFFB91C1C),
    bubbleColor: Color(0xFFFF6B35),
    bubbleEnd: Color(0xFFB91C1C),
    glowColor: Color(0xFFFF6B35),
    chipColor: Color(0xFF1A0A05),
    gradientColors: [Color(0xFFFF6B35), Color(0xFFB91C1C)],
    icon: Icons.restaurant_rounded,
  );

  // 💪 Fitness — Electric Green / Teal (energetic, powerful)
  static const PersonaTheme fitness = PersonaTheme(
    name: 'Fitness',
    emoji: '💪',
    subtitle: 'Workouts & nutrition',
    primary: Color(0xFF00F5A0),
    secondary: Color(0xFF0D9488),
    bubbleColor: Color(0xFF00F5A0),
    bubbleEnd: Color(0xFF0D9488),
    glowColor: Color(0xFF00F5A0),
    chipColor: Color(0xFF041A10),
    gradientColors: [Color(0xFF00F5A0), Color(0xFF0D9488)],
    icon: Icons.fitness_center_rounded,
  );

  // ── Helper to get theme by name ───────────────────────────────────────────
  static PersonaTheme of(String name) {
    switch (name) {
      case 'Tutor':   return tutor;
      case 'Chef':    return chef;
      case 'Fitness': return fitness;
      default:        return assistant;
    }
  }

  static const List<PersonaTheme> all = [
    assistant,
    tutor,
    chef,
    fitness,
  ];
}