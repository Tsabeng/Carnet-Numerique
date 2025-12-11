// lib/models/conversation.dart
import 'message.dart';

class Conversation {
  final String id;
  final String participant1Id;
  final String participant1Name;
  final String participant2Id;
  final String participant2Name;
  final List<ChatMessage> messages;
  DateTime lastMessageTime; // Retirer final
  bool hasUnreadMessages;

  Conversation({
    required this.id,
    required this.participant1Id,
    required this.participant1Name,
    required this.participant2Id,
    required this.participant2Name,
    required this.messages,
    required this.lastMessageTime,
    this.hasUnreadMessages = false,
  });

  String getOtherParticipant(String userId) {
    return participant1Id == userId ? participant2Id : participant1Id;
  }

  String getOtherParticipantName(String userId) {
    return participant1Id == userId ? participant2Name : participant1Name;
  }

  // Méthode pour ajouter un message et mettre à jour le timestamp
  void addMessage(ChatMessage message) {
    messages.add(message);
    lastMessageTime = DateTime.now();
    hasUnreadMessages = true;
  }
}