import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String quizId;
  final String studentId;
  final int score;
  final int numberOfItems;
  final DateTime date;

  Quiz({
    required this.quizId,
    required this.studentId,
    required this.score,
    required this.numberOfItems,
    required this.date,
  }) {
    assert(score >= 0, 'Score cannot be negative');
    assert(score <= numberOfItems, 'Score cannot exceed number of items');
  }

  factory Quiz.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date']);
    } else {
      parsedDate = DateTime.now();
    }

    return Quiz(
      quizId: id,
      studentId: map['student_id'] ?? '',
      score: map['score'] is num ? (map['score'] as num).toInt() : 0,
      numberOfItems: map['number_of_items'] is num ? (map['number_of_items'] as num).toInt() : 0,
      date: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'score': score,
      'number_of_items': numberOfItems,
      'date': Timestamp.fromDate(date),
    };
  }

  static String? validate(int? score, int? numberOfItems) {
    if (score == null) return 'Score is required';
    if (numberOfItems == null) return 'Number of items is required';
    if (score < 0) return 'Score cannot be negative';
    if (numberOfItems <= 0) return 'Number of items must be greater than zero';
    if (score > numberOfItems) return 'Score ($score) cannot exceed number of items ($numberOfItems)';
    return null;
  }
}
