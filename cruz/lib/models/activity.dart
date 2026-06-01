class Activity {
  final String activityId;
  final String studentId;
  final String title;
  final int score;
  final int numberOfItems;

  Activity({
    required this.activityId,
    required this.studentId,
    required this.title,
    required this.score,
    required this.numberOfItems,
  }) {
    assert(score >= 0, 'Score cannot be negative');
    assert(score <= numberOfItems, 'Score cannot exceed number of items');
  }

  factory Activity.fromMap(Map<String, dynamic> map, String id) {
    return Activity(
      activityId: id,
      studentId: map['student_id'] ?? '',
      title: map['title'] ?? '',
      score: map['score'] is num ? (map['score'] as num).toInt() : 0,
      numberOfItems: map['number_of_items'] is num ? (map['number_of_items'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'title': title,
      'score': score,
      'number_of_items': numberOfItems,
    };
  }

  static String? validate(int? score, int? numberOfItems, String? title) {
    if (title == null || title.trim().isEmpty) return 'Title is required';
    if (score == null) return 'Score is required';
    if (numberOfItems == null) return 'Number of items is required';
    if (score < 0) return 'Score cannot be negative';
    if (numberOfItems <= 0) return 'Number of items must be greater than zero';
    if (score > numberOfItems) return 'Score ($score) cannot exceed number of items ($numberOfItems)';
    return null;
  }
}
