// lib/services/chat_service.dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ChatService extends ChangeNotifier {
  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  ChatService() {
    _initializeConversations();
  }

  void _initializeConversations() {
    _conversations = [
      Conversation(
        id: 'CONV001',
        participant1Id: 'PAT001',
        participant1Name: 'Jean Dupont',
        participant2Id: 'DOC001',
        participant2Name: 'Dr. Martin',
        messages: [
          ChatMessage(
            id: 'MSG001',
            conversationId: 'CONV001',
            senderId: 'DOC001',
            senderName: 'Dr. Martin',
            receiverId: 'PAT001',
            content: 'Bonjour, comment allez-vous ?',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<Conversation> getConversationsForUser(String userId) {
    return _conversations.where((conv) {
      return conv.participant1Id == userId || conv.participant2Id == userId;
    }).toList();
  }

  Conversation? getConversation(String conversationId) {
    try {
      return _conversations.firstWhere((conv) => conv.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  Conversation? getConversationBetween(String userId1, String userId2) {
    try {
      return _conversations.firstWhere((conv) {
        return (conv.participant1Id == userId1 && conv.participant2Id == userId2) ||
               (conv.participant1Id == userId2 && conv.participant2Id == userId1);
      });
    } catch (e) {
      return null;
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    // Chercher une conversation existante
    var conversation = getConversationBetween(senderId, receiverId);
    
    if (conversation == null) {
      // Créer une nouvelle conversation
      final senderName = _getUserName(senderId);
      final receiverName = _getUserName(receiverId);
      
      conversation = Conversation(
        id: 'CONV${DateTime.now().millisecondsSinceEpoch}',
        participant1Id: senderId,
        participant1Name: senderName,
        participant2Id: receiverId,
        participant2Name: receiverName,
        messages: [],
        lastMessageTime: DateTime.now(),
      );
      _conversations.add(conversation);
    }

    final newMessage = ChatMessage(
      id: 'MSG${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversation.id,
      senderId: senderId,
      senderName: _getUserName(senderId),
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );

    // Mettre à jour la conversation
    final index = _conversations.indexWhere((c) => c.id == conversation!.id);
    if (index != -1) {
      _conversations[index].addMessage(newMessage); // Utiliser la nouvelle méthode
      notifyListeners();
    }

    await Future.delayed(const Duration(milliseconds: 500));
  }

  int getUnreadCount(String userId) {
    int count = 0;
    for (var conv in _conversations) {
      if (conv.participant1Id == userId || conv.participant2Id == userId) {
        for (var msg in conv.messages) {
          if (msg.receiverId == userId && !msg.isRead) {
            count++;
          }
        }
      }
    }
    return count;
  }

  String _getUserName(String userId) {
    // À remplacer par votre logique de récupération des noms
    if (userId.startsWith('PAT')) return 'Patient $userId';
    if (userId.startsWith('DOC')) return 'Dr. $userId';
    return 'Utilisateur $userId';
  }

  // Méthode pour marquer les messages comme lus
  void markMessagesAsRead(String conversationId, String userId) {
    final conversation = getConversation(conversationId);
    if (conversation != null) {
      for (var message in conversation.messages) {
        if (message.receiverId == userId) {
          message.isRead = true;
        }
      }
      conversation.hasUnreadMessages = false;
      notifyListeners();
    }
  }
}