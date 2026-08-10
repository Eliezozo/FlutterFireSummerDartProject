/// Exception de base pour toutes les erreurs liées aux tâches.
///
/// Toutes les exceptions métier héritent de [TaskException] afin
/// que la couche présentation puisse les distinguer et les afficher
/// avec un message adapté.
abstract class TaskException implements Exception {
  final String message;

  const TaskException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Levée lorsqu'une tâche introuvable est demandée.
class TaskNotFoundException extends TaskException {
  final String taskId;

  const TaskNotFoundException(this.taskId)
    : super('Tâche introuvable: $taskId');
}

/// Levée lorsque les données d'une tâche sont invalides
/// (titre vide, déjà terminée, id dupliqué, etc.).
class InvalidTaskException extends TaskException {
  const InvalidTaskException(super.message);
}

/// Levée en cas d'échec de lecture/écriture du fichier de persistance.
class PersistenceException extends TaskException {
  const PersistenceException(super.message);
}

/// Levée lorsqu'une opération CLI reçoit des arguments incorrects.
class CliArgumentException extends TaskException {
  const CliArgumentException(super.message);
}
