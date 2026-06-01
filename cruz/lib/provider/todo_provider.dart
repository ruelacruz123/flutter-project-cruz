import 'dart:async';
import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/database_service.dart';

class TodoProvider extends ChangeNotifier {
  DatabaseService? _dbService;
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _currentUserId;
  StreamSubscription? _todosSub;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;

  void updateService(DatabaseService service, String? userId) {
    _dbService = service;
    _todosSub?.cancel();
    _todos = [];

    if (userId != null) {
      _currentUserId = userId;
      _loadTodos(userId);
    } else {
      _currentUserId = null;
      notifyListeners();
    }
  }

  void _loadTodos(String userId) {
    if (_dbService == null) return;
    _isLoading = true;
    notifyListeners();

    _todosSub = _dbService!.getTodos(userId).listen((data) {
      _todos = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      debugPrint('Error loading todos: $e');
      notifyListeners();
    });
  }

  Future<void> addTodo(String title, String description, DateTime dueDate) async {
    if (_dbService == null || _currentUserId == null) return;

    final validationError = Todo.validate(title, description);
    if (validationError != null) throw Exception(validationError);

    final todo = Todo(
      todoId: '',
      userId: _currentUserId!,
      taskTitle: title,
      description: description,
      isCompleted: false,
      dueDate: dueDate,
    );

    await _dbService!.addTodo(todo);
  }

  Future<void> toggleTodo(Todo todo) async {
    if (_dbService == null) return;

    final updated = Todo(
      todoId: todo.todoId,
      userId: todo.userId,
      taskTitle: todo.taskTitle,
      description: todo.description,
      isCompleted: !todo.isCompleted,
      dueDate: todo.dueDate,
    );

    await _dbService!.updateTodo(updated);
  }

  Future<void> deleteTodo(String todoId) async {
    if (_dbService == null) return;
    await _dbService!.deleteTodo(todoId);
  }

  @override
  void dispose() {
    _todosSub?.cancel();
    super.dispose();
  }
}
