import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../provider/grading_provider.dart';
import '../widgets/gradient_background.dart';
import 'my_grades_screen.dart';
import 'todo_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  String _getLetterGrade(double grade) {
    if (grade >= 95) return 'A+';
    if (grade >= 90) return 'A';
    if (grade >= 85) return 'B+';
    if (grade >= 80) return 'B';
    if (grade >= 75) return 'C';
    return 'F';
  }

  Color _getGradeColor(double grade) {
    if (grade >= 85) return const Color(0xFF00E676); // Green
    if (grade >= 75) return Colors.orangeAccent; // Orange
    return Colors.redAccent; // Red
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final grading = Provider.of<GradingProvider>(context);

    final finalScore = grading.finalGrade;
    final letterGrade = _getLetterGrade(finalScore);
    final gradeColor = _getGradeColor(finalScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'STUDENT PORTAL',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F0C20),
        elevation: 0,
        actions: const [],
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card with Profile Info
              PremiumCard(
                gradientColors: [
                  const Color(0xFF9E77F3).withOpacity(0.15),
                  const Color(0xFF9E77F3).withOpacity(0.02),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF9E77F3).withOpacity(0.2),
                        child: Text(
                          auth.currentUser?.email.isNotEmpty == true 
                            ? auth.currentUser!.email[0].toUpperCase()
                            : 'S',
                          style: const TextStyle(
                            color: Color(0xFF9E77F3),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STUDENT PROFILE',
                              style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              auth.currentUser?.email.split('@').first.toUpperCase() ?? 'STUDENT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${auth.currentUser?.studentId ?? 'N/A'}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Final Cumulative Grade Gauge
              PremiumCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      // Radial Meter
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 90,
                            width: 90,
                            child: CircularProgressIndicator(
                              value: finalScore / 100.0,
                              strokeWidth: 8,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                            ),
                          ),
                          Text(
                            letterGrade,
                            style: TextStyle(
                              color: gradeColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CUMULATIVE GRADE',
                              style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${finalScore.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              finalScore >= 75.0 ? 'Academic Status: Passing' : 'Academic Status: Failing',
                              style: TextStyle(
                                color: finalScore >= 75.0 ? const Color(0xFF00E676) : Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Homework Task Management shortcut
              _buildTodoShortcut(context),
              const SizedBox(height: 32),

              // Category Scores List
              const Text(
                'ACADEMIC PERFORMANCE BREAKDOWN',
                style: TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              _buildCategoryCard(context, 'Quizzes', grading.quizAverage, Icons.quiz_outlined, 0),
              const SizedBox(height: 12),
              _buildCategoryCard(context, 'Exams', grading.examAverage, Icons.assignment_rounded, 1),
              const SizedBox(height: 12),
              _buildCategoryCard(context, 'Activities', grading.activityAverage, Icons.explore_outlined, 2),
              const SizedBox(height: 12),
              _buildCategoryCard(context, 'Attendance', grading.attendanceScore, Icons.calendar_today_rounded, 3),
              const SizedBox(height: 12),
              _buildCategoryCard(context, 'Oral Recitations', grading.oralAverage, Icons.record_voice_over_rounded, 4),
              const SizedBox(height: 12),
              _buildCategoryCard(context, 'Projects', grading.projectAverage, Icons.folder_shared_outlined, 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoShortcut(BuildContext context) {
    return PremiumCard(
      gradientColors: [
        const Color(0xFF00E676).withOpacity(0.08),
        const Color(0xFF00E676).withOpacity(0.01),
      ],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TodoScreen()),
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          children: [
            Icon(Icons.edit_calendar_rounded, color: Color(0xFF00E676), size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Tasks & Homework TODO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Create, complete, and track study checklists',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String name,
    double average,
    IconData icon,
    int tabIndex,
  ) {
    final displayColor = _getGradeColor(average);

    return PremiumCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyGradesScreen(initialIndex: tabIndex),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9E77F3), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${average.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: displayColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getLetterGrade(average),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
