import 'package:intl/intl.dart';

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  bool isRead; 

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (today == messageDay) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (today.subtract(const Duration(days: 1)) == messageDay) {
      return 'Hier ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('dd/MM HH:mm').format(timestamp);
    }
  }
}