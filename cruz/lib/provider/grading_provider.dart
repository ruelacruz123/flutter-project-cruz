import 'dart:async';
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/quiz.dart';
import '../models/exam.dart';
import '../models/activity.dart';
import '../models/attendance.dart';
import '../models/oral.dart';
import '../models/project.dart';
import '../services/database_service.dart';

class GradingProvider extends ChangeNotifier {
  DatabaseService? _dbService;


  List<Quiz> _quizzes = [];
  List<Exam> _exams = [];
  List<Activity> _activities = [];
  List<Attendance> _attendance = [];
  List<Oral> _orals = [];
  List<Project> _projects = [];


  bool _isLoadingDetails = false;
  String? _selectedStudentId;

  // Subscriptions

  StreamSubscription? _quizzesSub;
  StreamSubscription? _examsSub;
  StreamSubscription? _activitiesSub;
  StreamSubscription? _attendanceSub;
  StreamSubscription? _oralsSub;
  StreamSubscription? _projectsSub;


  List<Quiz> get quizzes => _quizzes;
  List<Exam> get exams => _exams;
  List<Activity> get activities => _activities;
  List<Attendance> get attendance => _attendance;
  List<Oral> get orals => _orals;
  List<Project> get projects => _projects;


  bool get isLoadingDetails => _isLoadingDetails;
  String? get selectedStudentId => _selectedStudentId;

  void updateService(DatabaseService service, String? role, String? studentId) {
    _dbService = service;
    _cancelSubscriptions();

    if (studentId != null) {
      selectStudent(studentId);
    }
  }

  void selectStudent(String studentId) {
    if (_dbService == null) return;
    if (_selectedStudentId == studentId) return;

    _selectedStudentId = studentId;
    _isLoadingDetails = true;
    notifyListeners();

    _cancelDetailSubscriptions();

    // Bind to the new student's streams
    _quizzesSub = _dbService!.getQuizzes(studentId).listen((data) {
      _quizzes = data;
      _checkLoadingFinished();
    });

    _examsSub = _dbService!.getExams(studentId).listen((data) {
      _exams = data;
      _checkLoadingFinished();
    });

    _activitiesSub = _dbService!.getActivities(studentId).listen((data) {
      _activities = data;
      _checkLoadingFinished();
    });

    _attendanceSub = _dbService!.getAttendance(studentId).listen((data) {
      _attendance = data;
      _checkLoadingFinished();
    });

    _oralsSub = _dbService!.getOrals(studentId).listen((data) {
      _orals = data;
      _checkLoadingFinished();
    });

    _projectsSub = _dbService!.getProjects(studentId).listen((data) {
      _projects = data;
      _checkLoadingFinished();
    });
  }

  void _checkLoadingFinished() {
    _isLoadingDetails = false;
    notifyListeners();
  }

  void _cancelSubscriptions() {
    _cancelDetailSubscriptions();
    _selectedStudentId = null;
  }

  void _cancelDetailSubscriptions() {
    _quizzesSub?.cancel();
    _examsSub?.cancel();
    _activitiesSub?.cancel();
    _attendanceSub?.cancel();
    _oralsSub?.cancel();
    _projectsSub?.cancel();

    _quizzes = [];
    _exams = [];
    _activities = [];
    _attendance = [];
    _orals = [];
    _projects = [];
  }

  // Double check and calculate performance averages
  double get quizAverage {
    if (_quizzes.isEmpty) return 0.0;
    int totalScore = 0;
    int totalItems = 0;
    for (var quiz in _quizzes) {
      totalScore += quiz.score;
      totalItems += quiz.numberOfItems;
    }
    return totalItems == 0 ? 0.0 : (totalScore / totalItems) * 100.0;
  }

  double get examAverage {
    if (_exams.isEmpty) return 0.0;
    int totalScore = 0;
    int totalItems = 0;
    for (var exam in _exams) {
      totalScore += exam.score;
      totalItems += exam.numberOfItems;
    }
    return totalItems == 0 ? 0.0 : (totalScore / totalItems) * 100.0;
  }

  double get activityAverage {
    if (_activities.isEmpty) return 0.0;
    int totalScore = 0;
    int totalItems = 0;
    for (var act in _activities) {
      totalScore += act.score;
      totalItems += act.numberOfItems;
    }
    return totalItems == 0 ? 0.0 : (totalScore / totalItems) * 100.0;
  }

  double get attendanceScore {
    if (_attendance.isEmpty) return 100.0; // Default to perfect attendance
    double totalPoints = 0;
    for (var att in _attendance) {
      if (att.status == 'Present') {
        totalPoints += 1.0;
      } else if (att.status == 'Late') {
        totalPoints += 0.5;
      }
    }
    return (totalPoints / _attendance.length) * 100.0;
  }

