// lib/models/message.dart
// Enhanced Message model with emoji reactions & reply support

class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final String? replyTo;       // id of message being replied to
  final String? replyText;     // preview text of replied message
  List<String> reactions;      // emoji reactions list

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.replyTo,
    this.replyText,
    List<String>? reactions,
  }) : reactions = reactions ?? [];

  factory Message.fromUser(String text, {String? replyTo, String? replyText}) =>
      Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
        replyTo: replyTo,
        replyText: replyText,
      );

  factory Message.fromAI(String text) => Message(
    id: '${DateTime.now().millisecondsSinceEpoch}_ai',
    text: text,
    isUser: false,
    timestamp: DateTime.now(),
  );

  factory Message.error(String text) => Message(
    id: '${DateTime.now().millisecondsSinceEpoch}_err',
    text: text,
    isUser: false,
    timestamp: DateTime.now(),
    isError: true,
  );

  Message copyWith({List<String>? reactions}) => Message(
    id: id,
    text: text,
    isUser: isUser,
    timestamp: timestamp,
    isError: isError,
    replyTo: replyTo,
    replyText: replyText,
    reactions: reactions ?? this.reactions,
  );
}