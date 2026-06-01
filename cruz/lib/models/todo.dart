import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String todoId;
  final String userId;
  final String taskTitle;
  final String description;
  final bool isCompleted;
  final DateTime dueDate;

  Todo({
    required this.todoId,
    required this.userId,
    required this.taskTitle,
    required this.description,
    required this.isCompleted,
    required this.dueDate,
  });

  factory Todo.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    if (map['due_date'] is Timestamp) {
      parsedDate = (map['due_date'] as Timestamp).toDate();
    } else if (map['due_date'] is String) {
      parsedDate = DateTime.parse(map['due_date']);
    } else {
      parsedDate = DateTime.now();
    }

    return Todo(
      todoId: id,
      userId: map['user_id'] ?? '',
      taskTitle: map['task_title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['is_completed'] ?? false,
      dueDate: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'task_title': taskTitle,
      'description': description,
      'is_completed': isCompleted,
      'due_date': Timestamp.fromDate(dueDate),
    };
  }

  static String? validate(String? taskTitle, String? description) {
    if (taskTitle == null || taskTitle.trim().isEmpty) {
      return 'Task title is required';
    }
    if (description == null || description.trim().isEmpty) {
      return 'Description is required';
    }
    return null;
  }
}
