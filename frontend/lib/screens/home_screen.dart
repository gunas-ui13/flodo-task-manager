import 'package:flutter/material.dart';
import 'dart:async';
import '../models/task.dart';
import '../services/api_service.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _allTasks = [];
  bool _isLoading = true;
  
  // Search and Filter State
  String _searchQuery = '';
  String _statusFilter = 'All';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await ApiService().getTasks();
      setState(() {
        _allTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  // STRETCH GOAL: Debounced Search
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
    });
  }

  Future<void> _deleteTask(int id) async {
    try {
      await ApiService().deleteTask(id);
      _fetchTasks(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply Filters & Search
    List<Task> displayedTasks = _allTasks.where((task) {
      final matchesStatus = _statusFilter == 'All' || task.status == _statusFilter;
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery);
      return matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flodo Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Tasks...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: ['All', 'To-Do', 'In Progress', 'Done'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _statusFilter = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Task List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedTasks.isEmpty
                    ? const Center(child: Text('No tasks found.'))
                    : RefreshIndicator(
                        onRefresh: _fetchTasks,
                        child: ListView.builder(
                          itemCount: displayedTasks.length,
                          itemBuilder: (context, index) {
                            final task = displayedTasks[index];
                            
                            // REQUIREMENT: Blocked By Logic
                            bool isBlocked = false;
                            if (task.blockedByTaskId != null) {
                              // Find the parent task
                              final parentTask = _allTasks.where((t) => t.id == task.blockedByTaskId).firstOrNull;
                              // If parent exists and isn't Done, this task is blocked
                              if (parentTask != null && parentTask.status != 'Done') {
                                isBlocked = true;
                              }
                            }

                            return Opacity(
                              opacity: isBlocked ? 0.5 : 1.0, // Grey out if blocked
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.status == 'Done' ? TextDecoration.lineThrough : null,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text('${task.status} • Due: ${task.dueDate}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteTask(task.id!),
                                  ),
                                  onTap: isBlocked 
                                    ? () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('This task is blocked by another task!')),
                                        );
                                      }
                                    : () async {
                                        // Navigate to edit screen, wait for return
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TaskFormScreen(taskToEdit: task),
                                          ),
                                        );
                                        // If we returned 'true', refresh the list
                                        if (result == true) _fetchTasks();
                                      },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to create screen, wait for return
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskFormScreen()),
          );
          // If we returned 'true', refresh the list
          if (result == true) _fetchTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}