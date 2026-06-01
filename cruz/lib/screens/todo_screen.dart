import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/todo_provider.dart';
import '../widgets/gradient_background.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _taskTitleController = TextEditingController();
  final _taskDescController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    _taskTitleController.clear();
    _taskDescController.clear();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF15102A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Add Task / TODO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _taskTitleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        labelStyle: TextStyle(color: Colors.white60),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _taskDescController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.white60),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Due Date:', style: TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF9E77F3),
                                      surface: Color(0xFF15102A),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: Text(
                            DateFormat('yMMMd').format(_selectedDate),
                            style: const TextStyle(color: Color(0xFF9E77F3), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
                    try {
                      await todoProvider.addTodo(
                        _taskTitleController.text.trim(),
                        _taskDescController.text.trim(),
                        _selectedDate,
                      );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9E77F3)),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    // Group/Sort tasks: uncompleted first, then by due date
    final pendingTasks = todoProvider.todos.where((t) => !t.isCompleted).toList();
    final completedTasks = todoProvider.todos.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TASKS & TODO LIST',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F0C20),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF00E676),
        child: const Icon(Icons.add_task_rounded, color: Colors.white),
      ),
      body: GradientBackground(
        child: todoProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF9E77F3)))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          if (pendingTasks.isNotEmpty) ...[
                            const Text(
                              'PENDING TASKS',
                              style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 8),
                            ...pendingTasks.map((t) => _buildTodoItem(todoProvider, t)),
                            const SizedBox(height: 24),
                          ],
                          if (completedTasks.isNotEmpty) ...[
                            const Text(
                              'COMPLETED TASKS',
                              style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 8),
                            ...completedTasks.map((t) => _buildTodoItem(todoProvider, t)),
                          ],
                          if (pendingTasks.isEmpty && completedTasks.isEmpty)
                            const SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  'All tasks complete! Great job.',
                                  style: TextStyle(color: Colors.white38, fontSize: 16),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTodoItem(TodoProvider todoProvider, var todo) {
    final isOverdue = !todo.isCompleted && todo.dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Dismissible(
        key: Key(todo.todoId),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        onDismissed: (direction) async {
          await todoProvider.deleteTodo(todo.todoId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task deleted'), backgroundColor: Colors.redAccent),
            );
          }
        },
        child: PremiumCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Checkbox(
                  value: todo.isCompleted,
                  activeColor: const Color(0xFF00E676),
                  checkColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  onChanged: (val) {
                    todoProvider.toggleTodo(todo);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.taskTitle,
                        style: TextStyle(
                          color: todo.isCompleted ? Colors.white38 : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (todo.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description,
                          style: TextStyle(
                            color: todo.isCompleted ? Colors.white24 : Colors.white60,
                            fontSize: 13,
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 13,
                            color: todo.isCompleted 
                              ? Colors.white24 
                              : isOverdue 
                                ? Colors.redAccent 
                                : Colors.white38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${DateFormat('yMMMd').format(todo.dueDate)}',
                            style: TextStyle(
                              color: todo.isCompleted 
                                ? Colors.white24 
                                : isOverdue 
                                  ? Colors.redAccent 
                                  : Colors.white38,
                              fontSize: 11,
                              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 8),
                            const Text(
                              'OVERDUE',
                              style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
