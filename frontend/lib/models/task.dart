class Task {
  final int? id;
  final String title;
  final String description;
  final String dueDate;
  final String status;
  final int? blockedByTaskId;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = "To-Do",
    this.blockedByTaskId,
  });

  // This translates the JSON data from Python into a Flutter Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['due_date'],
      status: json['status'] ?? "To-Do",
      blockedByTaskId: json['blocked_by_task_id'],
    );
  }

  // This translates a Flutter Task object back into JSON to send to Python
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate,
      'status': status,
      'blocked_by_task_id': blockedByTaskId,
    };
  }
}