/// Bibliothèque principale — Task Manager CLI.
///
/// Architecture en couches :
/// présentation → application → data → domain ← core
library;

export 'src/application/services/task_service.dart';
export 'src/core/errors/task_exceptions.dart';
export 'src/core/interfaces/identifiable.dart';
export 'src/core/interfaces/persistable.dart';
export 'src/core/interfaces/repository.dart';
export 'src/core/interfaces/serializable.dart';
export 'src/data/repositories/in_memory_repository.dart';
export 'src/data/repositories/json_file_repository.dart';
export 'src/data/repositories/json_task_repository.dart';
export 'src/domain/models/priority.dart';
export 'src/domain/models/regular_task.dart';
export 'src/domain/models/sort_by.dart';
export 'src/domain/models/task.dart';
export 'src/domain/models/urgent_task.dart';
export 'src/presentation/cli/cli_app.dart';
export 'src/presentation/cli/console_io.dart';
