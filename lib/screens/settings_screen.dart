// lib/screens/settings_screen.dart
// ✨ Full settings page: appearance, font size, language, notifications,
//    chat preferences, about section — all with smooth animations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/persona_theme.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  // ── Settings State ─────────────────────────────────────────────────────────
  double _fontSize = 15;
  String _language = 'English';
  String _bubbleStyle = 'Rounded';
  bool _notificationsEnabled = true;
  bool _dailyTipEnabled = true;
  bool _soundEnabled = false;
  bool _hapticEnabled = true;
  bool _sendOnEnter = true;
  String _defaultPersona = 'Assistant';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const List<String> _languages = [
    'English', 'Spanish', 'French', 'German',
    'Arabic', 'Chinese', 'Japanese', 'Portuguese',
  ];

  static const List<String> _bubbleStyles = [
    'Rounded', 'Pill', 'Sharp', 'Comic',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: _buildAppBar(isDark),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // ── Preview Card ─────────────────────────────────────
              _PreviewCard(
                fontSize: _fontSize,
                bubbleStyle: _bubbleStyle,
                isDark: isDark,
                persona: PersonaThemes.of(_defaultPersona),
              ),

              const SizedBox(height: 24),

              // ── Appearance ───────────────────────────────────────
              const _SectionHeader(title: 'Appearance', icon: Icons.palette_outlined),
              _SettingsCard(
                isDark: isDark,
                children: [
                  // Dark / Light toggle
                  _ToggleTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: const Color(0xFF818CF8),
                    title: 'Dark Mode',
                    subtitle: 'Switch between light and dark',
                    value: isDark,
                    onChanged: (_) =>
                        context.read<ThemeNotifier>().toggle(),
                    isDark: isDark,
                  ),
                  _Divider(isDark: isDark),

                  // Font size slider
                  _FontSizeTile(
                    fontSize: _fontSize,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _fontSize = v),
                  ),
                  _Divider(isDark: isDark),

                  // Bubble style
                  _DropdownTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: const Color(0xFF34D399),
                    title: 'Bubble Style',
                    subtitle: 'Chat bubble shape',
                    value: _bubbleStyle,
                    items: _bubbleStyles,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _bubbleStyle = v!),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Language ─────────────────────────────────────────
              const _SectionHeader(title: 'Language', icon: Icons.language_rounded),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _DropdownTile(
                    icon: Icons.translate_rounded,
                    iconColor: const Color(0xFF60A5FA),
                    title: 'App Language',
                    subtitle: 'Interface language',
                    value: _language,
                    items: _languages,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _language = v!),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Default Persona ───────────────────────────────────
              const _SectionHeader(
                  title: 'AI Persona', icon: Icons.smart_toy_outlined),
              _SettingsCard(
                isDark: isDark,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.star_outline_rounded,
                                  size: 20,
                                  color: Color(0xFFF59E0B)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Default Persona',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.lightText,
                                    )),
                                Text('Opens with this persona',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white38
                                          : AppTheme.lightSubtext,
                                    )),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Persona selector chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PersonaThemes.all.map((p) {
                            final isSelected = _defaultPersona == p.name;
                            return GestureDetector(
                              onTap: () {
                                setState(
                                        () => _defaultPersona = p.name);
                                HapticFeedback.lightImpact();
                              },
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: isSelected
                                      ? LinearGradient(colors: [
                                    p.primary,
                                    p.secondary,
                                  ])
                                      : null,
                                  color: isSelected
                                      ? null
                                      : (isDark
                                      ? AppTheme.darkCard
                                      : AppTheme.lightCard),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : (isDark
                                        ? AppTheme.darkBorder
                                        : AppTheme.lightBorder),
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                    BoxShadow(
                                      color: p.glowColor
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                    )
                                  ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(p.emoji,
                                        style: const TextStyle(
                                            fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      p.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                            ? Colors.white70
                                            : AppTheme.lightText),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Notifications ─────────────────────────────────────
              const _SectionHeader(
                  title: 'Notifications',
                  icon: Icons.notifications_outlined),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _ToggleTile(
                    icon: Icons.notifications_active_outlined,
                    iconColor: const Color(0xFFF87171),
                    title: 'Push Notifications',
                    subtitle: 'Enable all notifications',
                    value: _notificationsEnabled,
                    isDark: isDark,
                    onChanged: (v) =>
                        setState(() => _notificationsEnabled = v),
                  ),
                  _Divider(isDark: isDark),
                  _ToggleTile(
                    icon: Icons.lightbulb_outline_rounded,
                    iconColor: const Color(0xFFFBBF24),
                    title: 'Daily AI Tip',
                    subtitle: 'Morning tip notification',
                    value: _dailyTipEnabled,
                    isDark: isDark,
                    enabled: _notificationsEnabled,
                    onChanged: (v) => setState(() => _dailyTipEnabled = v),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Chat Preferences ──────────────────────────────────
              const _SectionHeader(
                  title: 'Chat', icon: Icons.chat_outlined),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _ToggleTile(
                    icon: Icons.keyboard_return_rounded,
                    iconColor: const Color(0xFF34D399),
                    title: 'Send on Enter',
                    subtitle: 'Press Enter to send message',
                    value: _sendOnEnter,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _sendOnEnter = v),
                  ),
                  _Divider(isDark: isDark),
                  _ToggleTile(
                    icon: Icons.volume_up_outlined,
                    iconColor: const Color(0xFF818CF8),
                    title: 'Sound Effects',
                    subtitle: 'Whoosh on send, pop on receive',
                    value: _soundEnabled,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _soundEnabled = v),
                  ),
                  _Divider(isDark: isDark),
                  _ToggleTile(
                    icon: Icons.vibration_rounded,
                    iconColor: const Color(0xFF60A5FA),
                    title: 'Haptic Feedback',
                    subtitle: 'Vibration on interactions',
                    value: _hapticEnabled,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _hapticEnabled = v),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Data ──────────────────────────────────────────────
              const _SectionHeader(title: 'Data', icon: Icons.storage_outlined),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _ActionTile(
                    icon: Icons.download_outlined,
                    iconColor: const Color(0xFF34D399),
                    title: 'Export Chat History',
                    subtitle: 'Save all chats as .txt file',
                    isDark: isDark,
                    onTap: () => _showComingSoon(context, 'Export'),
                  ),
                  _Divider(isDark: isDark),
                  _ActionTile(
                    icon: Icons.delete_sweep_outlined,
                    iconColor: const Color(0xFFF87171),
                    title: 'Clear All Chats',
                    subtitle: 'Delete entire chat history',
                    isDark: isDark,
                    isDestructive: true,
                    onTap: () => _confirmClearAll(context, isDark),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── About ─────────────────────────────────────────────
              const _SectionHeader(title: 'About', icon: Icons.info_outline_rounded),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _ActionTile(
                    icon: Icons.star_outline_rounded,
                    iconColor: const Color(0xFFFBBF24),
                    title: 'Rate Chattr',
                    subtitle: 'Leave a review on the App Store',
                    isDark: isDark,
                    onTap: () => _showComingSoon(context, 'Rating'),
                  ),
                  _Divider(isDark: isDark),
                  _ActionTile(
                    icon: Icons.share_outlined,
                    iconColor: const Color(0xFF60A5FA),
                    title: 'Share Chattr',
                    subtitle: 'Tell your friends about the app',
                    isDark: isDark,
                    onTap: () => _showComingSoon(context, 'Share'),
                  ),
                  _Divider(isDark: isDark),
                  _InfoTile(
                    icon: Icons.code_rounded,
                    iconColor: const Color(0xFF818CF8),
                    title: 'Version',
                    value: '1.0.0 (Week 1)',
                    isDark: isDark,
                  ),
                  _Divider(isDark: isDark),
                  _InfoTile(
                    icon: Icons.flash_on_rounded,
                    iconColor: const Color(0xFF34D399),
                    title: 'Powered by',
                    value: 'Claude API',
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  'Made with ❤️ using Flutter & Claude API',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white24
                        : AppTheme.lightSubtext.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : AppTheme.lightText, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Settings',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppTheme.lightText,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
            height: 1,
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✅ Settings saved'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Save',
              style: TextStyle(
                color: AppTheme.neonBlue,
                fontWeight: FontWeight.w600,
              )),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming in Week 3 🚀'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all chats?'),
        content: const Text(
            'This will permanently delete your entire chat history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All chats cleared'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

// ── Preview Card ──────────────────────────────────────────────────────────────
class _PreviewCard extends StatelessWidget {
  final double fontSize;
  final String bubbleStyle;
  final bool isDark;
  final PersonaTheme persona;

  const _PreviewCard({
    required this.fontSize,
    required this.bubbleStyle,
    required this.isDark,
    required this.persona,
  });

  BorderRadius _getBubbleRadius(bool isUser) {
    switch (bubbleStyle) {
      case 'Pill':
        return BorderRadius.circular(24);
      case 'Sharp':
        return BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isUser ? 12 : 2),
          bottomRight: Radius.circular(isUser ? 2 : 12),
        );
      case 'Comic':
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      default: // Rounded
        return BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : AppTheme.lightSubtext),
              const SizedBox(width: 6),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                  isDark ? Colors.white38 : AppTheme.lightSubtext,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // AI bubble
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [persona.primary, persona.secondary]),
                ),
                child: Center(
                    child: Text(persona.emoji,
                        style: const TextStyle(fontSize: 14))),
              ),
              const SizedBox(width: 8),
              Flexible(                          // ← ADD Flexible here
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightCard,
                    borderRadius: _getBubbleRadius(false),
                    border: Border.all(
                        color:
                        isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  ),
                  child: Text(
                    'Hello! How can I help you today?',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: isDark ? Colors.white : AppTheme.lightText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // User bubble
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [persona.bubbleColor, persona.bubbleEnd]),
                borderRadius: _getBubbleRadius(true),
                boxShadow: [
                  BoxShadow(
                    color: persona.glowColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'This looks great! ✨',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: isDark ? Colors.white38 : AppTheme.lightSubtext),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark ? Colors.white38 : AppTheme.lightSubtext,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Card ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(children: children),
    );
  }
}

