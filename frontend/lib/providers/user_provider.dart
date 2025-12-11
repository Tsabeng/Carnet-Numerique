import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _currentUserId;
  String? _currentUserRole;
  String? _currentUserName;
  
  String? get currentUserId => _currentUserId;
  String? get currentUserRole => _currentUserRole;
  String? get currentUserName => _currentUserName;
  
  // Ajoutez ce getter
  Map<String, String>? get currentUser {
    if (_currentUserId == null) return null;
    return {
      'id': _currentUserId!,
      'role': _currentUserRole!,
      'name': _currentUserName ?? '',
    };
  }
  
  bool get isLoggedIn => _currentUserId != null;
  bool get isDoctor => _currentUserRole == 'doctor';
  bool get isPatient => _currentUserRole == 'patient';
  
  void loginAsDoctor(String userId, String userName) {
    _currentUserId = userId;
    _currentUserRole = 'doctor';
    _currentUserName = userName;
    notifyListeners();
  }
  
  void loginAsPatient(String userId, String userName) {
    _currentUserId = userId;
    _currentUserRole = 'patient';
    _currentUserName = userName;
    notifyListeners();
  }
  
  void logout() {
    _currentUserId = null;
    _currentUserRole = null;
    _currentUserName = null;
    notifyListeners();
  }
}