import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';

void main() {
  group('Héritage Task → UrgentTask', () {
    test('UrgentTask est une sous-classe de Task', () {
      final task = UrgentTask(id: '1', title: 'Incident prod');
      expect(task, isA<Task>());
      expect(task, isA<UrgentTask>());
    });

    test('UrgentTask force la priorité high', () {
      final task = UrgentTask(id: '1', title: 'Corriger le bug critique');
      expect(task.priority, Priority.high);
    });

    test('UrgentTask surcharge displayLabel et isUrgent', () {
      final task = UrgentTask(
        id: '1',
        title: 'Corriger le bug critique',
        urgencyNote: 'Production down',
      );
      expect(task.displayLabel, 'URGENT');
      expect(task.isUrgent, isTrue);
    });

    test('UrgentTask sérialise le type et la note d\'urgence', () {
      final task = UrgentTask(
        id: '1',
        title: 'Corriger le bug critique',
        urgencyNote: 'Production down',
      );
      final json = task.toJson();
      expect(json['type'], 'UrgentTask');
      expect(json['urgencyNote'], 'Production down');
      expect(json['priority'], 'high');
    });

    test('UrgentTask.fromJson restaure tous les champs', () {
      final original = UrgentTask(
        id: '9',
        title: 'Relancer le serveur',
        dueDate: DateTime(2026, 8, 11),
        urgencyNote: 'ASAP',
      );
      final restored = UrgentTask.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.priority, Priority.high);
      expect(restored.dueDate, original.dueDate);
      expect(restored.urgencyNote, 'ASAP');
      expect(restored.isUrgent, isTrue);
    });

    test('toString inclut la note d\'urgence', () {
      final task = UrgentTask(
        id: '1',
        title: 'Panne',
        urgencyNote: 'Site down',
      );
      expect(task.toString(), contains('note: Site down'));
      expect(task.toString(), contains('URGENT'));
    });
  });

  group('RegularTask (complément de la hiérarchie)', () {
    test('RegularTask étend Task sans être urgente', () {
      final task = RegularTask(
        id: '2',
        title: 'Préparer le rapport',
        priority: Priority.medium,
      );
      expect(task, isA<Task>());
      expect(task.isUrgent, isFalse);
      expect(task.displayLabel, 'Tâche');
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
    });

    test('isOverdue devient false après complete()', () {
      final task = RegularTask(
        id: '3',
        title: 'Tâche en retard',
        priority: Priority.low,
        dueDate: DateTime(2020, 1, 1),
      );
      task.complete();
      expect(task.isCompleted, isTrue);
      expect(task.isOverdue, isFalse);
    });

    test('isOverdue est false sans date limite', () {
      final task = RegularTask(
        id: '4',
        title: 'Sans échéance',
        priority: Priority.low,
      );
      expect(task.isOverdue, isFalse);
    });

    test('toString omet l\'échéance si dueDate est null', () {
      final task = RegularTask(
        id: '5',
        title: 'Sans date',
        priority: Priority.low,
      );
      expect(task.toString(), isNot(contains('échéance')));
      expect(task.toString(), contains('Sans date'));
    });

    test('toString formate dueDate en yyyy-MM-dd', () {
      final task = RegularTask(
        id: '6',
        title: 'Avec date',
        priority: Priority.low,
        dueDate: DateTime(2026, 8, 10),
      );
      expect(task.toString(), contains('échéance: 2026-08-10'));
    });
  });
}
