import 'identifiable.dart';
import 'serializable.dart';

/// Entité identifiable et sérialisable.
///
/// Contrainte générique du dépôt JSON : `JsonFileRepository<T extends Persistable>`.
abstract interface class Persistable implements Identifiable, Serializable {}
