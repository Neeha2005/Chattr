// lib/screens/onboarding_screen.dart
// ✨ Beautiful 3-slide onboarding with animations, gradient backgrounds,
//    particle effects, and smooth page transitions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

// ── Onboarding Data ───────────────────────────────────────────────────────────
class _OnboardingData {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> gradientColors;
  final List<String> features;

  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradientColors,
    required this.features,
  });
}

const List<_OnboardingData> _slides = [
  _OnboardingData(
    emoji: '🤖',
    title: 'Chattr',
    subtitle: 'Your AI companion',
    description:
    'Chat with a powerful AI that understands you. Ask anything, get instant intelligent answers.',
    gradientColors: [Color(0xFF0A0A0F), Color(0xFF0D0D1A)],
    features: ['Instant responses', 'Smart context', 'Always available'],
  ),
  _OnboardingData(
    emoji: '🎭',
    title: 'Choose your',
    subtitle: 'AI Persona',
    description:
    'Switch between specialized AI personas — a tutor, chef, or fitness coach — each with unique expertise.',
    gradientColors: [Color(0xFF0A0A0F), Color(0xFF0F0A1A)],
    features: ['🤖 Assistant', '👨‍🏫 Tutor', '👨‍🍳 Chef', '💪 Fitness'],
  ),
  _OnboardingData(
    emoji: '✨',
    title: 'Built for',
    subtitle: 'Great conversations',
    description:
    'React to messages, reply in threads, search history, and export chats. Everything you need.',
    gradientColors: [Color(0xFF0A0A0F), Color(0xFF0A0F1A)],
    features: ['Emoji reactions', 'Swipe to reply', 'Export chats'],
  ),
];

// ── Main Onboarding Screen ────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnim;
  late Animation<double> _floatAnim;
  late Animation<double> _particleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Fade in controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Float animation for emoji
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Particle controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _particleAnim = CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    );

    // Slide up animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    HapticFeedback.lightImpact();

    // Re-trigger slide animation on page change
    _slideController.reset();
    _slideController.forward();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() => _completeOnboarding();

  Future<void> _completeOnboarding() async {
    // Save that onboarding is done
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ChatScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // ── Animated gradient background ──────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.2,
                colors: [
                  _currentPage == 0
                      ? AppTheme.neonPurple.withValues(alpha: 0.15)
                      : _currentPage == 1
                      ? AppTheme.neonBlue.withValues(alpha: 0.12)
                      : const Color(0xFF00F5A0).withValues(alpha: 0.1),
                  AppTheme.darkBg,
                ],
              ),
            ),
            width: size.width,
            height: size.height,
          ),

          // ── Floating particles ─────────────────────────────────────
          ...List.generate(8, (i) => _Particle(
            index: i,
            animation: _particleAnim,
            color: _currentPage == 0
                ? AppTheme.neonPurple
                : _currentPage == 1
                ? AppTheme.neonBlue
                : const Color(0xFF00F5A0),
          )),

          // ── Main content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 12),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return _SlideContent(
                        data: _slides[index],
                        floatAnim: _floatAnim,
                        slideAnim: _slideAnim,
                        fadeAnim: _fadeAnim,
                        isActive: index == _currentPage,
                      );
                    },
                  ),
                ),

                // ── Bottom section ────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                    child: Column(
                      children: [
                        // Page dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _slides.length,
                                (i) => _PageDot(
                              isActive: i == _currentPage,
                              color: _currentPage == 0
                                  ? AppTheme.neonPurple
                                  : _currentPage == 1
                                  ? AppTheme.neonBlue
                                  : const Color(0xFF00F5A0),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Next / Get Started button
                        GestureDetector(
                          onTap: _nextPage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                colors: _currentPage == 0
                                    ? [
                                  AppTheme.neonPurple,
                                  const Color(0xFF5B21B6)
                                ]
                                    : _currentPage == 1
                                    ? [
                                  AppTheme.neonBlue,
                                  AppTheme.neonPurple,
                                ]
                                    : [
                                  const Color(0xFF00F5A0),
                                  AppTheme.neonBlue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_currentPage == 0
                                      ? AppTheme.neonPurple
                                      : _currentPage == 1
                                      ? AppTheme.neonBlue
                                      : const Color(0xFF00F5A0))
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage == _slides.length - 1
                                        ? 'Get Started'
                                        : 'Continue',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _currentPage == _slides.length - 1
                                        ? Icons.rocket_launch_rounded
                                        : Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Terms text
                        if (_currentPage == _slides.length - 1)
                          Text(
                            'By continuing you agree to our Terms of Service',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide Content ─────────────────────────────────────────────────────────────
class _SlideContent extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> floatAnim;
  final Animation<Offset> slideAnim;
  final Animation<double> fadeAnim;
  final bool isActive;

  const _SlideContent({
    required this.data,
    required this.floatAnim,
    required this.slideAnim,
    required this.fadeAnim,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Floating emoji in glowing circle ──────────────────────
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, floatAnim.value),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      data.gradientColors[1].withValues(alpha: 0.0),
                      data.gradientColors[0].withValues(alpha: 0.0),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonBlue.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    data.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // ── Title ──────────────────────────────────────────────────
          SlideTransition(
            position: slideAnim,
            child: FadeTransition(
              opacity: fadeAnim,
              child: Column(
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: -1,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppTheme.neonBlue, AppTheme.neonPurple],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Description ────────────────────────────────────────────
          SlideTransition(
            position: slideAnim,
            child: FadeTransition(
              opacity: fadeAnim,
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.white.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // ── Feature chips ──────────────────────────────────────────
          SlideTransition(
            position: slideAnim,
            child: FadeTransition(
              opacity: fadeAnim,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: data.features
                    .map((f) => _FeatureChip(label: f))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature Chip ──────────────────────────────────────────────────────────────
class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

// ── Page Dot ──────────────────────────────────────────────────────────────────
class _PageDot extends StatelessWidget {
  final bool isActive;
  final Color color;
  const _PageDot({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? color : Colors.white.withValues(alpha: 0.2),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
          )
        ]
            : [],
      ),
    );
  }
}

// ── Floating Particle ─────────────────────────────────────────────────────────
class _Particle extends StatelessWidget {
  final int index;
  final Animation<double> animation;
  final Color color;

  const _Particle({
    required this.index,
    required this.animation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Each particle has different position and speed
    final positions = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.2),
      Offset(size.width * 0.2, size.height * 0.75),
      Offset(size.width * 0.9, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.05, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.85),
      Offset(size.width * 0.45, size.height * 0.9),
    ];

    final sizes = [4.0, 3.0, 5.0, 3.0, 4.0, 2.5, 4.0, 3.0];
    final speeds = [1.0, 0.7, 1.3, 0.9, 1.1, 0.8, 1.2, 0.6];

    final pos = positions[index % positions.length];
    final particleSize = sizes[index % sizes.length];
    final speed = speeds[index % speeds.length];

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final progress = (animation.value * speed) % 1.0;
        final yOffset = -size.height * progress;
        final opacity = progress < 0.1
            ? progress / 0.1
            : progress > 0.9
            ? (1.0 - progress) / 0.1
            : 1.0;

        return Positioned(
          left: pos.dx,
          top: pos.dy + yOffset,
          child: Opacity(
            opacity: opacity * 0.4,
            child: Container(
              width: particleSize,
              height: particleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}