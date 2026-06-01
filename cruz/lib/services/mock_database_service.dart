import 'dart:async';
import '../models/student.dart';
import '../models/quiz.dart';
import '../models/exam.dart';
import '../models/activity.dart';
import '../models/attendance.dart';
import '../models/oral.dart';
import '../models/project.dart';
import '../models/todo.dart';
import 'database_service.dart';

class MockDatabaseService implements DatabaseService {
  // Static in-memory lists to persist data across service reinstantiations during app session
  static final List<Student> _students = [
    Student(
      studentId: 'student1',
      name: 'Ruela Cruz',
      email: 'ruelacruz@gmail.com',
      rollNumber: '2024-0001',
    ),
    Student(
      studentId: 'student2',
      name: 'John Doe',
      email: 'john@student.com',
      rollNumber: '2024-0002',
    ),
    Student(
      studentId: 'student3',
      name: 'Jane Smith',
      email: 'jane@student.com',
      rollNumber: '2024-0003',
    ),
    Student(
      studentId: 'student4',
      name: 'Bob Johnson',
      email: 'bob@student.com',
      rollNumber: '2024-0004',
    ),
    Student(
      studentId: 'student5',
      name: 'Alice Williams',
      email: 'alice@student.com',
      rollNumber: '2024-0005',
    ),
  ];

