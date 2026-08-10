import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';

void main() {
  group('Interface Serializable', () {
    test('Task implémente Serializable via Persistable', () {
      final task = RegularTask(
        id: '1',
        title: 'Interface',
        priority: Priority.low,
      );
      expect(task, isA<Serializable>());
      expect(task, isA<Identifiable>());
      expect(task, isA<Persistable>());
    });

    test('toJson contient les clés attendues', () {
      final task = RegularTask(
        id: '1',
        title: 'Interface',
        priority: Priority.low,
      );
      final json = task.toJson();
      expect(json, containsPair('title', 'Interface'));
      expect(json, containsPair('id', '1'));
      expect(json, containsPair('priority', 'low'));
      expect(json, containsPair('isCompleted', false));
      expect(json.containsKey('createdAt'), isTrue);
      expect(json.containsKey('type'), isTrue);
    });

    test('UrgentTask implémente aussi Serializable', () {
      final task = UrgentTask(id: '2', title: 'Urgent');
      expect(task, isA<Serializable>());
      expect(task.toJson()['type'], 'UrgentTask');
    });

    test('Identifiable expose l\'id', () {
      final Identifiable entity = RegularTask(
        id: '42',
        title: 'Id',
        priority: Priority.medium,
      );
      expect(entity.id, '42');
    });

    test('Persistable combine Identifiable et Serializable', () {
      final Persistable entity = UrgentTask(id: '7', title: 'Combo');
      expect(entity.id, '7');
      expect(entity.toJson(), isA<Map<String, dynamic>>());
    });
  });
}
