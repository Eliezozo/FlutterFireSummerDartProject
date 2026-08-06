import 'priority.dart';
import 'task.dart';

/// Tâche urgente : priorité forcée à [Priority.high].
///
/// Hérite de [Task] et ajoute une note d'urgence optionnelle.
class UrgentTask extends Task {
  /// Contexte ou raison de l'urgence.
  String? urgencyNote;

  UrgentTask({
    required super.id,
    required super.title,
    super.dueDate,
    super.isCompleted,
    super.createdAt,
    this.urgencyNote,
  }) : super(priority: Priority.high);

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    return UrgentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      urgencyNote: json['urgencyNote'] as String?,
    );
  }

  @override
  String get displayLabel => 'URGENT';

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'urgencyNote': urgencyNote,
      };

  @override
  String toString() {
    final note = urgencyNote != null ? ' — note: $urgencyNote' : '';
    return '${super.toString()}$note';
  }
}
