import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:task_manager/task_manager.dart';

/// Point d'entrée de l'application CLI Task Manager.
Future<void> main(List<String> arguments) async {
  final dataPath = arguments.isNotEmpty
      ? arguments.first
      : p.join(Directory.current.path, 'data', 'tasks.json');

  final repository = JsonTaskRepository(filePath: dataPath);
  final service = TaskService(repository);
  final app = CliApp(service: service);

  await app.run();
}
