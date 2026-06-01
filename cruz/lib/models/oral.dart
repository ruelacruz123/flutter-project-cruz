import 'package:cloud_firestore/cloud_firestore.dart';

class Oral {
  final String oralId;
  final String studentId;
  final int score;
  final DateTime date;

  Oral({
    required this.oralId,
    required this.studentId,
    required this.score,
    required this.date,
  }) {
    assert(score >= 0, 'Score cannot be negative');
    assert(score <= 50, 'Score cannot exceed 50');
  }

  factory Oral.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date']);
    } else {
      parsedDate = DateTime.now();
    }

    return Oral(
      oralId: id,
      studentId: map['student_id'] ?? '',
      score: map['score'] is num ? (map['score'] as num).toInt() : 0,
      date: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'score': score,
      'date': Timestamp.fromDate(date),
    };
  }

  static String? validate(int? score) {
    if (score == null) return 'Score is required';
    if (score < 0) return 'Score cannot be negative';
    if (score > 50) return 'Score ($score) cannot exceed 50 for oral recitation';
    return null;
  }
}