  double get oralAverage {
    if (_orals.isEmpty) return 0.0;
    double totalScore = 0;
    for (var oral in _orals) {
      totalScore += oral.score;
    }
    return (totalScore / (_orals.length * 50.0)) * 100.0;
  }

  double get projectAverage {
    if (_projects.isEmpty) return 0.0;
    int totalScore = 0;
    int totalMax = 0;
    for (var proj in _projects) {
      totalScore += proj.score;
      totalMax += proj.maxScore;
    }
    return totalMax == 0 ? 0.0 : (totalScore / totalMax) * 100.0;
  }

  // Weightings: Quizzes (20%), Exams (30%), Activities (20%), Attendance (10%), Oral Recitations (10%), Projects (10%)
  double get finalGrade {
    return (quizAverage * 0.20) +
        (examAverage * 0.30) +
        (activityAverage * 0.20) +
        (attendanceScore * 0.10) +
        (oralAverage * 0.10) +
        (projectAverage * 0.10);
  }

  // CRUD Operations with validations
  Future<void> addQuiz(String title, int score, int numberOfItems) async {
    if (_dbService == null || _selectedStudentId == null) return;

    final validationError = Quiz.validate(score, numberOfItems);
    if (validationError != null) throw Exception(validationError);

    final quiz = Quiz(
      quizId: '',
      studentId: _selectedStudentId!,
      score: score,
      numberOfItems: numberOfItems,
      date: DateTime.now(),
    );

    await _dbService!.addQuiz(quiz);
  }

  Future<void> deleteQuiz(String quizId) async {
    if (_dbService == null) return;
    await _dbService!.deleteQuiz(quizId);
  }

  Future<void> addExam(String term, int score, int numberOfItems) async {
    if (_dbService == null || _selectedStudentId == null) return;

    final validationError = Exam.validate(score, numberOfItems, term);
    if (validationError != null) throw Exception(validationError);

    // Exam constraint check
    final examExists = _exams.any((e) => e.term == term);
    if (examExists) {
      throw Exception('An exam for term "$term" already exists for this student.');
    }

    final exam = Exam(
      examId: '',
      studentId: _selectedStudentId!,
      term: term,
      score: score,
      numberOfItems: numberOfItems,
    );

    await _dbService!.addExam(exam);
  }

  Future<void> deleteExam(String examId) async {
    if (_dbService == null) return;
    await _dbService!.deleteExam(examId);
  }

  Future<void> addActivity(String title, int score, int numberOfItems) async {
    if (_dbService == null || _selectedStudentId == null) return;

    final validationError = Activity.validate(score, numberOfItems, title);
    if (validationError != null) throw Exception(validationError);

    final activity = Activity(
      activityId: '',
      studentId: _selectedStudentId!,
      title: title,
      score: score,
      numberOfItems: numberOfItems,
    );

    await _dbService!.addActivity(activity);
  }

  Future<void> deleteActivity(String activityId) async {
    if (_dbService == null) return;
    await _dbService!.deleteActivity(activityId);
  }

  Future<void> addAttendance(DateTime date, String status) async {
    if (_dbService == null || _selectedStudentId == null) return;

    final validationError = Attendance.validate(status);
    if (validationError != null) throw Exception(validationError);

    final attendance = Attendance(
      attendanceId: '',
      studentId: _selectedStudentId!,
      date: date,
      status: status,
    );

    await _dbService!.addAttendance(attendance);
  }

  Future<void> deleteAttendance(String attendanceId) async {
    if (_dbService == null) return;
    await _dbService!.deleteAttendance(attendanceId);
  }

  Future<void> addOral(int score) async {
    if (_dbService == null || _selectedStudentId == null) return;

    final validationError = Oral.validate(score);
    if (validationError != null) throw Exception(validationError);

    final oral = Oral(
      oralId: '',
      studentId: _selectedStudentId!,
      score: score,
      date: DateTime.now(),
    );

    await _dbService!.addOral(oral);
  }

  Future<void> deleteOral(String oralId) async {
    if (_dbService == null) return;
    await _dbService!.deleteOral(oralId);
  }

  Future<void> addProject(String title, int score, int maxScore) async {
    if (_dbService == null || _selectedStudentId == null) return;

    final validationError = Project.validate(score, maxScore, title);
    if (validationError != null) throw Exception(validationError);

    final project = Project(
      projectId: '',
      studentId: _selectedStudentId!,
      title: title,
      score: score,
      maxScore: maxScore,
    );

    await _dbService!.addProject(project);
  }

  Future<void> deleteProject(String projectId) async {
    if (_dbService == null) return;
    await _dbService!.deleteProject(projectId);
  }



  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
