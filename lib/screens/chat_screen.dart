// lib/screens/chat_screen.dart
// ✨ Upgraded with: persona switcher, voice input button, reply bar,
//    animated app bar, beautiful empty state, neon input bar

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../theme/app_theme.dart';
import '../main.dart';
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

  String _currentPersona = 'Assistant';
  bool _isRecording = false; // mic stub for Week 2

  late AnimationController _appBarAnimController;
  late Animation<double> _appBarFade;

  static const Map<String, Map<String, String>> _personas = {
    'Assistant': {'emoji': '🤖', 'subtitle': 'General AI Assistant'},
    'Tutor': {'emoji': '👨‍🏫', 'subtitle': 'Learn anything, step by step'},
    'Chef': {'emoji': '👨‍🍳', 'subtitle': 'Recipes & cooking tips'},
    'Fitness': {'emoji': '💪', 'subtitle': 'Workouts & nutrition'},
  };

  @override
  void initState() {
    super.initState();
    _appBarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _appBarAnimController, curve: Curves.easeOut),
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
    Future.delayed(
        const Duration(milliseconds: 100), _scrollToBottom);
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

  void _switchPersona() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
            ..._personas.entries.map((entry) {
              final isSelected = _currentPersona == entry.key;
              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [AppTheme.neonBlue, AppTheme.neonPurple]
                          : [
                        isDark
                            ? AppTheme.darkBorder
                            : AppTheme.lightCard,
                        isDark
                            ? AppTheme.darkBorder
                            : AppTheme.lightCard,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(entry.value['emoji']!,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                title: Text(
                  entry.key,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.lightText,
                  ),
                ),
                subtitle: Text(
                  entry.value['subtitle']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : AppTheme.lightSubtext,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded,
                    color: isDark
                        ? AppTheme.neonBlue
                        : AppTheme.neonPurple)
                    : null,
                onTap: () {
                  setState(() => _currentPersona = entry.key);
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 12),
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
          backgroundColor:
          isDark ? AppTheme.darkBg : AppTheme.lightBg,
          appBar: _buildAppBar(provider, isDark),
          body: Column(
            children: [
              Expanded(child: _buildMessageList(provider, isDark)),
              if (provider.replyingTo != null)
                _ReplyBar(
                  message: provider.replyingTo!,
                  isDark: isDark,
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
    final persona = _personas[_currentPersona]!;
    return AppBar(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      elevation: 0,
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
            children: [
              // Persona avatar with glow
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                      AppTheme.neonBlue.withValues(alpha:0.3),
                      AppTheme.neonPurple.withValues(alpha:0.3),
                    ]
                        : [
                      const Color(0xFFEDE9FE),
                      const Color(0xFFDDD6FE),
                    ],
                  ),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.neonBlue.withValues(alpha:0.5)
                        : AppTheme.neonPurple.withValues(alpha:0.4),
                    width: 1.5,
                  ),
                  boxShadow: isDark
                      ? [
                    BoxShadow(
                      color: AppTheme.neonBlue.withValues(alpha:0.2),
                      blurRadius: 8,
                    )
                  ]
                      : [],
                ),
                child: Center(
                    child: Text(persona['emoji']!,
                        style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _currentPersona,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: isDark
                              ? Colors.white38
                              : AppTheme.lightSubtext),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: provider.isLoading
                              ? Colors.orange
                              : const Color(0xFF22C55E),
                          boxShadow: [
                            BoxShadow(
                              color: (provider.isLoading
                                  ? Colors.orange
                                  : const Color(0xFF22C55E))
                                  .withValues(alpha:0.5),
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        provider.isLoading ? 'Thinking…' : 'Online',
                        style: TextStyle(
                          fontSize: 11,
                          color: provider.isLoading
                              ? Colors.orange
                              : const Color(0xFF22C55E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Theme toggle
        IconButton(
          icon: Icon(
            isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: isDark ? AppTheme.neonBlue : AppTheme.neonPurple,
          ),
          onPressed: () =>
              context.read<ThemeNotifier>().toggle(),
        ),
        // Clear chat
        IconButton(
          icon: Icon(
            Icons.delete_outline_rounded,
            color: isDark ? Colors.white38 : AppTheme.lightSubtext,
          ),
          onPressed: provider.hasMessages
              ? () => _confirmClear(provider)
              : null,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Message List ──────────────────────────────────────────────────────────
  Widget _buildMessageList(ChatProvider provider, bool isDark) {
    if (!provider.hasMessages) return _EmptyState(isDark: isDark);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount:
      provider.messages.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (provider.isLoading && index == provider.messages.length) {
          return TypingIndicator(persona: _currentPersona);
        }
        return ChatBubble(
          message: provider.messages[index],
          persona: _currentPersona,
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
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
          ),
        ),
        child: Row(
          children: [
            // ── Mic Button ───────────────────────────────────────────
            GestureDetector(
              onTap: () {
                setState(() => _isRecording = !_isRecording);
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isRecording
                        ? '🎤 Recording... (coming in Week 2)'
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
                      ? Colors.red.withValues(alpha:0.15)
                      : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                  border: Border.all(
                    color: _isRecording
                        ? Colors.red
                        : (isDark
                        ? AppTheme.darkBorder
                        : AppTheme.lightBorder),
                  ),
                ),
                child: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
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

            // ── Text Field ───────────────────────────────────────────
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
                  hintText: 'Message $_currentPersona…',
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
                      color: isDark
                          ? AppTheme.neonBlue
                          : AppTheme.neonPurple,
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

            // ── Send Button ──────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: child,
              ),
              child: provider.isLoading
                  ? Container(
                key: const ValueKey('loading'),
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: isDark
                      ? AppTheme.neonBlue
                      : AppTheme.neonPurple,
                ),
              )
                  : GestureDetector(
                key: const ValueKey('send'),
                onTap: () => _sendMessage(provider),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                        AppTheme.neonBlue,
                        AppTheme.neonPurple,
                      ]
                          : [
                        AppTheme.neonPurple,
                        const Color(0xFF5B21B6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark
                            ? AppTheme.neonBlue
                            : AppTheme.neonPurple)
                            .withValues(alpha:0.4),
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

  void _confirmClear(ChatProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('All messages will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              provider.clearChat();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ── Reply Bar ─────────────────────────────────────────────────────────────────
class _ReplyBar extends StatelessWidget {
  final dynamic message;
  final bool isDark;
  final VoidCallback onCancel;
  const _ReplyBar(
      {required this.message,
        required this.isDark,
        required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark
          ? AppTheme.darkSurface
          : AppTheme.lightCard,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.neonBlue : AppTheme.neonPurple,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${message.isUser ? 'yourself' : 'AI'}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.neonBlue : AppTheme.neonPurple,
                  ),
                ),
                Text(
                  message.text.length > 50
                      ? '${message.text.substring(0, 50)}…'
                      : message.text,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : AppTheme.lightSubtext,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                size: 18,
                color: isDark ? Colors.white38 : AppTheme.lightSubtext),
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
  const _EmptyState({required this.isDark});

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _float,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _float.value),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: widget.isDark
                        ? [
                      AppTheme.neonBlue.withValues(alpha:0.2),
                      AppTheme.neonPurple.withValues(alpha:0.2),
                    ]
                        : [
                      const Color(0xFFEDE9FE),
                      const Color(0xFFDDD6FE),
                    ],
                  ),
                  border: Border.all(
                    color: widget.isDark
                        ? AppTheme.neonBlue.withValues(alpha:0.3)
                        : AppTheme.neonPurple.withValues(alpha:0.3),
                    width: 2,
                  ),
                  boxShadow: widget.isDark
                      ? [
                    BoxShadow(
                      color: AppTheme.neonBlue.withValues(alpha:0.15),
                      blurRadius: 24,
                    )
                  ]
                      : [
                    BoxShadow(
                      color: AppTheme.neonPurple.withValues(alpha:0.1),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 44))),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: widget.isDark ? Colors.white : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a message or tap the mic to begin',
            style: TextStyle(
              fontSize: 14,
              color: widget.isDark ? Colors.white38 : AppTheme.lightSubtext,
            ),
          ),
          const SizedBox(height: 32),
          // Quick suggestion chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['👋 Say hello', '💡 Get ideas', '❓ Ask anything']
                .map((label) => _SuggestionChip(
                label: label, isDark: widget.isDark))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SuggestionChip({required this.label, required this.isDark});

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
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
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