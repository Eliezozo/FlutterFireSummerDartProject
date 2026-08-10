/// Interface : toute entité persistée possède un identifiant unique.
///
/// Utilisée comme contrainte générique de [Repository] et des dépôts.
abstract interface class Identifiable {
  String get id;
}
