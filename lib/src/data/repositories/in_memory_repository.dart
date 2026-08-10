import '../../core/errors/task_exceptions.dart';
import '../../core/interfaces/identifiable.dart';
import '../../core/interfaces/repository.dart';

/// Implémentation générique en mémoire de [Repository].
///
/// Démontre que `Repository<T>` n'est pas limité aux tâches :
/// `InMemoryRepository<Task>`, `InMemoryRepository<Note>`, etc.
class InMemoryRepository<T extends Identifiable> implements Repository<T> {
  final List<T> _items = [];
  List<T> _persistedSnapshot = const [];

  @override
  Future<List<T>> findAll() async => List.unmodifiable(_items);

  @override
  Future<List<T>> findAllSorted({int Function(T a, T b)? compare}) async {
    final copy = List<T>.from(_items);
    if (compare != null) {
      copy.sort(compare);
    }
    return copy;
  }

  @override
  Future<T?> findById(String id) async {
    try {
      return _items.firstWhere((e) => e.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> add(T entity) async {
    if (_items.any((e) => e.id == entity.id)) {
      throw InvalidTaskException(
        'Une entité avec l\'id "${entity.id}" existe déjà.',
      );
    }
    _items.add(entity);
    await save();
  }

  @override
  Future<void> update(T entity) async {
    final index = _items.indexWhere((e) => e.id == entity.id);
    if (index < 0) {
      throw TaskNotFoundException(entity.id);
    }
    _items[index] = entity;
    await save();
  }

  @override
  Future<bool> delete(String id) async {
    final initial = _items.length;
    _items.removeWhere((e) => e.id == id);
    if (_items.length == initial) return false;
    await save();
    return true;
  }

  /// Persiste un snapshot mémoire (équivalent fichier pour les tests).
  @override
  Future<void> save() async {
    _persistedSnapshot = List<T>.from(_items);
  }

  /// Dernier snapshot persisté par [save].
  List<T> get persistedSnapshot => List.unmodifiable(_persistedSnapshot);
}
