import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/quiz.dart';
import '../models/exam.dart';
import '../models/activity.dart';
import '../models/attendance.dart';
import '../models/oral.dart';
import '../models/project.dart';
import '../models/todo.dart';
import 'database_service.dart';

class FirestoreService implements DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<List<Student>> getStudents() {
    return _db.collection('students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addStudent(Student student) async {
    await _db.collection('students').doc(student.studentId).set(student.toMap());
  }

  @override
  Stream<List<Quiz>> getQuizzes(String studentId) {
    return _db
        .collection('quizzes')
        .where('student_id', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Quiz.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addQuiz(Quiz quiz) async {
    await _db.collection('quizzes').add(quiz.toMap());
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    await _db.collection('quizzes').doc(quizId).delete();
  }

  @override
  Stream<List<Exam>> getExams(String studentId) {
    return _db
        .collection('exams')
        .where('student_id', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Exam.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addExam(Exam exam) async {
    // Client-side validation: check duplicate term exam for the student
    final query = await _db
        .collection('exams')
        .where('student_id', isEqualTo: exam.studentId)
        .where('term', isEqualTo: exam.term)
        .get();

    if (query.docs.isNotEmpty) {
      throw Exception('An exam for term "${exam.term}" already exists for this student.');
    }
    await _db.collection('exams').add(exam.toMap());
  }

  @override
  Future<void> deleteExam(String examId) async {
    await _db.collection('exams').doc(examId).delete();
  }

  @override
  Stream<List<Activity>> getActivities(String studentId) {
    return _db
        .collection('activities')
        .where('student_id', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Activity.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addActivity(Activity activity) async {
    await _db.collection('activities').add(activity.toMap());
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    await _db.collection('activities').doc(activityId).delete();
  }

  @override
  Stream<List<Attendance>> getAttendance(String studentId) {
    return _db
        .collection('attendance')
        .where('student_id', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Attendance.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addAttendance(Attendance attendance) async {
    await _db.collection('attendance').add(attendance.toMap());
  }

  @override
  Future<void> deleteAttendance(String attendanceId) async {
    await _db.collection('attendance').doc(attendanceId).delete();
  }

  @override
  Stream<List<Oral>> getOrals(String studentId) {
    return _db
        .collection('oral')
        .where('student_id', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Oral.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addOral(Oral oral) async {
    await _db.collection('oral').add(oral.toMap());
  }

  @override
  Future<void> deleteOral(String oralId) async {
    await _db.collection('oral').doc(oralId).delete();
  }

  @override
  Stream<List<Project>> getProjects(String studentId) {
    return _db
        .collection('projects')
        .where('student_id', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Project.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addProject(Project project) async {
    await _db.collection('projects').add(project.toMap());
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _db.collection('projects').doc(projectId).delete();
  }

  @override
  Stream<List<Todo>> getTodos(String userId) {
    return _db
        .collection('todos')
        .where('user_id', isEqualTo: userId)
        .orderBy('due_date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Todo.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addTodo(Todo todo) async {
    await _db.collection('todos').add(todo.toMap());
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    await _db.collection('todos').doc(todo.todoId).update(todo.toMap());
  }

  @override
  Future<void> deleteTodo(String todoId) async {
    await _db.collection('todos').doc(todoId).delete();
  }
}
