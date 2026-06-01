import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String attendanceId;
  final String studentId;
  final DateTime date;
  final String status; // 'Present', 'Absent', 'Late'

  Attendance({
    required this.attendanceId,
    required this.studentId,
    required this.date,
    required this.status,
  }) {
    assert(status == 'Present' || status == 'Absent' || status == 'Late', 'Invalid status');
  }

  factory Attendance.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date']);
    } else {
      parsedDate = DateTime.now();
    }

    return Attendance(
      attendanceId: id,
      studentId: map['student_id'] ?? '',
      date: parsedDate,
      status: map['status'] ?? 'Present',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }

  static String? validate(String? status) {
    if (status == null || (status != 'Present' && status != 'Absent' && status != 'Late')) {
      return 'Status must be Present, Absent, or Late';
    }
    return null;
  }
}
