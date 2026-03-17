// lib/providers/chat_provider.dart
// ✨ Multi-session support — save current chat, start new one,
//    switch between past conversations

import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/chat_session.dart';

class ChatProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  final List<Message> _messages = [];
  final List<ChatSession> _sessions = [];
  bool _isLoading = false;
  String? _errorMessage;
  Message? _replyingTo;
  String? _activeSessionId;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<Message> get messages => List.unmodifiable(_messages);
  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;
  Message? get replyingTo => _replyingTo;
  String? get activeSessionId => _activeSessionId;

  // ── Send Message ───────────────────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _clearError();

    final userMsg = Message.fromUser(
      text.trim(),
      replyTo: _replyingTo?.id,
      replyText: _replyingTo?.text,
    );
    _addMessage(userMsg);
    _replyingTo = null;
    notifyListeners();

    _setLoading(true);

    // ── WEEK 1 STUB ─────────────────────────────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 1400));
    _addMessage(Message.fromAI(
      'Hello! I\'m your AI assistant. Week 2 brings real Claude API responses!',
    ));
    // ── END STUB ────────────────────────────────────────────────────────────

    _setLoading(false);
  }

  // ── Save current chat & start new ─────────────────────────────────────────
  void saveAndStartNew({
    required String personaName,
    required String personaEmoji,
  }) {
    if (_messages.isNotEmpty) {
      _saveCurrentSession(
        personaName: personaName,
        personaEmoji: personaEmoji,
      );
    }
    _startFreshChat();
  }

  // ── Load a past session ────────────────────────────────────────────────────
  void loadSession(ChatSession session) {
    _messages.clear();
    _messages.addAll(session.messages);
    _activeSessionId = session.id;
    _replyingTo = null;
    _clearError();
    notifyListeners();
  }

  // ── Delete a session ───────────────────────────────────────────────────────
  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_activeSessionId == sessionId) {
      _startFreshChat();
    }
    notifyListeners();
  }

  // ── Clear current chat (no save) ──────────────────────────────────────────
  void clearChat() {
    _messages.clear();
    _activeSessionId = null;
    _replyingTo = null;
    _clearError();
    notifyListeners();
  }

  // ── Emoji Reactions ────────────────────────────────────────────────────────
  void addReaction(String messageId, String emoji) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;
    final msg = _messages[index];
    final updated = List<String>.from(msg.reactions);
    if (updated.contains(emoji)) {
      updated.remove(emoji);
    } else {
      updated.add(emoji);
    }
    _messages[index] = msg.copyWith(reactions: updated);
    notifyListeners();
  }

  // ── Reply ──────────────────────────────────────────────────────────────────
  void setReplyTo(Message message) {
    _replyingTo = message;
    notifyListeners();
  }

  void cancelReply() {
    _replyingTo = null;
    notifyListeners();
  }

  // ── Private ────────────────────────────────────────────────────────────────
  void _saveCurrentSession({
    required String personaName,
    required String personaEmoji,
  }) {
    if (_activeSessionId != null) {
      final idx =
      _sessions.indexWhere((s) => s.id == _activeSessionId);
      if (idx != -1) {
        final old = _sessions[idx];
        _sessions[idx] = ChatSession(
          id: old.id,
          title: old.title,
          personaName: personaName,
          personaEmoji: personaEmoji,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
          messages: List.from(_messages),
        );
        return;
      }
    }

    final session = ChatSession.create(
      personaName: personaName,
      personaEmoji: personaEmoji,
      messages: _messages,
    );
    _sessions.insert(0, session);
  }

  void _startFreshChat() {
    _messages.clear();
    _activeSessionId = null;
    _replyingTo = null;
    notifyListeners();
  }

  void _addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}