import 'package:flutter/material.dart';

class MedicalNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // appointment, result, alert, message, system
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  bool isRead;

  MedicalNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return 'Le ${timestamp.day}/${timestamp.month}';
  }
}