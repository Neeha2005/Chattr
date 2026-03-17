// lib/widgets/chat_bubble.dart
// ✨ Upgraded: animated entrance, emoji reactions, copy on long press,
//    swipe-to-reply, AI persona avatars, wow-factor design

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

// ── Available emoji reactions ─────────────────────────────────────────────
const List<String> kReactionEmojis = ['👍', '❤️', '😂', '😮', '🔥', '👏'];

// ── AI Persona Avatars ────────────────────────────────────────────────────
const Map<String, String> kPersonaAvatars = {
  'Assistant': '🤖',
  'Tutor': '👨‍🏫',
  'Chef': '👨‍🍳',
  'Fitness': '💪',
};

class ChatBubble extends StatefulWidget {
  final Message message;
  final String persona;

  const ChatBubble({
    super.key,
    required this.message,
    this.persona = 'Assistant',
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Long Press → Copy + Reactions ────────────────────────────────────────
  void _onLongPress(BuildContext context) {
    HapticFeedback.mediumImpact();
    _showOptionsSheet(context);
  }

  void _showOptionsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<ChatProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Reaction Row ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: kReactionEmojis.map((emoji) {
                  final hasReaction =
                  widget.message.reactions.contains(emoji);
                  return GestureDetector(
                    onTap: () {
                      provider.addReaction(widget.message.id, emoji);
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasReaction
                            ? (isDark
                            ? AppTheme.neonBlue.withValues(alpha:0.2)
                            : AppTheme.neonPurple.withValues(alpha:0.1))
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Divider(height: 1),

            // ── Action Buttons ─────────────────────────────────────────
            _ActionTile(
              icon: Icons.copy_rounded,
              label: 'Copy message',
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: widget.message.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.reply_rounded,
              label: 'Reply',
              onTap: () {
                provider.setReplyTo(widget.message);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = widget.message.isUser;
    final isError = widget.message.isError;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Dismissible(
            key: Key('dismiss_${widget.message.id}'),
            direction: isUser
                ? DismissDirection.endToStart
                : DismissDirection.startToEnd,
            confirmDismiss: (_) async {
              context.read<ChatProvider>().setReplyTo(widget.message);
              HapticFeedback.lightImpact();
              return false; // don't actually dismiss
            },
            background: _SwipeReplyBackground(isUser: isUser),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: Row(
                mainAxisAlignment: isUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isUser) ...[
                    _PersonaAvatar(
                        persona: widget.persona, isDark: isDark),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        // ── Reply Preview ───────────────────────────
                        if (widget.message.replyText != null)
                          _ReplyPreview(
                            text: widget.message.replyText!,
                            isUser: isUser,
                            isDark: isDark,
                          ),

                        // ── Bubble ──────────────────────────────────
                        GestureDetector(
                          onLongPress: () => _onLongPress(context),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                              MediaQuery.of(context).size.width * 0.72,
                            ),
                            decoration: BoxDecoration(
                              gradient: isError
                                  ? null
                                  : isUser
                                  ? (isDark
                                  ? const LinearGradient(
                                colors: [
                                  Color(0xFF00D4FF),
                                  Color(0xFF7C3AED),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : const LinearGradient(
                                colors: [
                                  Color(0xFF7C3AED),
                                  Color(0xFF5B21B6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ))
                                  : null,
                              color: isError
                                  ? Colors.red.withValues(alpha:0.15)
                                  : isUser
                                  ? null
                                  : (isDark
                                  ? AppTheme.darkCard
                                  : Colors.white),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft:
                                Radius.circular(isUser ? 20 : 4),
                                bottomRight:
                                Radius.circular(isUser ? 4 : 20),
                              ),
                              border: !isUser
                                  ? Border.all(
                                color: isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.lightBorder,
                                width: 1,
                              )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: isUser
                                      ? (isDark
                                      ? AppTheme.neonBlue
                                      : AppTheme.neonPurple)
                                      .withValues(alpha:0.25)
                                      : Colors.black.withValues(alpha:0.06),
                                  blurRadius: isUser ? 12 : 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 11),
                            child: Text(
                              widget.message.text,
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : (isDark
                                    ? Colors.white
                                    : AppTheme.lightText),
                                fontSize: 15,
                                height: 1.45,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),

                        // ── Reactions Row ───────────────────────────
                        if (widget.message.reactions.isNotEmpty)
                          _ReactionsRow(
                            reactions: widget.message.reactions,
                            isDark: isDark,
                          ),

                        // ── Timestamp ────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 4, left: 4, right: 4),
                          child: Text(
                            _formatTime(widget.message.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white30
                                  : AppTheme.lightSubtext,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUser) ...[
                    const SizedBox(width: 8),
                    _UserAvatar(isDark: isDark),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

// ── Persona Avatar ────────────────────────────────────────────────────────────
class _PersonaAvatar extends StatelessWidget {
  final String persona;
  final bool isDark;
  const _PersonaAvatar({required this.persona, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final emoji = kPersonaAvatars[persona] ?? '🤖';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.neonBlue.withValues(alpha:0.3), AppTheme.neonPurple.withValues(alpha:0.3)]
              : [const Color(0xFFEDE9FE), const Color(0xFFDDD6FE)],
        ),
        border: Border.all(
          color: isDark ? AppTheme.neonBlue.withValues(alpha:0.4) : AppTheme.neonPurple.withValues(alpha:0.3),
          width: 1.5,
        ),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
    );
  }
}

// ── User Avatar ───────────────────────────────────────────────────────────────
class _UserAvatar extends StatelessWidget {
  final bool isDark;
  const _UserAvatar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.neonPurple, AppTheme.neonBlue]
              : [const Color(0xFF7C3AED), const Color(0xFF5B21B6)],
        ),
      ),
      child: const Center(
          child: Text('👤', style: TextStyle(fontSize: 18))),
    );
  }
}

// ── Swipe Reply Background ────────────────────────────────────────────────────
class _SwipeReplyBackground extends StatelessWidget {
  final bool isUser;
  const _SwipeReplyBackground({required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.neonPurple.withValues(alpha:0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.reply_rounded,
            color: AppTheme.neonPurple, size: 22),
      ),
    );
  }
}

// ── Reply Preview Banner ──────────────────────────────────────────────────────
class _ReplyPreview extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isDark;
  const _ReplyPreview(
      {required this.text, required this.isUser, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha:0.06)
            : Colors.black.withValues(alpha:0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isUser ? AppTheme.neonBlue : AppTheme.neonPurple,
            width: 3,
          ),
        ),
      ),
      child: Text(
        text.length > 60 ? '${text.substring(0, 60)}…' : text,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white54 : AppTheme.lightSubtext,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

// ── Reactions Row ─────────────────────────────────────────────────────────────
class _ReactionsRow extends StatelessWidget {
  final List<String> reactions;
  final bool isDark;
  const _ReactionsRow({required this.reactions, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: reactions
            .toSet()
            .map((emoji) => Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkCard
                : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppTheme.darkBorder
                  : AppTheme.lightBorder,
            ),
          ),
          child: Text(emoji,
              style: const TextStyle(fontSize: 14)),
        ))
            .toList(),
      ),
    );
  }
}

// ── Action Tile (bottom sheet) ────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.darkBorder
              : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20,
            color: isDark ? Colors.white70 : AppTheme.lightText),
      ),
      title: Text(label,
          style: TextStyle(
              color: isDark ? Colors.white : AppTheme.lightText,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────────
class TypingIndicator extends StatefulWidget {
  final String persona;
  const TypingIndicator({super.key, this.persona = 'Assistant'});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotAnims;

  @override
  void initState() {
    super.initState();
    _dotControllers = List.generate(
      3,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _dotAnims = _dotControllers
        .map((c) => Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: c, curve: Curves.easeInOut),
    ))
        .toList();

    // staggered bounce
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _dotControllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _dotControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _PersonaAvatar(persona: widget.persona, isDark: isDark),
          const SizedBox(width: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _dotAnims[i],
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _dotAnims[i].value),
                    child: Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppTheme.neonBlue
                            : AppTheme.neonPurple,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}