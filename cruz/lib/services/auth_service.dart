import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSession {
  final String uid;
  final String email;
  final String role; // 'teacher' or 'student'
  final String? studentId; // If student, the corresponding student document ID

  UserSession({
    required this.uid,
    required this.email,
    required this.role,
    this.studentId,
  });
}

abstract class AuthService {
  Stream<UserSession?> get onAuthStateChanged;
  Future<UserSession> signIn(String email, String password);
  Future<void> signOut();
  bool get isMockMode;
}

class MockAuthService implements AuthService {
  static final StreamController<UserSession?> _controller = StreamController<UserSession?>.broadcast();
  static UserSession? _currentUser;

  @override
  Stream<UserSession?> get onAuthStateChanged {
    // Emit initial status
    Timer(Duration.zero, () => _controller.add(_currentUser));
    return _controller.stream;
  }

  @override
  Future<UserSession> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network latency

    final normalizedEmail = email.trim().toLowerCase();
    UserSession session;

    if (normalizedEmail == 'ruela@student.com') {
      session = UserSession(
        uid: 'student1',
        email: 'ruela@student.com',
        role: 'student',
        studentId: 'student1',
      );
    } else if (normalizedEmail == 'john@student.com') {
      session = UserSession(
        uid: 'student2',
        email: 'john@student.com',
        role: 'student',
        studentId: 'student2',
      );
    } else if (normalizedEmail.contains('student')) {
      // General student simulation
      final name = normalizedEmail.split('@').first;
      session = UserSession(
        uid: name,
        email: normalizedEmail,
        role: 'student',
        studentId: name,
      );
    } else {
      throw fb.FirebaseAuthException(
        code: 'user-not-found',
        message: 'Invalid credentials for Mock Mode. Use ruela@student.com or john@student.com',
      );
    }

    _currentUser = session;
    _controller.add(_currentUser);
    return session;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  bool get isMockMode => true;
}

class FirebaseAuthService implements AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final StreamController<UserSession?> _controller = StreamController<UserSession?>.broadcast();

  FirebaseAuthService() {
    _auth.authStateChanges().listen((fb.User? user) async {
      if (user == null) {
        _controller.add(null);
      } else {
        try {
          final userDoc = await _db.collection('users').doc(user.uid).get();
          String role = 'student';
          String? studentId;

          if (userDoc.exists) {
            role = userDoc.data()?['role'] ?? 'student';
            studentId = userDoc.data()?['student_id'];
          }

          _controller.add(UserSession(
            uid: user.uid,
            email: user.email ?? '',
            role: role,
            studentId: studentId ?? (role == 'student' ? user.uid : null),
          ));
        } catch (e) {
          // If Firestore fails, default to student role
          _controller.add(UserSession(
            uid: user.uid,
            email: user.email ?? '',
            role: 'student',
            studentId: user.uid,
          ));
        }
      }
    });
  }

  @override
  Stream<UserSession?> get onAuthStateChanged => _controller.stream;

  @override
  Future<UserSession> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    final userDoc = await _db.collection('users').doc(user.uid).get();
    String role = 'student';
    String? studentId;

    if (userDoc.exists) {
      role = userDoc.data()?['role'] ?? 'student';
      studentId = userDoc.data()?['student_id'];
    }

    return UserSession(
      uid: user.uid,
      email: user.email ?? '',
      role: role,
      studentId: studentId ?? (role == 'student' ? user.uid : null),
    );
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  bool get isMockMode => false;
}
