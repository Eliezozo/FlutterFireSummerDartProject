import 'identifiable.dart';

/// Interface générique de dépôt CRUD — `Repository<T>`.
///
/// [T] est le type d'entité gérée. Exemples :
/// - `Repository<Task>`
/// - `InMemoryRepository<Note>`
/// - `JsonFileRepository<T extends Persistable>`
///
/// Cette interface n'est **pas** figée à un type métier : chaque
/// implémentation choisit son `T`.
abstract interface class Repository<T extends Identifiable> {
  /// Retourne toutes les entités.
  Future<List<T>> findAll();

  /// Retourne toutes les entités, éventuellement triées par [compare].
  Future<List<T>> findAllSorted({int Function(T a, T b)? compare});

  /// Retourne l'entité d'identifiant [id], ou `null` si absente.
  Future<T?> findById(String id);

  /// Ajoute une entité et la persiste.
  Future<void> add(T entity);

  /// Met à jour une entité existante.
  Future<void> update(T entity);

  /// Supprime l'entité d'identifiant [id].
  /// Retourne `true` si une entité a été supprimée.
  Future<bool> delete(String id);

  /// Persiste l'état courant (no-op pour un dépôt mémoire).
  Future<void> save();
}
