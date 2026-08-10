import 'task.dart';

/// Critères de tri pour la liste des tâches.
enum SortBy { priority, dueDate, createdAt }

/// Comparateurs métier utilisés par `Repository<Task>.findAllSorted`.
abstract final class TaskComparators {
  static int Function(Task a, Task b) by(SortBy sortBy) => switch (sortBy) {
    SortBy.priority => _byPriority,
    SortBy.dueDate => _byDueDate,
    SortBy.createdAt => _byCreatedAt,
  };

  static int _byPriority(Task a, Task b) {
    final byPriority = b.priority.sortWeight.compareTo(a.priority.sortWeight);
    if (byPriority != 0) return byPriority;
    return a.createdAt.compareTo(b.createdAt);
  }

  static int _byDueDate(Task a, Task b) {
    final aDue = a.dueDate;
    final bDue = b.dueDate;
    if (aDue == null && bDue == null) return 0;
    if (aDue == null) return 1;
    if (bDue == null) return -1;
    return aDue.compareTo(bDue);
  }

  static int _byCreatedAt(Task a, Task b) => a.createdAt.compareTo(b.createdAt);
}
