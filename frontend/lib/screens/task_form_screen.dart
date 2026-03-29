import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? taskToEdit; // If this is null, we are creating a new task

  const TaskFormScreen({super.key, this.taskToEdit});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _status = 'To-Do';
  String _dueDate = DateTime.now().toString().split(' ')[0]; // Defaults to today
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      // Edit Mode: Fill the fields with existing task data
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description;
      _status = widget.taskToEdit!.status;
      _dueDate = widget.taskToEdit!.dueDate;
    } else {
      // Create Mode: Load any saved drafts!
      _loadDraft();
    }
  }

  // --- REQUIREMENT: DRAFTS LOGIC ---
  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _titleController.text = prefs.getString('draft_title') ?? '';
      _descriptionController.text = prefs.getString('draft_description') ?? '';
    });
  }

  Future<void> _saveDraft() async {
    if (widget.taskToEdit != null) return; // Don't save drafts if we are editing
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', _titleController.text);
    await prefs.setString('draft_description', _descriptionController.text);
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_title');
    await prefs.remove('draft_description');
  }
  // ----------------------------------

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    // REQUIREMENT: Prevent double-tapping and show loading
    setState(() {
      _isLoading = true; 
    });

    final taskData = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      status: _status,
    );

    try {
      if (widget.taskToEdit == null) {
        await ApiService().createTask(taskData);
        await _clearDraft(); // Clear the draft once successfully saved!
      } else {
        await ApiService().updateTask(widget.taskToEdit!.id!, taskData);
      }
      
      // Go back to the main screen and tell it to refresh
      if (mounted) Navigator.pop(context, true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving task: $e')),
      );
      setState(() {
        _isLoading = false; // Turn loading off if it fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskToEdit == null ? 'New Task' : 'Edit Task'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title', border: OutlineInputBorder()),
                onChanged: (value) => _saveDraft(), // Save draft on every keystroke
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                onChanged: (value) => _saveDraft(), // Save draft on every keystroke
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              
              // Simple Due Date display (we will make this a fancy date picker later if needed)
              Text('Due Date: $_dueDate', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['To-Do', 'In Progress', 'Done'].map((String status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
              ),
              const Spacer(),
              
              // REQUIREMENT: Disable button when loading
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Task', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}