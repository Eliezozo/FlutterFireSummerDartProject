import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';

void main() {
  group('Priority', () {
    test('fromString parse les valeurs valides', () {
      expect(Priority.fromString('low'), Priority.low);
      expect(Priority.fromString('MEDIUM'), Priority.medium);
      expect(Priority.fromString('high'), Priority.high);
    });

    test('fromString lève FormatException pour une valeur invalide', () {
      expect(
        () => Priority.fromString('critique'),
        throwsA(isA<FormatException>()),
      );
    });

    test('sortWeight ordonne high > medium > low', () {
      expect(Priority.high.sortWeight, greaterThan(Priority.medium.sortWeight));
      expect(
        Priority.medium.sortWeight,
        greaterThan(Priority.low.sortWeight),
      );
    });
  });

  group('Task / UrgentTask (héritage)', () {
    test('UrgentTask force la priorité high', () {
      final task = UrgentTask(
        id: '1',
        title: 'Corriger le bug critique',
        urgencyNote: 'Production down',
      );
      expect(task, isA<Task>());
      expect(task.priority, Priority.high);
      expect(task.displayLabel, 'URGENT');
      expect(task.toJson()['type'], 'UrgentTask');
      expect(task.toJson()['urgencyNote'], 'Production down');
    });

    test('RegularTask sérialise et désérialise correctement', () {
      final original = RegularTask(
        id: '2',
        title: 'Préparer le rapport',
        priority: Priority.medium,
        dueDate: DateTime(2026, 8, 15),
      );
      final restored = RegularTask.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.priority, original.priority);
      expect(restored.dueDate, original.dueDate);
      expect(restored.isCompleted, isFalse);
    });

    test('isOverdue est true si la date limite est passée', () {
      final task = RegularTask(
        id: '3',
        title: 'Tâche en retard',
        priority: Priority.low,
        dueDate: DateTime(2020, 1, 1),
      );
      expect(task.isOverdue, isTrue);
      task.complete();
      expect(task.isOverdue, isFalse);
    });
  });

  group('JsonTaskRepository (génériques + persistance)', () {
    late Directory tempDir;
    late JsonTaskRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('task_manager_test_');
      repository = JsonTaskRepository(
        filePath: p.join(tempDir.path, 'tasks.json'),
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('add et findAll persistent dans le fichier JSON', () async {
      final task = RegularTask(
        id: '10',
        title: 'Persister',
        priority: Priority.low,
      );
      await repository.add(task);

      expect(File(repository.filePath).existsSync(), isTrue);

      final reloaded = JsonTaskRepository(filePath: repository.filePath);
      final all = await reloaded.findAll();
      expect(all, hasLength(1));
      expect(all.first.title, 'Persister');
      expect(all.first, isA<RegularTask>());
    });

    test('findAllSorted trie par priorité décroissante', () async {
      await repository.add(
        RegularTask(id: '1', title: 'A', priority: Priority.low),
      );
      await repository.add(
        UrgentTask(id: '2', title: 'B'),
      );
      await repository.add(
        RegularTask(id: '3', title: 'C', priority: Priority.medium),
      );

      final sorted = await repository.findAllSorted(sortBy: SortBy.priority);
      expect(sorted.map((t) => t.priority).toList(), [
        Priority.high,
        Priority.medium,
        Priority.low,
      ]);
    });

    test('delete retourne false si la tâche n\'existe pas', () async {
      final result = await repository.delete('999');
      expect(result, isFalse);
    });
  });

  group('TaskService (exceptions personnalisées)', () {
    late Directory tempDir;
    late TaskService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('task_service_test_');
      final repo = JsonTaskRepository(
        filePath: p.join(tempDir.path, 'tasks.json'),
      );
      service = TaskService(repo);
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('addTask refuse un titre vide', () async {
      expect(
        () => service.addTask(title: '   '),
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
      expect((task as UrgentTask).urgencyNote, 'ASAP');
    });

    test('completeTask lève TaskNotFoundException', () async {
      expect(
        () => service.completeTask('inconnu'),
        throwsA(isA<TaskNotFoundException>()),
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
  });

  group('Serializable (interface)', () {
    test('Task implémente Serializable', () {
      final task = RegularTask(
        id: '1',
        title: 'Interface',
        priority: Priority.low,
      );
      expect(task, isA<Serializable>());
      expect(task.toJson(), containsPair('title', 'Interface'));
    });
  });
}
