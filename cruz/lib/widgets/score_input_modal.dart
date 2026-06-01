import 'package:flutter/material.dart';

class ScoreInputModal extends StatefulWidget {
  final String category; // 'Quiz', 'Exam', 'Activity', 'Attendance', 'Oral', 'Project'
  final Function(Map<String, dynamic> data) onSave;
  final List<String> existingExamTerms; // For validating unique exams (Prelim, Midterm, Final)

  const ScoreInputModal({
    super.key,
    required this.category,
    required this.onSave,
    this.existingExamTerms = const [],
  });

  @override
  State<ScoreInputModal> createState() => _ScoreInputModalState();
}

class _ScoreInputModalState extends State<ScoreInputModal> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _scoreController = TextEditingController();
  final _itemsController = TextEditingController();

  // Selected values
  String _selectedTerm = 'Midterm';
  String _selectedAttendanceStatus = 'Present';

  @override
  void dispose() {
    _titleController.dispose();
    _scoreController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{};

    if (widget.category == 'Quiz') {
      data['score'] = int.parse(_scoreController.text);
      data['number_of_items'] = int.parse(_itemsController.text);
    } else if (widget.category == 'Exam') {
      data['term'] = _selectedTerm;
      data['score'] = int.parse(_scoreController.text);
      data['number_of_items'] = int.parse(_itemsController.text);
    } else if (widget.category == 'Activity') {
      data['title'] = _titleController.text.trim();
      data['score'] = int.parse(_scoreController.text);
      data['number_of_items'] = int.parse(_itemsController.text);
    } else if (widget.category == 'Attendance') {
      data['status'] = _selectedAttendanceStatus;
      data['date'] = DateTime.now();
    } else if (widget.category == 'Oral') {
      data['score'] = int.parse(_scoreController.text);
    } else if (widget.category == 'Project') {
      data['title'] = _titleController.text.trim();
      data['score'] = int.parse(_scoreController.text);
      data['max_score'] = int.parse(_itemsController.text);
    }

    widget.onSave(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF15102A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Add ${widget.category} Record',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TITLE INPUT (Activities and Projects)
              if (widget.category == 'Activity' || widget.category == 'Project') ...[
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Title / Topic',
                    labelStyle: const TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
              ],

              // TERM DROPDOWN (Exams)
              if (widget.category == 'Exam') ...[
                DropdownButtonFormField<String>(
                  value: _selectedTerm,
                  dropdownColor: const Color(0xFF15102A),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Academic Term',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Prelim', child: Text('Prelim')),
                    DropdownMenuItem(value: 'Midterm', child: Text('Midterm')),
                    DropdownMenuItem(value: 'Final', child: Text('Final')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedTerm = val;
                      });
                    }
                  },
                  validator: (val) {
                    if (widget.existingExamTerms.contains(val)) {
                      return 'An exam for $val already exists!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // ATTENDANCE DROPDOWN
              if (widget.category == 'Attendance') ...[
                DropdownButtonFormField<String>(
                  value: _selectedAttendanceStatus,
                  dropdownColor: const Color(0xFF15102A),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Present', child: Text('Present')),
                    DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                    DropdownMenuItem(value: 'Late', child: Text('Late')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedAttendanceStatus = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              // SCORE INPUT (Except Attendance)
              if (widget.category != 'Attendance') ...[
                TextFormField(
                  controller: _scoreController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: widget.category == 'Oral' ? 'Score (Max 50)' : 'Score Obtained',
                    labelStyle: const TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Score is required';
                    final score = int.tryParse(val);
                    if (score == null) return 'Must be a valid integer';
                    if (score < 0) return 'Score cannot be negative';
                    
                    if (widget.category == 'Oral' && score > 50) {
                      return 'Oral score cannot exceed 50';
                    }

                    if (_itemsController.text.isNotEmpty) {
                      final items = int.tryParse(_itemsController.text);
                      if (items != null && score > items) {
                        return 'Cannot exceed total items ($items)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // TOTAL ITEMS / MAX SCORE (Quizzes, Activities, Exams, Projects)
              if (widget.category == 'Quiz' ||
                  widget.category == 'Activity' ||
                  widget.category == 'Exam' ||
                  widget.category == 'Project') ...[
                TextFormField(
                  controller: _itemsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: widget.category == 'Project' ? 'Max Score (e.g. 100)' : 'Total Items',
                    labelStyle: const TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Total items is required';
                    final items = int.tryParse(val);
                    if (items == null) return 'Must be a valid integer';
                    if (items <= 0) return 'Must be greater than zero';
                    
                    if (_scoreController.text.isNotEmpty) {
                      final score = int.tryParse(_scoreController.text);
                      if (score != null && score > items) {
                        return 'Total items must be >= score ($score)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9E77F3)),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
