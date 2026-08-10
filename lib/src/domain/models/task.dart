import '../../core/interfaces/persistable.dart';
import 'priority.dart';

/// Classe abstraite représentant une tâche.
///
/// Hiérarchie d'héritage (exigence du projet) :
/// ```
/// Task (abstract)
///   ├── UrgentTask   // chemin principal : Task → UrgentTask
///   └── RegularTask  // tâche standard (priorité low / medium)
/// ```
///
/// [Task] implémente l'interface [Persistable] (`Identifiable` + `Serializable`).
/// Les sous-classes concrètes définissent le comportement polymorphique
/// ([displayLabel], [isUrgent], sérialisation spécifique).
abstract class Task implements Persistable {
  @override
  final String id;
  String title;
  Priority priority;
  DateTime? dueDate;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Indique si la tâche est en retard (date limite dépassée et non terminée).
  bool get isOverdue {
    final deadline = dueDate;
    if (deadline == null || isCompleted) return false;
    return deadline.isBefore(DateTime.now());
  }

  /// Libellé d'affichage spécifique au type de tâche (polymorphisme).
  String get displayLabel;

  /// `true` uniquement pour le chemin d'héritage [Task] → `UrgentTask`.
  bool get isUrgent => false;

  /// Marque la tâche comme terminée.
  void complete() {
    isCompleted = true;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'priority': priority.name,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'type': runtimeType.toString(),
  };

  @override
  String toString() {
    final status = isCompleted ? '✓' : '○';
    final due = dueDate != null ? ' | échéance: ${_formatDate(dueDate!)}' : '';
    final overdue = isOverdue ? ' [EN RETARD]' : '';
    return '[$status] $displayLabel #$id — $title '
        '(${priority.name})$due$overdue';
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
