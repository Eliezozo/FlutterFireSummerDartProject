import 'dart:convert';
import 'dart:io';

import '../../core/errors/task_exceptions.dart';
import '../../core/interfaces/persistable.dart';
import '../../core/interfaces/repository.dart';

/// Dépôt générique persisté dans un fichier JSON.
///
/// [T] doit être [Persistable] (identifiable + sérialisable).
/// Les sous-classes fournissent uniquement [collectionKey] et [deserialize].
///
/// Exemple : `_NoteRepository extends JsonFileRepository<_Note>` (voir tests).
/// Le dépôt tâches (`JsonTaskRepository`) implémente `Repository<Task>`
/// directement afin d'exposer `add` / `update` / `save` + `writeAsString`.
abstract class JsonFileRepository<T extends Persistable>
    implements Repository<T> {
  final File _file;
  final List<T> _cache = [];
  bool _loaded = false;

  JsonFileRepository({required String filePath}) : _file = File(filePath);

  /// Chemin du fichier de persistance.
  String get filePath => _file.path;

  /// Clé JSON de la collection (ex: `tasks`).
  String get collectionKey;

  /// Reconstruit une entité depuis une map JSON.
  T deserialize(Map<String, dynamic> json);

  /// Invalide le cache mémoire (rechargement disque au prochain accès).
  void invalidateCache() {
    _cache.clear();
    _loaded = false;
  }

  @override
  Future<List<T>> findAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_cache);
  }

  @override
  Future<List<T>> findAllSorted({int Function(T a, T b)? compare}) async {
    final items = List<T>.from(await findAll());
    if (compare != null) {
      items.sort(compare);
    }
    return items;
  }

  @override
  Future<T?> findById(String id) async {
    await _ensureLoaded();
    try {
      return _cache.firstWhere((e) => e.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> add(T entity) async {
    await _ensureLoaded();
    if (_cache.any((e) => e.id == entity.id)) {
      throw InvalidTaskException(
        'Une entité avec l\'id "${entity.id}" existe déjà.',
      );
    }
    _cache.add(entity);
    await save();
  }

  @override
  Future<void> update(T entity) async {
    await _ensureLoaded();
    final index = _cache.indexWhere((e) => e.id == entity.id);
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
    _cache.removeWhere((e) => e.id == id);
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
        collectionKey: _cache.map((e) => e.toJson()).toList(),
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
      final raw = decoded[collectionKey] as List<dynamic>? ?? [];
      _cache
        ..clear()
        ..addAll(raw.map((e) => deserialize(e as Map<String, dynamic>)));
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
}
