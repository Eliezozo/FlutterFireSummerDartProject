import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/regular_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import 'repository.dart';

/// Critères de tri pour la liste des tâches.
enum SortBy { priority, dueDate, createdAt }

/// Dépôt de tâches persisté dans un fichier JSON local.
class JsonTaskRepository implements Repository<Task> {
  final File _file;
  final List<Task> _cache = [];
  bool _loaded = false;

  JsonTaskRepository({required String filePath}) : _file = File(filePath);

  /// Chemin du fichier de persistance.
  String get filePath => _file.path;

  @override
  Future<List<Task>> findAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_cache);
  }

  /// Retourne les tâches triées selon [sortBy].
  Future<List<Task>> findAllSorted({SortBy sortBy = SortBy.priority}) async {
    final tasks = List<Task>.from(await findAll());
    switch (sortBy) {
      case SortBy.priority:
        tasks.sort((a, b) {
          final byPriority =
              b.priority.sortWeight.compareTo(a.priority.sortWeight);
          if (byPriority != 0) return byPriority;
          return a.createdAt.compareTo(b.createdAt);
        });
      case SortBy.dueDate:
        tasks.sort((a, b) {
          final aDue = a.dueDate;
          final bDue = b.dueDate;
          if (aDue == null && bDue == null) return 0;
          if (aDue == null) return 1;
          if (bDue == null) return -1;
          return aDue.compareTo(bDue);
        });
      case SortBy.createdAt:
        tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return tasks;
  }

  @override
  Future<Task?> findById(String id) async {
    await _ensureLoaded();
    try {
      return _cache.firstWhere((t) => t.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> add(Task entity) async {
    await _ensureLoaded();
    if (_cache.any((t) => t.id == entity.id)) {
      throw InvalidTaskException(
        'Une tâche avec l\'id "${entity.id}" existe déjà.',
      );
    }
    _cache.add(entity);
    await save();
  }

  @override
  Future<void> update(Task entity) async {
    await _ensureLoaded();
    final index = _cache.indexWhere((t) => t.id == entity.id);
    if (index < 0) {
      throw TaskNotFoundException(entity.id);
    }
    _cache[index] = entity;
    await save();
  }

  @override
  Future<bool> delete(String id) async {
    await _ensureLoaded();
    final initial = _cache.length;
    _cache.removeWhere((t) => t.id == id);
    if (_cache.length == initial) return false;
    await save();
    return true;
  }

  @override
  Future<void> save() async {
    try {
      final dir = _file.parent;
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      final payload = {
        'version': 1,
        'tasks': _cache.map((t) => t.toJson()).toList(),
      };
      await _file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload),
      );
    } on FileSystemException catch (e) {
      throw PersistenceException(
        'Impossible d\'écrire le fichier "${_file.path}": ${e.message}',
      );
    }
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _load();
    _loaded = true;
  }

  Future<void> _load() async {
    if (!_file.existsSync()) {
      _cache.clear();
      return;
    }
    try {
      final content = await _file.readAsString();
      if (content.trim().isEmpty) {
        _cache.clear();
        return;
      }
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final rawTasks = decoded['tasks'] as List<dynamic>? ?? [];
      _cache
        ..clear()
        ..addAll(rawTasks.map((e) => _fromJson(e as Map<String, dynamic>)));
    } on FormatException catch (e) {
      throw PersistenceException(
        'Fichier JSON corrompu "${_file.path}": ${e.message}',
      );
    } on FileSystemException catch (e) {
      throw PersistenceException(
        'Impossible de lire "${_file.path}": ${e.message}',
      );
    }
  }

  /// Factory pour reconstruire le bon sous-type depuis le JSON.
  static Task _fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'RegularTask';
    if (type == 'UrgentTask') {
      return UrgentTask.fromJson(json);
    }
    return RegularTask.fromJson(json);
  }
}
