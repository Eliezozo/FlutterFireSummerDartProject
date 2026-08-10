/// Interface de sérialisation JSON.
///
/// En Dart 3, `abstract interface class` définit un contrat pur :
/// aucun état, uniquement des membres abstraits. Les types concrets
/// l'utilisent via `implements` (et non `extends`).
abstract interface class Serializable {
  /// Convertit l'objet en map JSON-compatible.
  Map<String, dynamic> toJson();
}
