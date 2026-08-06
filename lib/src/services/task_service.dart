import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../models/regular_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import '../repositories/json_task_repository.dart';
import '../repositories/repository.dart';

/// Service métier pour la gestion des tâches.
class TaskService {
  final Repository<Task> _repository;
  int _idCounter = 0;

  TaskService(this._repository);

  /// Ajoute une tâche. Si [priority] est [Priority.high], crée une [UrgentTask].
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
  Future<List<Task>> listTasks({SortBy sortBy = SortBy.priority}) async {
    final repo = _repository;
    if (repo is JsonTaskRepository) {
      return repo.findAllSorted(sortBy: sortBy);
    }
    final tasks = List<Task>.from(await repo.findAll());
    tasks.sort(
      (a, b) => b.priority.sortWeight.compareTo(a.priority.sortWeight),
    );
    return tasks;
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

  Future<String> _nextId() async {
    final existing = await _repository.findAll();
    if (existing.isEmpty && _idCounter == 0) {
      _idCounter = 1;
      return '1';
    }
    var maxId = _idCounter;
    for (final t in existing) {
      final parsed = int.tryParse(t.id);
      if (parsed != null && parsed > maxId) {
        maxId = parsed;
      }
    }
    _idCounter = maxId + 1;
    return '$_idCounter';
  }
}
