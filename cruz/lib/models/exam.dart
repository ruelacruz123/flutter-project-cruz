class Exam {
  final String examId;
  final String studentId;
  final String term; // 'Prelim', 'Midterm', 'Final'
  final int score;
  final int numberOfItems;

  Exam({
    required this.examId,
    required this.studentId,
    required this.term,
    required this.score,
    required this.numberOfItems,
  }) {
    assert(score >= 0, 'Score cannot be negative');
    assert(score <= numberOfItems, 'Score cannot exceed number of items');
    assert(term == 'Prelim' || term == 'Midterm' || term == 'Final', 'Term must be Prelim, Midterm, or Final');
  }

  factory Exam.fromMap(Map<String, dynamic> map, String id) {
    return Exam(
      examId: id,
      studentId: map['student_id'] ?? '',
      term: map['term'] ?? 'Midterm',
      score: map['score'] is num ? (map['score'] as num).toInt() : 0,
      numberOfItems: map['number_of_items'] is num ? (map['number_of_items'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'term': term,
      'score': score,
      'number_of_items': numberOfItems,
    };
  }

  static String? validate(int? score, int? numberOfItems, String? term) {
    if (score == null) return 'Score is required';
    if (numberOfItems == null) return 'Number of items is required';
    if (term == null || (term != 'Prelim' && term != 'Midterm' && term != 'Final')) {
      return 'Invalid term. Must be Prelim, Midterm, or Final';
    }
    if (score < 0) return 'Score cannot be negative';
    if (numberOfItems <= 0) return 'Number of items must be greater than zero';
    if (score > numberOfItems) return 'Score ($score) cannot exceed number of items ($numberOfItems)';
    return null;
  }
}
