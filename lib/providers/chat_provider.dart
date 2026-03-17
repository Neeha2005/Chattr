// lib/providers/chat_provider.dart
// Enhanced with reactions, reply, and swipe-to-reply support

import 'package:flutter/foundation.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  Message? _replyingTo; // currently selected reply target

  // ── Getters ───────────────────────────────────────────────────────────────
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;
  Message? get replyingTo => _replyingTo;

  // ── Send Message ──────────────────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _clearError();

    final userMsg = Message.fromUser(
      text.trim(),
      replyTo: _replyingTo?.id,
      replyText: _replyingTo?.text,
    );
    _addMessage(userMsg);
    _replyingTo = null; // clear reply after sending
    notifyListeners();

    _setLoading(true);

    // ── WEEK 1 STUB — replace in Week 2 ──────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 1400));
    _addMessage(Message.fromAI(
      '✨ Hello! I\'m your AI assistant. Week 2 brings real Claude API responses!',
    ));
    // ── END STUB ─────────────────────────────────────────────────────────

    _setLoading(false);
  }

  // ── Emoji Reactions ───────────────────────────────────────────────────────
  void addReaction(String messageId, String emoji) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final msg = _messages[index];
    final updatedReactions = List<String>.from(msg.reactions);

    if (updatedReactions.contains(emoji)) {
      updatedReactions.remove(emoji); // toggle off
    } else {
      updatedReactions.add(emoji);
    }

    _messages[index] = msg.copyWith(reactions: updatedReactions);
    notifyListeners();
  }

  // ── Reply ─────────────────────────────────────────────────────────────────
  void setReplyTo(Message message) {
    _replyingTo = message;
    notifyListeners();
  }

  void cancelReply() {
    _replyingTo = null;
    notifyListeners();
  }

  // ── Clear ─────────────────────────────────────────────────────────────────
  void clearChat() {
    _messages.clear();
    _replyingTo = null;
    _clearError();
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────────
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

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}