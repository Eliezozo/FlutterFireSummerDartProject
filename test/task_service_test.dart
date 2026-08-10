import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';

void main() {
  group('TaskService', () {
    late TaskService service;

    setUp(() {
      service = TaskService(InMemoryRepository<Task>());
    });

    test('addTask refuse un titre vide', () async {
      expect(
        () => service.addTask(title: '   '),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('addTask refuse un titre trop long', () async {
      expect(
        () => service.addTask(title: 'x' * 201),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('addTask crée une UrgentTask pour priority high', () async {
      final task = await service.addTask(
        title: 'Urgent!',
        priority: Priority.high,
        urgencyNote: 'ASAP',
      );
      expect(task, isA<UrgentTask>());
      expect(task.isUrgent, isTrue);
      expect((task as UrgentTask).urgencyNote, 'ASAP');
    });

    test('addTask crée une RegularTask pour priority medium', () async {
      final task = await service.addTask(
        title: 'Normale',
        priority: Priority.medium,
      );
      expect(task, isA<RegularTask>());
      expect(task.isUrgent, isFalse);
    });

    test('completeTask lève TaskNotFoundException', () async {
      expect(
        () => service.completeTask('inconnu'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('completeTask lève InvalidTaskException si déjà terminée', () async {
      final task = await service.addTask(title: 'Déjà faite');
      await service.completeTask(task.id);
      expect(
        () => service.completeTask(task.id),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('cycle complet: add → complete → delete', () async {
      final task = await service.addTask(
        title: 'Cycle',
        priority: Priority.medium,
        dueDate: DateTime(2026, 12, 31),
      );
      expect(task.isCompleted, isFalse);

      final completed = await service.completeTask(task.id);
      expect(completed.isCompleted, isTrue);

      await service.deleteTask(task.id);
      final remaining = await service.listTasks();
      expect(remaining, isEmpty);
    });

    test('deleteTask lève TaskNotFoundException', () async {
      expect(
        () => service.deleteTask('42'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('listTasks trie par priorité par défaut', () async {
      await service.addTask(title: 'Basse', priority: Priority.low);
      await service.addTask(title: 'Haute', priority: Priority.high);
      await service.addTask(title: 'Moyenne', priority: Priority.medium);

      final listed = await service.listTasks();
      expect(listed.map((t) => t.priority).toList(), [
        Priority.high,
        Priority.medium,
        Priority.low,
      ]);
    });

    test('les ids sont incrémentés séquentiellement', () async {
      final a = await service.addTask(title: 'A');
      final b = await service.addTask(title: 'B');
      expect(a.id, '1');
      expect(b.id, '2');
    });
  });

  group('TaskService + JsonTaskRepository (ids persistés)', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('task_ids_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('le prochain id reprend après rechargement du JSON', () async {
      final filePath = p.join(tempDir.path, 'tasks.json');
      final first = TaskService(JsonTaskRepository(filePath: filePath));
      await first.addTask(title: 'Existante');
      await first.addTask(title: 'Deuxième');

      final reloaded = TaskService(JsonTaskRepository(filePath: filePath));
      final next = await reloaded.addTask(title: 'Nouvelle');
      expect(next.id, '3');
    });
  });
}
