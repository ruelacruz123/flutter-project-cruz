class Project {
  final String projectId;
  final String studentId;
  final String title;
  final int score;
  final int maxScore;

  Project({
    required this.projectId,
    required this.studentId,
    required this.title,
    required this.score,
    required this.maxScore,
  }) {
    assert(score >= 0, 'Score cannot be negative');
    assert(score <= maxScore, 'Score cannot exceed max score');
  }

  factory Project.fromMap(Map<String, dynamic> map, String id) {
    return Project(
      projectId: id,
      studentId: map['student_id'] ?? '',
      title: map['title'] ?? '',
      score: map['score'] is num ? (map['score'] as num).toInt() : 0,
      maxScore: map['max_score'] is num ? (map['max_score'] as num).toInt() : 100,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'title': title,
      'score': score,
      'max_score': maxScore,
    };
  }

  static String? validate(int? score, int? maxScore, String? title) {
    if (title == null || title.trim().isEmpty) return 'Title is required';
    if (score == null) return 'Score is required';
    if (maxScore == null) return 'Max score is required';
    if (score < 0) return 'Score cannot be negative';
    if (maxScore <= 0) return 'Max score must be greater than zero';
    if (score > maxScore) return 'Score ($score) cannot exceed maximum score ($maxScore)';
    return null;
  }
}
