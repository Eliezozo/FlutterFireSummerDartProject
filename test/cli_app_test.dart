import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';

class _FakeConsoleIo implements ConsoleIo {
  final List<String> inputs;
  final StringBuffer output = StringBuffer();
  int _index = 0;

  _FakeConsoleIo(this.inputs);

  @override
  String? readLine(String prompt) {
    output.writeln('$prompt:');
    if (_index >= inputs.length) return null;
    return inputs[_index++];
  }

  @override
  void writeln(String message) => output.writeln(message);
}

void main() {
  group('CliApp', () {
    late TaskService service;

    setUp(() {
      service = TaskService(InMemoryRepository<Task>());
    });

    Future<String> runWith(List<String> inputs) async {
      final io = _FakeConsoleIo(inputs);
      final app = CliApp(service: service, io: io);
      await app.run();
      return io.output.toString();
    }

    test('option 5 quitte proprement', () async {
      final out = await runWith(['5']);
      expect(out, contains('Au revoir'));
    });

    test('option invalide affiche un message d\'erreur', () async {
      final out = await runWith(['9', '5']);
      expect(out, contains('Option invalide'));
    });

    test('option 1 ajoute une tâche puis option 2 la liste', () async {
      final out = await runWith([
        '1',
        'Récolter le cacao',
        'medium',
        '',
        '2',
        'priority',
        '5',
      ]);
      expect(out, contains('Tâche ajoutée'));
      expect(out, contains('Récolter le cacao'));
      expect(await service.listTasks(), hasLength(1));
    });

    test('option 1 high crée une UrgentTask', () async {
      final out = await runWith([
        '1',
        'Irrigation en panne',
        'high',
        '',
        'Pompe HS',
        '5',
      ]);
      expect(out, contains('Tâche ajoutée'));
      expect(out, contains('URGENT'));
      final tasks = await service.listTasks();
      expect(tasks.first, isA<UrgentTask>());
    });

    test('option 3 affiche la liste avant de terminer', () async {
      await service.addTask(title: 'Semis', priority: Priority.low);
      final out = await runWith(['3', '1', '5']);
      expect(out, contains('── Tâches (1) ──'));
      expect(out, contains('Semis'));
      expect(out, contains('Tâche terminée'));
      expect((await service.listTasks()).first.isCompleted, isTrue);
    });

    test('option 4 affiche la liste avant de supprimer', () async {
      await service.addTask(title: 'Désherbage', priority: Priority.medium);
      final out = await runWith(['4', '1', '5']);
      expect(out, contains('── Tâches (1) ──'));
      expect(out, contains('Désherbage'));
      expect(out, contains('supprimée'));
      expect(await service.listTasks(), isEmpty);
    });

    test('option 3 sans tâches n\'exige pas d\'ID', () async {
      final out = await runWith(['3', '5']);
      expect(out, contains('Aucune tâche pour le moment.'));
      expect(out, isNot(contains('ID de la tâche à terminer')));
    });

    test('affiche Introuvable pour un id inconnu', () async {
      await service.addTask(title: 'Existante', priority: Priority.low);
      final out = await runWith(['3', '999', '5']);
      expect(out, contains('Introuvable'));
    });

    test('affiche Saisie incorrecte si le titre est vide', () async {
      final out = await runWith(['1', '', '5']);
      expect(out, contains('Saisie incorrecte'));
    });

    test('affiche Saisie incorrecte pour une date invalide', () async {
      final out = await runWith([
        '1',
        'Tâche datée',
        'low',
        'pas-une-date',
        '5',
      ]);
      expect(out, contains('Saisie incorrecte'));
      expect(out, contains('Date invalide'));
    });
  });
}
