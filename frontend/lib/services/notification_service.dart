// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import '../models/notification.dart';

class NotificationService extends ChangeNotifier {
  List<MedicalNotification> _notifications = [];

  NotificationService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _notifications = [
      MedicalNotification(
        id: 'NOTIF001',
        userId: 'PAT001',
        title: 'Rendez-vous confirmé',
        message: 'Votre rendez-vous avec le Dr. Martin est confirmé pour demain à 14h',
        type: 'appointment',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.calendar_today,
        color: Colors.blue,
      ),
      MedicalNotification(
        id: 'NOTIF002',
        userId: 'PAT001',
        title: 'Résultats d\'analyse disponibles',
        message: 'Vos résultats de sang sont maintenant disponibles dans votre dossier',
        type: 'result',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.medical_services,
        color: Colors.green,
      ),
      MedicalNotification(
        id: 'NOTIF003',
        userId: 'PAT001',
        title: 'Nouveau message',
        message: 'Le Dr. Martin vous a envoyé un message',
        type: 'message',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        icon: Icons.message,
        color: Colors.purple,
      ),
      MedicalNotification(
        id: 'NOTIF004',
        userId: 'PAT001',
        title: 'Rappel de vaccination',
        message: 'Votre prochaine vaccination est prévue dans 2 mois',
        type: 'alert',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        icon: Icons.vaccines,
        color: Colors.orange,
      ),
    ];
  }

  List<MedicalNotification> get notifications => _notifications;

  int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  List<MedicalNotification> getNotificationsForUser(String userId) {
    return _notifications.where((n) => n.userId == userId).toList();
  }

  void addNotification(MedicalNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Méthodes utilitaires pour créer des notifications
  void createAppointmentNotification({
    required String userId,
    required String patientName,
    required DateTime appointmentTime,
  }) {
    final notification = MedicalNotification(
      id: 'APP_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: 'Nouveau rendez-vous',
      message: 'Rendez-vous avec $patientName le ${appointmentTime.day}/${appointmentTime.month} à ${appointmentTime.hour}:${appointmentTime.minute}',
      type: 'appointment',
      timestamp: DateTime.now(),
      icon: Icons.calendar_today,
      color: Colors.blue,
    );
    addNotification(notification);
  }

  void createTestResultNotification({
    required String userId,
    required String testType,
  }) {
    final notification = MedicalNotification(
      id: 'RES_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: 'Résultats disponibles',
      message: 'Vos résultats de $testType sont disponibles',
      type: 'result',
      timestamp: DateTime.now(),
      icon: Icons.medical_services,
      color: Colors.green,
    );
    addNotification(notification);
  }
}