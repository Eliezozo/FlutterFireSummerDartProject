import 'priority.dart';
import 'task.dart';

/// Tâche urgente : spécialisation de [Task] (`Task → UrgentTask`).
///
/// Hérite de [Task] et surcharge le comportement :
/// - priorité forcée à [Priority.high]
/// - libellé `URGENT`
/// - [isUrgent] vaut `true`
/// - note d'urgence optionnelle [urgencyNote]
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
  bool get isUrgent => true;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'urgencyNote': urgencyNote,
  };

  @override
  String toString() {
    final note = urgencyNote;
    final noteLabel = (note == null || note.isEmpty) ? '' : ' — note: $note';
    return '${super.toString()}$noteLabel';
  }
}
