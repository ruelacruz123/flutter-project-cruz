import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/mock_database_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthService _authService = MockAuthService();
  DatabaseService _dbService = MockDatabaseService();
  UserSession? _currentUser;
  bool _isLoading = true;
  bool _isMockMode = true;
  String? _errorMessage;

  AuthProvider() {
    _initAuth();
  }

  AuthService get authService => _authService;
  DatabaseService get dbService => _dbService;
  UserSession? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isMockMode => _isMockMode;
  String? get errorMessage => _errorMessage;

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();


    try {
      // Check if Firebase is configured / initialized
      // We will check Firebase apps list first to avoid double initialization exceptions
      if (Firebase.apps.isNotEmpty) {
        _useFirebase();
      } else {
        try {
          await Firebase.initializeApp();
          _useFirebase();
        } catch (e) {
          debugPrint('Firebase not initialized. Defaulting to Mock Offline Mode. Info: $e');
          _useMock();
        }
      }
    } catch (e) {
      debugPrint('Error setting up authentication services: $e');
      _useMock();
    }

    // Auto-login as the default student
    try {
      _currentUser = await _authService.signIn('ruela@student.com', '');
    } catch (_) {
      // Fallback: create a default session directly
      _currentUser = UserSession(
        uid: 'student1',
        email: 'ruela@student.com',
        role: 'student',
        studentId: 'student1',
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void _useFirebase() {
    _authService = FirebaseAuthService();
    _dbService = FirestoreService();
    _isMockMode = false;
    debugPrint('Running in Firebase Mode');
  }

  void _useMock() {
    _authService = MockAuthService();
    _dbService = MockDatabaseService();
    _isMockMode = true;
    debugPrint('Running in Mock Mode');
  }

  // Force toggle mock mode for testing/demo purposes
  void toggleMockMode(bool enabled) {
    if (enabled) {
      _useMock();
    } else {
      try {
        _useFirebase();
      } catch (e) {
        _errorMessage = 'Could not switch to Firebase. Verify your platform configuration. Error: $e';
        notifyListeners();
        return;
      }
    }
    _errorMessage = null;
    _currentUser = null;
    _isLoading = false;
    // Re-subscribe to new service auth state changes
    _authService.onAuthStateChanged.listen((session) {
      _currentUser = session;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
