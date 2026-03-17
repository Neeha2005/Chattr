// lib/screens/chat_screen.dart
// ✨ Full chat screen with side drawer, new chat, session history

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/export_sheet.dart';
import '../theme/app_theme.dart';
import '../theme/persona_theme.dart';
import '../main.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _currentPersonaName = 'Assistant';
  bool _isRecording = false;

  late AnimationController _appBarAnimController;
  late Animation<double> _appBarFade;

  PersonaTheme get _persona => PersonaThemes.of(_currentPersonaName);

  @override
  void initState() {
    super.initState();
    _appBarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _appBarAnimController, curve: Curves.easeOut),
    );
    _appBarAnimController.forward();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _appBarAnimController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatProvider provider) {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    provider.sendMessage(text);
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ── New Chat ───────────────────────────────────────────────────────────────
  void _startNewChat(ChatProvider provider) {
    provider.saveAndStartNew(
      personaName: _currentPersonaName,
      personaEmoji: _persona.emoji,
    );
    _appBarAnimController.reset();
    _appBarAnimController.forward();
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: _persona.primary, size: 18),
            const SizedBox(width: 8),
            const Text('Chat saved! Starting new conversation.'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Load Session ───────────────────────────────────────────────────────────
  void _loadSession(ChatSession session, ChatProvider provider) {
    // Save current chat before switching
    if (provider.hasMessages) {
      provider.saveAndStartNew(
        personaName: _currentPersonaName,
        personaEmoji: _persona.emoji,
      );
    }
    provider.loadSession(session);
    setState(() => _currentPersonaName = session.personaName);
    _appBarAnimController.reset();
    _appBarAnimController.forward();
  }

  // ── Persona Switcher ───────────────────────────────────────────────────────
  void _switchPersona() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Choose AI Persona',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.lightText,
                ),
              ),
            ),
            const Divider(height: 1),
            ...PersonaThemes.all.map((theme) {
              final isSelected = _currentPersonaName == theme.name;
              return _PersonaTile(
                theme: theme,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _currentPersonaName = theme.name;
                    _appBarAnimController.reset();
                    _appBarAnimController.forward();
                  });
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.hasMessages) _scrollToBottom();
        });

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor:
          isDark ? AppTheme.darkBg : AppTheme.lightBg,
          appBar: _buildAppBar(provider, isDark),

          // ── Side Drawer ──────────────────────────────────────────
          drawer: ChatDrawer(
            currentPersonaName: _currentPersonaName,
            currentPersona: _persona,
            onNewChat: () => _startNewChat(provider),
            onSessionLoad: (session) =>
                _loadSession(session, provider),
          ),

          body: Column(
            children: [
              _PersonaAccentBar(persona: _persona, isDark: isDark),
              Expanded(child: _buildMessageList(provider, isDark)),
              if (provider.replyingTo != null)
                _ReplyBar(
                  message: provider.replyingTo!,
                  isDark: isDark,
                  persona: _persona,
                  onCancel: provider.cancelReply,
                ),
              _buildInputBar(provider, isDark),
            ],
          ),
        );
      },
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(ChatProvider provider, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      elevation: 0,
      // Hamburger menu opens drawer
      leading: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.menu_rounded,
                color: isDark ? Colors.white70 : AppTheme.lightText,
                size: 24),
            // Red dot when there are saved sessions
            if (provider.sessions.isNotEmpty)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _persona.primary,
                    boxShadow: [
                      BoxShadow(
                        color: _persona.glowColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
        onPressed: () =>
            _scaffoldKey.currentState?.openDrawer(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      title: FadeTransition(
        opacity: _appBarFade,
        child: GestureDetector(
          onTap: _switchPersona,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _persona.primary
                          .withValues(alpha: isDark ? 0.25 : 0.15),
                      _persona.secondary
                          .withValues(alpha: isDark ? 0.25 : 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: _persona.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: isDark
                      ? [
                    BoxShadow(
                      color: _persona.glowColor
                          .withValues(alpha: 0.3),
                      blurRadius: 10,
                    )
                  ]
                      : [],
                ),
                child: Center(
                  child: Text(_persona.emoji,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.lightText,
                            ),
                            child: Text(
                              _currentPersonaName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: isDark
                                ? Colors.white38
                                : AppTheme.lightSubtext),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: provider.isLoading
                                ? Colors.orange
                                : _persona.primary,
                            boxShadow: [
                              BoxShadow(
                                color: (provider.isLoading
                                    ? Colors.orange
                                    : _persona.primary)
                                    .withValues(alpha: 0.6),
                                blurRadius: 4,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.isLoading ? 'Thinking…' : 'Online',
                          style: TextStyle(
                            fontSize: 11,
                            color: provider.isLoading
                                ? Colors.orange
                                : _persona.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Theme toggle
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: _persona.primary,
            size: 22,
          ),
          onPressed: () => context.read<ThemeNotifier>().toggle(),
        ),
        // Settings
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.settings_outlined,
              size: 22,
              color: isDark ? Colors.white54 : AppTheme.lightSubtext),
          onPressed: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const SettingsScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOutCubic)),
                    child: child,
                  ),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          ),
        ),
        // Export
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.ios_share_rounded,
              size: 22,
              color: isDark ? Colors.white54 : AppTheme.lightSubtext),
          onPressed: provider.hasMessages
              ? () => ExportSheet.show(
            context: context,
            messages: provider.messages,
            persona: _persona,
            chatTitle: '$_currentPersonaName Chat',
          )
              : null,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Message List ──────────────────────────────────────────────────────────
  Widget _buildMessageList(ChatProvider provider, bool isDark) {
    if (!provider.hasMessages) {
      return _EmptyState(isDark: isDark, persona: _persona);
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount:
      provider.messages.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (provider.isLoading && index == provider.messages.length) {
          return TypingIndicator(
            persona: _currentPersonaName,
            personaTheme: _persona,
          );
        }
        return ChatBubble(
          message: provider.messages[index],
          persona: _currentPersonaName,
          personaTheme: _persona,
        );
      },
    );
  }

  // ── Input Bar ─────────────────────────────────────────────────────────────
  Widget _buildInputBar(ChatProvider provider, bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color:
              isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() => _isRecording = !_isRecording);
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isRecording
                        ? 'Recording... (coming in Week 2)'
                        : 'Recording stopped'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? Colors.red.withValues(alpha: 0.15)
                      : (isDark
                      ? AppTheme.darkCard
                      : AppTheme.lightCard),
                  border: Border.all(
                    color: _isRecording
                        ? Colors.red
                        : (isDark
                        ? AppTheme.darkBorder
                        : AppTheme.lightBorder),
                  ),
                ),
                child: Icon(
                  _isRecording
                      ? Icons.stop_rounded
                      : Icons.mic_rounded,
                  color: _isRecording
                      ? Colors.red
                      : (isDark
                      ? Colors.white54
                      : AppTheme.lightSubtext),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                enabled: !provider.isLoading,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.lightText,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Message $_currentPersonaName…',
                  hintStyle: TextStyle(
                    color: isDark
                        ? const Color(0xFF4A4A6A)
                        : AppTheme.lightSubtext,
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor:
                  isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.lightBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.lightBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: _persona.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(provider),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: provider.isLoading
                  ? Container(
                key: const ValueKey('loading'),
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _persona.primary,
                ),
              )
                  : GestureDetector(
                key: const ValueKey('send'),
                onTap: () => _sendMessage(provider),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _persona.bubbleColor,
                        _persona.bubbleEnd,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _persona.glowColor
                            .withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Persona Accent Bar ────────────────────────────────────────────────────────
class _PersonaAccentBar extends StatelessWidget {
  final PersonaTheme persona;
  final bool isDark;
  const _PersonaAccentBar(
      {required this.persona, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            persona.primary.withValues(alpha: 0.0),
            persona.primary,
            persona.secondary,
            persona.secondary.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

// ── Persona Tile ──────────────────────────────────────────────────────────────
class _PersonaTile extends StatelessWidget {
  final PersonaTheme theme;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  const _PersonaTile(
      {required this.theme,
        required this.isSelected,
        required this.isDark,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: isDark ? 0.1 : 0.06)
              : Colors.transparent,
          border: isSelected
              ? Border(
              left: BorderSide(color: theme.primary, width: 3))
              : const Border(
              left: BorderSide(
                  color: Colors.transparent, width: 3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isSelected
                      ? [theme.primary, theme.secondary]
                      : [
                    isDark
                        ? AppTheme.darkBorder
                        : AppTheme.lightCard,
                    isDark
                        ? AppTheme.darkBorder
                        : AppTheme.lightCard,
                  ],
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color:
                    theme.glowColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                  )
                ]
                    : [],
              ),
              child: Center(
                child: Text(theme.emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(theme.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isSelected
                            ? theme.primary
                            : (isDark
                            ? Colors.white
                            : AppTheme.lightText),
                      )),
                  const SizedBox(height: 2),
                  Text(theme.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white38
                            : AppTheme.lightSubtext,
                      )),
                ],
              ),
            ),
            isSelected
                ? Icon(Icons.check_circle_rounded,
                color: theme.primary, size: 22)
                : Icon(Icons.radio_button_unchecked_rounded,
                color: isDark ? Colors.white24 : Colors.black12,
                size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Reply Bar ─────────────────────────────────────────────────────────────────
class _ReplyBar extends StatelessWidget {
  final dynamic message;
  final bool isDark;
  final PersonaTheme persona;
  final VoidCallback onCancel;
  const _ReplyBar(
      {required this.message,
        required this.isDark,
        required this.persona,
        required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? AppTheme.darkSurface : AppTheme.lightCard,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: persona.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${message.isUser ? 'yourself' : persona.name}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: persona.primary,
                  ),
                ),
                Text(
                  message.text.length > 50
                      ? '${message.text.substring(0, 50)}…'
                      : message.text,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white54
                        : AppTheme.lightSubtext,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                size: 18,
                color: isDark
                    ? Colors.white38
                    : AppTheme.lightSubtext),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatefulWidget {
  final bool isDark;
  final PersonaTheme persona;
  const _EmptyState({required this.isDark, required this.persona});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _float = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _float,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _float.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        widget.persona.primary.withValues(alpha: 0.2),
                        widget.persona.secondary
                            .withValues(alpha: 0.2),
                      ],
                    ),
                    border: Border.all(
                      color: widget.persona.primary
                          .withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: widget.isDark
                        ? [
                      BoxShadow(
                        color: widget.persona.glowColor
                            .withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ]
                        : [],
                  ),
                  child: Center(
                    child: Text(widget.persona.emoji,
                        style: const TextStyle(fontSize: 48)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  widget.persona.primary,
                  widget.persona.secondary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: const Text(
                'Chattr',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                key: ValueKey(widget.persona.name),
                widget.persona.name == 'Assistant'
                    ? 'Start a conversation'
                    : 'Chat with your ${widget.persona.name}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: widget.isDark
                      ? Colors.white
                      : AppTheme.lightText,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.persona.subtitle,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark
                    ? Colors.white38
                    : AppTheme.lightSubtext,
              ),
            ),
            const SizedBox(height: 16),
            // Hint to open drawer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_right_rounded,
                    size: 14,
                    color: widget.isDark
                        ? Colors.white24
                        : Colors.black26),
                const SizedBox(width: 4),
                Text(
                  'Swipe right to see chat history',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDark
                        ? Colors.white24
                        : Colors.black26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _getSuggestions(widget.persona.name)
                  .map((label) => _SuggestionChip(
                label: label,
                isDark: widget.isDark,
                persona: widget.persona,
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getSuggestions(String persona) {
    switch (persona) {
      case 'Tutor':
        return [
          '📚 Explain a concept',
          '🧮 Help with math',
          '✍️ Review my essay'
        ];
      case 'Chef':
        return [
          '🍝 Quick dinner ideas',
          '🥗 Healthy recipes',
          '🎂 Bake something'
        ];
      case 'Fitness':
        return [
          '🏋️ Workout plan',
          '🥦 Meal prep tips',
          '🏃 Cardio routine'
        ];
      default:
        return ['👋 Say hello', '💡 Get ideas', '❓ Ask anything'];
    }
  }
}

// ── Suggestion Chip ───────────────────────────────────────────────────────────
class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final PersonaTheme persona;
  const _SuggestionChip(
      {required this.label,
        required this.isDark,
        required this.persona});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final provider = context.read<ChatProvider>();
        provider.sendMessage(label.substring(2).trim());
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isDark
              ? persona.primary.withValues(alpha: 0.08)
              : persona.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: persona.primary
                .withValues(alpha: isDark ? 0.25 : 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : AppTheme.lightText,
          ),
        ),
      ),
    );
  }
}