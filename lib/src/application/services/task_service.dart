import '../../core/errors/task_exceptions.dart';
import '../../core/interfaces/repository.dart';
import '../../domain/models/priority.dart';
import '../../domain/models/regular_task.dart';
import '../../domain/models/sort_by.dart';
import '../../domain/models/task.dart';
import '../../domain/models/urgent_task.dart';

/// Service métier pour la gestion des tâches.
///
/// Dépend uniquement de `Repository<Task>` (inversion de dépendance) :
/// `JsonTaskRepository` (fichier JSON) ou `InMemoryRepository<Task>`.
class TaskService {
  final Repository<Task> _repository;
  int? _idCounter;

  TaskService(this._repository);

  /// Ajoute une tâche.
  /// Si [priority] est [Priority.high], crée une [UrgentTask]
  /// (`Task → UrgentTask`), sinon une [RegularTask].
  Future<Task> addTask({
    required String title,
    Priority priority = Priority.medium,
    DateTime? dueDate,
    String? urgencyNote,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw const InvalidTaskException(
        'Le titre de la tâche ne peut pas être vide.',
      );
    }
    if (trimmed.length > 200) {
      throw const InvalidTaskException(
        'Le titre ne peut pas dépasser 200 caractères.',
      );
    }

    final id = await _nextId();
    final Task task;
    if (priority == Priority.high) {
      task = UrgentTask(
        id: id,
        title: trimmed,
        dueDate: dueDate,
        urgencyNote: urgencyNote,
      );
    } else {
      task = RegularTask(
        id: id,
        title: trimmed,
        priority: priority,
        dueDate: dueDate,
      );
    }
    await _repository.add(task);
    return task;
  }

  /// Liste les tâches, éventuellement triées.
  Future<List<Task>> listTasks({SortBy sortBy = SortBy.priority}) {
    return _repository.findAllSorted(compare: TaskComparators.by(sortBy));
  }

  /// Marque la tâche [id] comme terminée.
  Future<Task> completeTask(String id) async {
    final task = await _requireTask(id);
    if (task.isCompleted) {
      throw InvalidTaskException('La tâche #$id est déjà terminée.');
    }
    task.complete();
    await _repository.update(task);
    return task;
  }

  /// Supprime la tâche [id].
  Future<void> deleteTask(String id) async {
    final deleted = await _repository.delete(id);
    if (!deleted) {
      throw TaskNotFoundException(id);
    }
  }

  Future<Task> _requireTask(String id) async {
    final task = await _repository.findById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }
    return task;
  }

  /// Génère le prochain id en s'alignant sur le max déjà persisté (JSON).
  Future<String> _nextId() async {
    _idCounter ??= await _maxPersistedId();
    _idCounter = _idCounter! + 1;
    return '$_idCounter';
  }

  Future<int> _maxPersistedId() async {
    final existing = await _repository.findAll();
    var maxId = 0;
    for (final t in existing) {
      final parsed = int.tryParse(t.id);
      if (parsed != null && parsed > maxId) {
        maxId = parsed;
      }
    }
    return maxId;
  }
}
