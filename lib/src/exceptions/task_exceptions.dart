/// Exception de base pour toutes les erreurs liées aux tâches.
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

/// Levée lorsque le titre d'une tâche est invalide.
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
