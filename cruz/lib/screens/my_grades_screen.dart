import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../provider/grading_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/score_input_modal.dart';

class MyGradesScreen extends StatefulWidget {
  final int initialIndex;

  const MyGradesScreen({super.key, this.initialIndex = 0});

  @override
  State<MyGradesScreen> createState() => _MyGradesScreenState();
}

class _MyGradesScreenState extends State<MyGradesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['Quiz', 'Exam', 'Activity', 'Attendance', 'Oral', 'Project'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddRecordDialog(String category, List<String> existingTerms) {
    showDialog(
      context: context,
      builder: (context) {
        return ScoreInputModal(
          category: category,
          existingExamTerms: existingTerms,
          onSave: (data) async {
            final grading = Provider.of<GradingProvider>(context, listen: false);
            try {
              if (category == 'Quiz') {
                await grading.addQuiz('', data['score'], data['number_of_items']);
              } else if (category == 'Exam') {
                await grading.addExam(data['term'], data['score'], data['number_of_items']);
              } else if (category == 'Activity') {
                await grading.addActivity(data['title'], data['score'], data['number_of_items']);
              } else if (category == 'Attendance') {
                await grading.addAttendance(data['date'], data['status']);
              } else if (category == 'Oral') {
                await grading.addOral(data['score']);
              } else if (category == 'Project') {
                await grading.addProject(data['title'], data['score'], data['max_score']);
              }
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$category record saved successfully!'),
                    backgroundColor: const Color(0xFF00E676),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception:', '').trim()),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final grading = Provider.of<GradingProvider>(context);

    // Collect existing exam terms to pass to validator
    final existingExamTerms = grading.exams.map((e) => e.term).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MY ACADEMIC RECORDS',
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F0C20),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF9E77F3),
          unselectedLabelColor: Colors.white60,
          indicatorColor: const Color(0xFF9E77F3),
          tabs: _categories.map((cat) => Tab(text: cat == 'Oral' ? 'Oral Rec' : '${cat}s')).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final activeCategory = _categories[_tabController.index];
          _showAddRecordDialog(activeCategory, existingExamTerms);
        },
        backgroundColor: const Color(0xFF9E77F3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: GradientBackground(
        child: grading.isLoadingDetails
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF9E77F3)))
            : TabBarView(
                controller: _tabController,
                children: [
                  // QUIZZES TAB
                  _buildRecordList(
                    items: grading.quizzes,
                    titleBuilder: (q) => 'Quiz',
                    subtitleBuilder: (q) => DateFormat('yMMMd').format(q.date),
                    scoreBuilder: (q) => '${q.score} / ${q.numberOfItems}',
                    onDelete: (q) => grading.deleteQuiz(q.quizId),
                  ),

                  // EXAMS TAB
                  _buildRecordList(
                    items: grading.exams,
                    titleBuilder: (e) => '${e.term} Exam',
                    subtitleBuilder: (e) => 'Term Assessment',
                    scoreBuilder: (e) => '${e.score} / ${e.numberOfItems}',
                    onDelete: (e) => grading.deleteExam(e.examId),
                  ),

                  // ACTIVITIES TAB
                  _buildRecordList(
                    items: grading.activities,
                    titleBuilder: (a) => a.title,
                    subtitleBuilder: (a) => 'Class Activity',
                    scoreBuilder: (a) => '${a.score} / ${a.numberOfItems}',
                    onDelete: (a) => grading.deleteActivity(a.activityId),
                  ),

                  // ATTENDANCE TAB
                  _buildRecordList(
                    items: grading.attendance,
                    titleBuilder: (att) => att.status,
                    subtitleBuilder: (att) => DateFormat('yMMMd').format(att.date),
                    scoreBuilder: (att) => '',
                    statusColorBuilder: (att) {
                      if (att.status == 'Present') return const Color(0xFF00E676);
                      if (att.status == 'Late') return Colors.orangeAccent;
                      return Colors.redAccent;
                    },
                    onDelete: (att) => grading.deleteAttendance(att.attendanceId),
                  ),

                  // ORALS TAB
                  _buildRecordList(
                    items: grading.orals,
                    titleBuilder: (o) => 'Oral Recitation',
                    subtitleBuilder: (o) => DateFormat('yMMMd').format(o.date),
                    scoreBuilder: (o) => '${o.score} / 50',
                    onDelete: (o) => grading.deleteOral(o.oralId),
                  ),

                  // PROJECTS TAB
                  _buildRecordList(
                    items: grading.projects,
                    titleBuilder: (p) => p.title,
                    subtitleBuilder: (p) => 'Term Project',
                    scoreBuilder: (p) => '${p.score} / ${p.maxScore}',
                    onDelete: (p) => grading.deleteProject(p.projectId),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRecordList<T>({
    required List<T> items,
    required String Function(T item) titleBuilder,
    required String Function(T item) subtitleBuilder,
    required String Function(T item) scoreBuilder,
    required Future<void> Function(T item) onDelete,
    Color Function(T item)? statusColorBuilder,
  }) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No records found for this category.',
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final title = titleBuilder(item);
        final subtitle = subtitleBuilder(item);
        final score = scoreBuilder(item);
        final statusColor = statusColorBuilder != null ? statusColorBuilder(item) : Colors.white;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Dismissible(
            key: Key(item.hashCode.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_rounded, color: Colors.white),
            ),
            onDismissed: (direction) async {
              await onDelete(item);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Record deleted'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: PremiumCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (score.isNotEmpty)
                      Text(
                        score,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
