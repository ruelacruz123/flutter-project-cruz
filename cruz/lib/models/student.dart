class Student {
  final String studentId;
  final String name;
  final String email;
  final String rollNumber;

  Student({
    required this.studentId,
    required this.name,
    required this.email,
    required this.rollNumber,
  });

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      studentId: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      rollNumber: map['roll_number'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'roll_number': rollNumber,
    };
  }
}
