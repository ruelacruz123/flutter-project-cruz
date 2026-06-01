import '../models/student.dart';
import '../models/quiz.dart';
import '../models/exam.dart';
import '../models/activity.dart';
import '../models/attendance.dart';
import '../models/oral.dart';
import '../models/project.dart';
import '../models/todo.dart';

abstract class DatabaseService {
  // Students
  Stream<List<Student>> getStudents();
  Future<void> addStudent(Student student);

  // Quizzes
  Stream<List<Quiz>> getQuizzes(String studentId);
  Future<void> addQuiz(Quiz quiz);
  Future<void> deleteQuiz(String quizId);

  // Exams
  Stream<List<Exam>> getExams(String studentId);
  Future<void> addExam(Exam exam);
  Future<void> deleteExam(String examId);

  // Activities
  Stream<List<Activity>> getActivities(String studentId);
  Future<void> addActivity(Activity activity);
  Future<void> deleteActivity(String activityId);

  // Attendance
  Stream<List<Attendance>> getAttendance(String studentId);
  Future<void> addAttendance(Attendance attendance);
  Future<void> deleteAttendance(String attendanceId);

  // Oral Recitations
  Stream<List<Oral>> getOrals(String studentId);
  Future<void> addOral(Oral oral);
  Future<void> deleteOral(String oralId);

  // Projects
  Stream<List<Project>> getProjects(String studentId);
  Future<void> addProject(Project project);
  Future<void> deleteProject(String projectId);

  // Todos
  Stream<List<Todo>> getTodos(String userId);
  Future<void> addTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String todoId);
}
