/// Interface générique de dépôt (CRUD).
///
/// [T] est le type d'entité gérée par le dépôt.
abstract class Repository<T> {
  /// Retourne toutes les entités.
  Future<List<T>> findAll();

  /// Retourne l'entité d'identifiant [id], ou `null` si absente.
  Future<T?> findById(String id);

  /// Ajoute une entité et la persiste.
  Future<void> add(T entity);

  /// Met à jour une entité existante.
  Future<void> update(T entity);

  /// Supprime l'entité d'identifiant [id].
  /// Retourne `true` si une entité a été supprimée.
  Future<bool> delete(String id);

  /// Persiste l'état courant.
  Future<void> save();
}
