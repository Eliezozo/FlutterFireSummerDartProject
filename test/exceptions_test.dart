import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';

void main() {
  group('Exceptions personnalisées', () {
    test('TaskNotFoundException étend TaskException', () {
      const e = TaskNotFoundException('99');
      expect(e, isA<TaskException>());
      expect(e.taskId, '99');
      expect(e.message, contains('99'));
      expect(e.toString(), contains('TaskNotFoundException'));
    });

    test('InvalidTaskException étend TaskException', () {
      const e = InvalidTaskException('Titre vide');
      expect(e, isA<TaskException>());
      expect(e.message, 'Titre vide');
    });

    test('PersistenceException étend TaskException', () {
      const e = PersistenceException('Disque plein');
      expect(e, isA<TaskException>());
      expect(e.message, 'Disque plein');
    });

    test('CliArgumentException étend TaskException', () {
      const e = CliArgumentException('ID obligatoire');
      expect(e, isA<TaskException>());
      expect(e.message, 'ID obligatoire');
    });

    test('toutes les exceptions personnalisées sont des Exception', () {
      const exceptions = <TaskException>[
        TaskNotFoundException('1'),
        InvalidTaskException('x'),
        PersistenceException('y'),
        CliArgumentException('z'),
      ];
      for (final e in exceptions) {
        expect(e, isA<Exception>());
        expect(e.toString(), isNotEmpty);
      }
    });
  });
}
