import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';

void main() {
  group('JsonTaskRepository', () {
    late Directory tempDir;
    late JsonTaskRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('task_repo_test_');
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

    test('restaure une UrgentTask depuis le JSON', () async {
      await repository.add(
        UrgentTask(id: '1', title: 'Critique', urgencyNote: 'P0'),
      );

      final reloaded = JsonTaskRepository(filePath: repository.filePath);
      final all = await reloaded.findAll();
      expect(all.first, isA<UrgentTask>());
      expect((all.first as UrgentTask).urgencyNote, 'P0');
    });

    test('findAllBySort trie par priorité décroissante', () async {
      await repository.add(
        RegularTask(id: '1', title: 'A', priority: Priority.low),
      );
      await repository.add(UrgentTask(id: '2', title: 'B'));
      await repository.add(
        RegularTask(id: '3', title: 'C', priority: Priority.medium),
      );

      final sorted = await repository.findAllBySort(SortBy.priority);
      expect(sorted.map((t) => t.priority).toList(), [
        Priority.high,
        Priority.medium,
        Priority.low,
      ]);
    });

    test('findAllSorted trie par date d\'échéance', () async {
      await repository.add(
        RegularTask(
          id: '1',
          title: 'Plus tard',
          priority: Priority.low,
          dueDate: DateTime(2026, 12, 1),
        ),
      );
      await repository.add(
        RegularTask(
          id: '2',
          title: 'Plus tôt',
          priority: Priority.low,
          dueDate: DateTime(2026, 1, 1),
        ),
      );

      final sorted = await repository.findAllSorted(
        compare: TaskComparators.by(SortBy.dueDate),
      );
      expect(sorted.map((t) => t.id).toList(), ['2', '1']);
    });

    test('findAllSorted trie par date de création', () async {
      await repository.add(
        RegularTask(
          id: '1',
          title: 'Ancienne',
          priority: Priority.low,
          createdAt: DateTime(2024, 1, 1),
        ),
      );
      await repository.add(
        RegularTask(
          id: '2',
          title: 'Récente',
          priority: Priority.low,
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final sorted = await repository.findAllBySort(SortBy.createdAt);
      expect(sorted.map((t) => t.id).toList(), ['1', '2']);
    });

    test('delete retourne false si la tâche n\'existe pas', () async {
      final result = await repository.delete('999');
      expect(result, isFalse);
    });

    test('update lève TaskNotFoundException si absent', () async {
      expect(
        () => repository.update(
          RegularTask(id: '404', title: 'Nope', priority: Priority.low),
        ),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('add refuse un id déjà présent', () async {
      await repository.add(
        RegularTask(id: '1', title: 'A', priority: Priority.low),
      );
      expect(
        () => repository.add(
          RegularTask(id: '1', title: 'B', priority: Priority.low),
        ),
        throwsA(isA<InvalidTaskException>()),
      );
    });
  });
}