// ── Toggle Tile ───────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.lightText,
                      )),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : AppTheme.lightSubtext,
                      )),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: AppTheme.neonBlue,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Font Size Tile ────────────────────────────────────────────────────────────
class _FontSizeTile extends StatelessWidget {
  final double fontSize;
  final bool isDark;
  final ValueChanged<double> onChanged;

  const _FontSizeTile({
    required this.fontSize,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFA78BFA).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.text_fields_rounded,
                    size: 20, color: Color(0xFFA78BFA)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Font Size',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.lightText,
                        )),
                    Text('${fontSize.round()}px',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white38
                              : AppTheme.lightSubtext,
                        )),
                  ],
                ),
              ),
              // Size preview
              Row(
                children: [
                  Text('A',
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white38
                              : AppTheme.lightSubtext)),
                  const SizedBox(width: 4),
                  const Text('A',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.neonBlue)),
                ],
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.neonBlue,
              inactiveTrackColor:
              isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              thumbColor: AppTheme.neonBlue,
              overlayColor: AppTheme.neonBlue.withValues(alpha: 0.1),
              trackHeight: 3,
            ),
            child: Slider(
              value: fontSize,
              min: 12,
              max: 20,
              divisions: 8,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['12', '14', '16', '18', '20'].map((s) {
              return Text(s,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white24 : AppTheme.lightSubtext,
                  ));
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Dropdown Tile ─────────────────────────────────────────────────────────────
class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.lightText,
                    )),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                      isDark ? Colors.white38 : AppTheme.lightSubtext,
                    )),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                items: items
                    .map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(i,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white
                            : AppTheme.lightText,
                      )),
                ))
                    .toList(),
                onChanged: onChanged,
                isDense: true,
                dropdownColor:
                isDark ? AppTheme.darkCard : Colors.white,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: isDark
                        ? Colors.white38
                        : AppTheme.lightSubtext),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : AppTheme.lightText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Tile ───────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red
                            : (isDark ? Colors.white : AppTheme.lightText),
                      )),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white38
                            : AppTheme.lightSubtext,
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20,
                color:
                isDark ? Colors.white24 : AppTheme.lightSubtext),
          ],
        ),
      ),
    );
  }
}

// ── Info Tile ─────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool isDark;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.lightText,
                )),
          ),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : AppTheme.lightSubtext,
              )),
        ],
      ),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 54,
      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
    );
  }
}