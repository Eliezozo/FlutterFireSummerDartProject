/// Interface de sérialisation JSON.
///
/// En Dart, une interface est une classe abstraite utilisée via `implements`.
abstract class Serializable {
  /// Convertit l'objet en map JSON-compatible.
  Map<String, dynamic> toJson();
}
