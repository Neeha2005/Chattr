// lib/models/chat_session.dart
// Represents a single saved conversation

import 'message.dart';

class ChatSession {
  final String id;
  final String title;
  final String personaName;
  final String personaEmoji;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.personaName,
    required this.personaEmoji,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  // Auto-generate title from first user message
  factory ChatSession.create({
    required String personaName,
    required String personaEmoji,
    required List<Message> messages,
  }) {
    final now = DateTime.now();
    final firstUserMsg = messages.firstWhere(
          (m) => m.isUser,
      orElse: () => Message.fromUser('New Chat'),
    );

    // Truncate title to 40 chars
    final rawTitle = firstUserMsg.text.trim();
    final title = rawTitle.length > 40
        ? '${rawTitle.substring(0, 40)}…'
        : rawTitle;

    return ChatSession(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      personaName: personaName,
      personaEmoji: personaEmoji,
      createdAt: now,
      updatedAt: now,
      messages: List.from(messages),
    );
  }

  // Preview text shown in drawer
  String get preview {
    if (messages.isEmpty) return 'No messages';
    final last = messages.last;
    final text = last.text.trim();
    return text.length > 50 ? '${text.substring(0, 50)}…' : text;
  }

  int get messageCount => messages.length;

  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = [
      'Jan','Feb','Mar','Apr','May',
      'Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[updatedAt.month - 1]} ${updatedAt.day}';
  }
}