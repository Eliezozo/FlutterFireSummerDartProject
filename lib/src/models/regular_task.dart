import 'priority.dart';
import 'task.dart';

/// Tâche standard (priorité low ou medium).
class RegularTask extends Task {
  RegularTask({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.isCompleted,
    super.createdAt,
  });

  factory RegularTask.fromJson(Map<String, dynamic> json) {
    return RegularTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: Priority.fromString(json['priority'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String get displayLabel => 'Tâche';
}
