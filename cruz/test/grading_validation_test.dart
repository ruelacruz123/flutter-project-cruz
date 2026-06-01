import 'package:flutter_test/flutter_test.dart';
import 'package:cruz/models/quiz.dart';
import 'package:cruz/models/oral.dart';
import 'package:cruz/models/exam.dart';
import 'package:cruz/services/mock_database_service.dart';
import 'package:cruz/provider/grading_provider.dart';

void main() {
  group('Model Validations', () {
    test('Quiz validations enforce limits and boundaries', () {
      // Valid quiz
      expect(Quiz.validate(10, 10), isNull);
      expect(Quiz.validate(0, 10), isNull);

      // Invalid quiz scores
      expect(Quiz.validate(-1, 10), contains('cannot be negative'));
      expect(Quiz.validate(11, 10), contains('cannot exceed number of items'));
      expect(Quiz.validate(5, -1), contains('must be greater than zero'));
    });

    test('Oral Recitation validation enforces limit of 50', () {
      // Valid oral
      expect(Oral.validate(45), isNull);
      expect(Oral.validate(0), isNull);
      expect(Oral.validate(50), isNull);

      // Invalid oral scores
      expect(Oral.validate(-5), contains('cannot be negative'));
      expect(Oral.validate(51), contains('cannot exceed 50'));
    });

    test('Exam validation checks bounds and valid terms', () {
      // Valid exams
      expect(Exam.validate(90, 100, 'Prelim'), isNull);
      expect(Exam.validate(50, 100, 'Midterm'), isNull);
      expect(Exam.validate(100, 100, 'Final'), isNull);

      // Invalid exams
      expect(Exam.validate(-10, 100, 'Midterm'), contains('cannot be negative'));
      expect(Exam.validate(101, 100, 'Midterm'), contains('cannot exceed number of items'));
      expect(Exam.validate(80, 100, 'InvalidTerm'), contains('Invalid term'));
    });
  });

  group('Database Constraints', () {
    test('MockDatabaseService prevents duplicate term exams for same student', () async {
      final db = MockDatabaseService();
      
      // Attempting to add duplicate Midterm exam for student1
      final duplicateExam = Exam(
        examId: 'e_dup',
        studentId: 'student1',
        term: 'Midterm',
        score: 95,
        numberOfItems: 100,
      );

      expect(
        () => db.addExam(duplicateExam),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('already exists'))),
      );
    });

    test('GradingProvider prevents adding duplicate exam term', () async {
      final db = MockDatabaseService();
      final provider = GradingProvider();
      
      // Update provider to use mock service and select student1
      provider.updateService(db, 'teacher', null);
      provider.selectStudent('student1');

      // Wait a moment for streams to emit mock data (including the default Midterm exam e2 for student1)
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert that Midterm exam is in the student's list
      expect(provider.exams.any((e) => e.term == 'Midterm'), isTrue);

      // Try adding another Midterm exam through the provider, should throw exception
      expect(
        () => provider.addExam('Midterm', 85, 100),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('already exists'))),
      );
    });
  });
}
