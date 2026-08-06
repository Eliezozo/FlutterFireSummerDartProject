/// Niveau de priorité d'une tâche.
enum Priority {
  low,
  medium,
  high;

  /// Valeur numérique pour le tri (high = 3, medium = 2, low = 1).
  int get sortWeight => switch (this) {
        Priority.high => 3,
        Priority.medium => 2,
        Priority.low => 1,
      };

  /// Parse une chaîne en [Priority], lève [FormatException] si invalide.
  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (p) => p.name == value.toLowerCase().trim(),
      orElse: () => throw FormatException(
        'Priorité invalide: "$value". Valeurs acceptées: low, medium, high.',
      ),
    );
  }

  @override
  String toString() => name;
}
