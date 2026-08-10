import 'dart:convert';
import 'dart:io';

import '../../core/errors/task_exceptions.dart';
import '../../core/interfaces/repository.dart';
import '../../domain/models/regular_task.dart';
import '../../domain/models/sort_by.dart';
import '../../domain/models/task.dart';
import '../../domain/models/urgent_task.dart';

/// Dépôt de tâches persisté dans un fichier JSON local.
///
/// Implémente `Repository<Task>` **en entier** : `add`, `update`, `delete`
/// et `save` écrivent réellement sur le disque via [File.writeAsString].
///
/// Fichier par défaut : `data/tasks.json`.
class JsonTaskRepository implements Repository<Task> {
  final File _file;
  final List<Task> _cache = [];
  bool _loaded = false;

  JsonTaskRepository({required String filePath}) : _file = File(filePath);

  /// Chemin du fichier JSON de persistance.
  String get filePath => _file.path;

  /// Invalide le cache (prochain accès = relecture du fichier).
  void invalidateCache() {
    _cache.clear();
    _loaded = false;
  }

  @override
  Future<List<Task>> findAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_cache);
  }

  @override
  Future<List<Task>> findAllSorted({
    int Function(Task a, Task b)? compare,
  }) async {
    final tasks = List<Task>.from(await findAll());
    if (compare != null) {
      tasks.sort(compare);
    }
    return tasks;
  }

  /// Tri métier via [SortBy].
  Future<List<Task>> findAllBySort(SortBy sortBy) {
    return findAllSorted(compare: TaskComparators.by(sortBy));
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

  /// Ajoute une tâche et l'écrit dans le fichier JSON.
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

  /// Met à jour une tâche existante et réécrit le fichier JSON.
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

  /// Supprime une tâche et réécrit le fichier JSON.
  @override
  Future<bool> delete(String id) async {
    await _ensureLoaded();
    final initial = _cache.length;
    _cache.removeWhere((t) => t.id == id);
    if (_cache.length == initial) return false;
    await save();
    return true;
  }

  /// Écrit le cache courant dans le fichier JSON (persistance réelle).
  @override
  Future<void> save() async {
    try {
      final dir = _file.parent;
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      final payload = <String, dynamic>{
        'version': 1,
        'tasks': _cache.map((t) => t.toJson()).toList(),
      };
      final jsonContents = const JsonEncoder.withIndent('  ').convert(payload);
      await _file.writeAsString(jsonContents, flush: true);
    } on PathAccessException catch (e) {
      throw PersistenceException(
        'Permission refusée pour écrire "${_file.path}": ${e.message}',
      );
    } on PathNotFoundException catch (e) {
      throw PersistenceException(
        'Chemin introuvable pour "${_file.path}": ${e.message}',
      );
    } on FileSystemException catch (e) {
      throw PersistenceException(
        'Impossible d\'écrire le fichier JSON "${_file.path}": ${e.message}',
      );
    } catch (e) {
      throw PersistenceException(
        'Erreur inattendue lors de la sauvegarde JSON: $e',
      );
    }
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _load();
    _loaded = true;
  }

  /// Lit le fichier JSON et reconstruit les [Task].
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
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        throw const PersistenceException(
          'Le fichier JSON doit contenir un objet racine.',
        );
      }
      final rawTasks = decoded['tasks'] as List<dynamic>? ?? [];
      _cache
        ..clear()
        ..addAll(rawTasks.map((e) => _taskFromJson(e as Map<String, dynamic>)));
    } on PersistenceException {
      rethrow;
    } on FormatException catch (e) {
      throw PersistenceException(
        'Fichier JSON corrompu "${_file.path}": ${e.message}',
      );
    } on PathAccessException catch (e) {
      throw PersistenceException(
        'Permission refusée pour lire "${_file.path}": ${e.message}',
      );
    } on FileSystemException catch (e) {
      throw PersistenceException(
        'Impossible de lire le fichier JSON "${_file.path}": ${e.message}',
      );
    }
  }

  static Task _taskFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'RegularTask';
    if (type == 'UrgentTask') {
      return UrgentTask.fromJson(json);
    }
    return RegularTask.fromJson(json);
  }
}
