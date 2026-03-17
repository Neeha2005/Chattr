// lib/widgets/chat_drawer.dart
// ✨ Side drawer with chat history, new chat button,
//    session switching, delete, and persona badges

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/chat_session.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../theme/persona_theme.dart';

class ChatDrawer extends StatefulWidget {
  final String currentPersonaName;
  final PersonaTheme currentPersona;
  final VoidCallback onNewChat;
  final Function(ChatSession) onSessionLoad;

  const ChatDrawer({
    super.key,
    required this.currentPersonaName,
    required this.currentPersona,
    required this.onNewChat,
    required this.onSessionLoad,
  });

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(-0.05, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
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
    final provider = context.watch<ChatProvider>();

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Drawer(
          width: 300,
          backgroundColor:
          isDark ? AppTheme.darkSurface : Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              _DrawerHeader(
                persona: widget.currentPersona,
                isDark: isDark,
              ),

              // ── New Chat Button ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _NewChatButton(
                  persona: widget.currentPersona,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    widget.onNewChat();
                  },
                ),
              ),

              // ── Divider + label ─────────────────────────────────────
              if (provider.sessions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded,
                          size: 14,
                          color: isDark
                              ? Colors.white38
                              : AppTheme.lightSubtext),
                      const SizedBox(width: 6),
                      Text(
                        'Recent Chats',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: isDark
                              ? Colors.white38
                              : AppTheme.lightSubtext,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${provider.sessions.length}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white24
                              : AppTheme.lightSubtext,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Session List ────────────────────────────────────────
              Expanded(
                child: provider.sessions.isEmpty
                    ? _EmptyHistory(isDark: isDark)
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  itemCount: provider.sessions.length,
                  itemBuilder: (context, index) {
                    final session = provider.sessions[index];
                    final isActive =
                        session.id == provider.activeSessionId;
                    return _SessionTile(
                      session: session,
                      isActive: isActive,
                      isDark: isDark,
                      persona: PersonaThemes.of(session.personaName),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onSessionLoad(session);
                      },
                      onDelete: () {
                        HapticFeedback.mediumImpact();
                        provider.deleteSession(session.id);
                      },
                    );
                  },
                ),
              ),

              // ── Footer ──────────────────────────────────────────────
              _DrawerFooter(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Drawer Header ─────────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  final PersonaTheme persona;
  final bool isDark;
  const _DrawerHeader({required this.persona, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            persona.primary.withValues(alpha: 0.15),
            persona.secondary.withValues(alpha: 0.08),
          ]
              : [
            persona.primary.withValues(alpha: 0.08),
            persona.secondary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          // App logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [persona.primary, persona.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: persona.glowColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                )
              ],
            ),
            child: const Center(
              child: Text('💬', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [persona.primary, persona.secondary],
                ).createShader(bounds),
                child: const Text(
                  'Chattr',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Your AI companion',
                style: TextStyle(
                  fontSize: 12,
                  color:
                  isDark ? Colors.white38 : AppTheme.lightSubtext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── New Chat Button ───────────────────────────────────────────────────────────
class _NewChatButton extends StatelessWidget {
  final PersonaTheme persona;
  final bool isDark;
  final VoidCallback onTap;
  const _NewChatButton(
      {required this.persona,
        required this.isDark,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [persona.primary, persona.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: persona.glowColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'New Chat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session Tile ──────────────────────────────────────────────────────────────
class _SessionTile extends StatelessWidget {
  final ChatSession session;
  final bool isActive;
  final bool isDark;
  final PersonaTheme persona;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.isActive,
    required this.isDark,
    required this.persona,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('session_${session.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.red, size: 22),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? persona.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                : (isDark
                ? AppTheme.darkCard.withValues(alpha: 0.5)
                : AppTheme.lightCard),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? persona.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Persona avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      persona.primary
                          .withValues(alpha: isActive ? 1.0 : 0.5),
                      persona.secondary
                          .withValues(alpha: isActive ? 1.0 : 0.5),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(session.personaEmoji,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(width: 10),

              // Title + preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? persona.primary
                                  : (isDark
                                  ? Colors.white
                                  : AppTheme.lightText),
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        Text(
                          session.timeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? Colors.white24
                                : AppTheme.lightSubtext,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      session.preview,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white38
                            : AppTheme.lightSubtext,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    // Message count badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: persona.primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${session.messageCount} msgs',
                            style: TextStyle(
                              fontSize: 9,
                              color: persona.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            session.personaName,
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark
                                  ? Colors.white38
                                  : AppTheme.lightSubtext,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Active indicator
              if (isActive)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: persona.primary,
                    boxShadow: [
                      BoxShadow(
                        color: persona.glowColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty History ─────────────────────────────────────────────────────────────
class _EmptyHistory extends StatelessWidget {
  final bool isDark;
  const _EmptyHistory({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          const SizedBox(height: 12),
          Text(
            'No saved chats yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start chatting and save\nyour conversations here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Footer ─────────────────────────────────────────────────────────────
class _DrawerFooter extends StatelessWidget {
  final bool isDark;
  const _DrawerFooter({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          const SizedBox(width: 6),
          Text(
            'Swipe left on a chat to delete',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}