  static final List<Quiz> _quizzes = [
    // student1
    Quiz(
      quizId: 'q1',
      studentId: 'student1',
      score: 18,
      numberOfItems: 20,
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Quiz(
      quizId: 'q2',
      studentId: 'student1',
      score: 15,
      numberOfItems: 20,
      date: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Quiz(
      quizId: 'q3',
      studentId: 'student1',
      score: 9,
      numberOfItems: 10,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    // student2
    Quiz(
      quizId: 'q4',
      studentId: 'student2',
      score: 12,
      numberOfItems: 20,
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Quiz(
      quizId: 'q5',
      studentId: 'student2',
      score: 19,
      numberOfItems: 20,
      date: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  static final List<Exam> _exams = [
    // student1
    Exam(
      examId: 'e1',
      studentId: 'student1',
      term: 'Prelim',
      score: 85,
      numberOfItems: 100,
    ),
    Exam(
      examId: 'e2',
      studentId: 'student1',
      term: 'Midterm',
      score: 90,
      numberOfItems: 100,
    ),
    // student2
    Exam(
      examId: 'e3',
      studentId: 'student2',
      term: 'Prelim',
      score: 72,
      numberOfItems: 100,
    ),
  ];

  static final List<Activity> _activities = [
    // student1
    Activity(
      activityId: 'a1',
      studentId: 'student1',
      title: 'Activity 1: Firebase Setup',
      score: 10,
      numberOfItems: 10,
    ),
    Activity(
      activityId: 'a2',
      studentId: 'student1',
      title: 'Activity 2: Layout Design',
      score: 13,
      numberOfItems: 15,
    ),
    // student2
    Activity(
      activityId: 'a3',
      studentId: 'student2',
      title: 'Activity 1: Firebase Setup',
      score: 8,
      numberOfItems: 10,
    ),
  ];

  static final List<Attendance> _attendance = [
    // student1
    Attendance(
      attendanceId: 'att1',
      studentId: 'student1',
      date: DateTime.now().subtract(const Duration(days: 4)),
      status: 'Present',
    ),
    Attendance(
      attendanceId: 'att2',
      studentId: 'student1',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Present',
    ),
    Attendance(
      attendanceId: 'att3',
      studentId: 'student1',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: 'Late',
    ),
    Attendance(
      attendanceId: 'att4',
      studentId: 'student1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Absent',
    ),
    // student2
    Attendance(
      attendanceId: 'att5',
      studentId: 'student2',
      date: DateTime.now().subtract(const Duration(days: 4)),
      status: 'Present',
    ),
    Attendance(
      attendanceId: 'att6',
      studentId: 'student2',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Present',
    ),
  ];

  static final List<Oral> _orals = [
    // student1
    Oral(
      oralId: 'o1',
      studentId: 'student1',
      score: 45,
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Oral(
      oralId: 'o2',
      studentId: 'student1',
      score: 40,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    // student2
    Oral(
      oralId: 'o3',
      studentId: 'student2',
      score: 35,
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  static final List<Project> _projects = [
    // student1
    Project(
      projectId: 'p1',
      studentId: 'student1',
      title: 'Grading App Draft',
      score: 90,
      maxScore: 100,
    ),
    // student2
    Project(
      projectId: 'p2',
      studentId: 'student2',
      title: 'Grading App Draft',
      score: 80,
      maxScore: 100,
    ),
  ];

  static final List<Todo> _todos = [
    Todo(
      todoId: 't1',
      userId: 'teacher_uid',
      taskTitle: 'Review exam results',
      description: 'Grade prelims and post results.',
      isCompleted: false,
      dueDate: DateTime.now().add(const Duration(days: 2)),
    ),
    Todo(
      todoId: 't2',
      userId: 'teacher_uid',
      taskTitle: 'Prepare final syllabus',
      description: 'Update reading materials.',
      isCompleted: true,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Todo(
      todoId: 't3',
      userId: 'student1',
      taskTitle: 'Study for Midterm Exam',
      description: 'Focus on chapters 4-6.',
      isCompleted: false,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    Todo(
      todoId: 't4',
      userId: 'student1',
      taskTitle: 'Submit Project draft',
      description: 'Ensure citations are formatted.',
      isCompleted: false,
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
  ];

  // Stream Controllers
  final _studentsController = StreamController<List<Student>>.broadcast();
  final _quizzesControllers = <String, StreamController<List<Quiz>>>{};
  final _examsControllers = <String, StreamController<List<Exam>>>{};
  final _activitiesControllers = <String, StreamController<List<Activity>>>{};
  final _attendanceControllers = <String, StreamController<List<Attendance>>>{};
  final _oralControllers = <String, StreamController<List<Oral>>>{};
  final _projectsControllers = <String, StreamController<List<Project>>>{};
  final _todosControllers = <String, StreamController<List<Todo>>>{};

  void _notifyStudents() {
    if (_studentsController.hasListener) {
      _studentsController.add(List.unmodifiable(_students));
    }
  }

  void _notifyQuizzes(String studentId) {
    final controller = _quizzesControllers[studentId];
    if (controller != null && controller.hasListener) {
      final list = _quizzes.where((q) => q.studentId == studentId).toList();
      controller.add(List.unmodifiable(list));
    }
  }

  void _notifyExams(String studentId) {
    final controller = _examsControllers[studentId];
    if (controller != null && controller.hasListener) {
      final list = _exams.where((e) => e.studentId == studentId).toList();
      controller.add(List.unmodifiable(list));
    }
  }

  void _notifyActivities(String studentId) {
    final controller = _activitiesControllers[studentId];
    if (controller != null && controller.hasListener) {
      final list = _activities.where((a) => a.studentId == studentId).toList();
      controller.add(List.unmodifiable(list));
    }
  }

  void _notifyAttendance(String studentId) {
    final controller = _attendanceControllers[studentId];
    if (controller != null && controller.hasListener) {
      final list = _attendance
          .where((att) => att.studentId == studentId)
          .toList();
      controller.add(List.unmodifiable(list));
    }
  }

  void _notifyOrals(String studentId) {
    final controller = _oralControllers[studentId];
    if (controller != null && controller.hasListener) {
      final list = _orals.where((o) => o.studentId == studentId).toList();
      controller.add(List.unmodifiable(list));
    }
  }

  void _notifyProjects(String studentId) {
    final controller = _projectsControllers[studentId];
    if (controller != null && controller.hasListener) {
      final list = _projects.where((p) => p.studentId == studentId).toList();
      controller.add(List.unmodifiable(list));
    }
  }

  void _notifyTodos(String userId) {
    final controller = _todosControllers[userId];
    if (controller != null && controller.hasListener) {
      final list = _todos.where((t) => t.userId == userId).toList();
      controller.add(List.unmodifiable(list));
    }
  }

  @override
  Stream<List<Student>> getStudents() {
    Timer(Duration.zero, () => _notifyStudents());
    return _studentsController.stream;
  }

  @override
  Future<void> addStudent(Student student) async {
    _students.add(student);
    _notifyStudents();
  }

  @override
  Stream<List<Quiz>> getQuizzes(String studentId) {
    final controller = _quizzesControllers.putIfAbsent(
      studentId,
      () => StreamController<List<Quiz>>.broadcast(),
    );
    Timer(Duration.zero, () => _notifyQuizzes(studentId));
    return controller.stream;
  }

  @override
  Future<void> addQuiz(Quiz quiz) async {
    _quizzes.add(quiz);
    _notifyQuizzes(quiz.studentId);
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    final index = _quizzes.indexWhere((q) => q.quizId == quizId);
    if (index != -1) {
      final studentId = _quizzes[index].studentId;
      _quizzes.removeAt(index);
      _notifyQuizzes(studentId);
    }
  }

  @override
  Stream<List<Exam>> getExams(String studentId) {
    final controller = _examsControllers.putIfAbsent(
      studentId,
      () => StreamController<List<Exam>>.broadcast(),
    );
    Timer(Duration.zero, () => _notifyExams(studentId));
    return controller.stream;
  }

  @override
  Future<void> addExam(Exam exam) async {
    // Business rule check: only 1 exam per term per student
    final exists = _exams.any(
      (e) => e.studentId == exam.studentId && e.term == exam.term,
    );
    if (exists) {
      throw Exception(
        'An exam for term "${exam.term}" already exists for this student.',
      );
    }
    _exams.add(exam);
    _notifyExams(exam.studentId);
  }

  @override
  Future<void> deleteExam(String examId) async {
    final index = _exams.indexWhere((e) => e.examId == examId);
    if (index != -1) {
      final studentId = _exams[index].studentId;
      _exams.removeAt(index);
      _notifyExams(studentId);
    }
  }

  @override
  Stream<List<Activity>> getActivities(String studentId) {
    final controller = _activitiesControllers.putIfAbsent(
      studentId,
      () => StreamController<List<Activity>>.broadcast(),
    );
    Timer(Duration.zero, () => _notifyActivities(studentId));
    return controller.stream;
  }

  @override
  Future<void> addActivity(Activity activity) async {
    _activities.add(activity);
    _notifyActivities(activity.studentId);
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    final index = _activities.indexWhere((a) => a.activityId == activityId);
    if (index != -1) {
      final studentId = _activities[index].studentId;
      _activities.removeAt(index);
      _notifyActivities(studentId);
    }
  }

  @override
  Stream<List<Attendance>> getAttendance(String studentId) {
    final controller = _attendanceControllers.putIfAbsent(
      studentId,
      () => StreamController<List<Attendance>>.broadcast(),
    );
    Timer(Duration.zero, () => _notifyAttendance(studentId));
    return controller.stream;
  }

  @override
  Future<void> addAttendance(Attendance attendance) async {
    _attendance.add(attendance);
    _notifyAttendance(attendance.studentId);
  }

  @override
  Future<void> deleteAttendance(String attendanceId) async {
    final index = _attendance.indexWhere(
      (att) => att.attendanceId == attendanceId,
    );
    if (index != -1) {
      final studentId = _attendance[index].studentId;
      _attendance.removeAt(index);
      _notifyAttendance(studentId);
    }
  }

  @override
  Stream<List<Oral>> getOrals(String studentId) {
    final controller = _oralControllers.putIfAbsent(
      studentId,
      () => StreamController<List<Oral>>.broadcast(),
    );
    Timer(Duration.zero, () => _notifyOrals(studentId));
    return controller.stream;
  }

  @override
  Future<void> addOral(Oral oral) async {
    _orals.add(oral);
    _notifyOrals(oral.studentId);
  }

  @override
  Future<void> deleteOral(String oralId) async {
    final index = _orals.indexWhere((o) => o.oralId == oralId);
    if (index != -1) {
      final studentId = _orals[index].studentId;
      _orals.removeAt(index);
      _notifyOrals(studentId);
    }
  }

  @override
  Stream<List<Project>> getProjects(String studentId) {
    final controller = _projectsControllers.putIfAbsent(
      studentId,
      () => StreamController<List<Project>>.broadcast(),
    );
    Timer(Duration.zero, () => _notifyProjects(studentId));
    return controller.stream;
  }

  @override
  Future<void> addProject(Project project) async {
    _projects.add(project);
    _notifyProjects(project.studentId);
  }

  @override
  Future<void> deleteProject(String projectId) async {
    final index = _projects.indexWhere((p) => p.projectId == projectId);
    if (index != -1) {
      final studentId = _projects[index].studentId;
      _projects.removeAt(index);
      _notifyProjects(studentId);
    }
  }

  @override
  Stream<List<Todo>> getTodos(String userId) {
    final controller = _todosControllers.putIfAbsent(
      userId,
      () => StreamController<List<Todo>>.broadcast(),
    );
    Timer(Duration.zero, () => _notifyTodos(userId));
    return controller.stream;
  }

  @override
  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
    _notifyTodos(todo.userId);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.todoId == todo.todoId);
    if (index != -1) {
      _todos[index] = todo;
      _notifyTodos(todo.userId);
    }
  }

  @override
  Future<void> deleteTodo(String todoId) async {
    final index = _todos.indexWhere((t) => t.todoId == todoId);
    if (index != -1) {
      final userId = _todos[index].userId;
      _todos.removeAt(index);
      _notifyTodos(userId);
    }
  }
}
