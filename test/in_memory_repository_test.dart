import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';

/// Entité fictive pour prouver que `Repository<T>` n'est pas figé à Task.
class _Note implements Identifiable {
  @override
  final String id;
  final String text;

  _Note({required this.id, required this.text});
}

void main() {
  group('InMemoryRepository<T> (génériques)', () {
    late InMemoryRepository<_Note> notes;

    setUp(() {
      notes = InMemoryRepository<_Note>();
    });

    test('add puis findAll retourne l\'entité', () async {
      await notes.add(_Note(id: 'n1', text: 'Acheter du café'));
      final all = await notes.findAll();
      expect(all, hasLength(1));
      expect(all.first.text, 'Acheter du café');
    });

    test('findById retourne null si absent', () async {
      expect(await notes.findById('inconnu'), isNull);
    });

    test('findById retourne l\'entité si présente', () async {
      await notes.add(_Note(id: 'n2', text: 'Relire le README'));
      final found = await notes.findById('n2');
      expect(found, isNotNull);
      expect(found!.text, 'Relire le README');
    });

    test('add refuse un id dupliqué', () async {
      await notes.add(_Note(id: 'n1', text: 'A'));
      expect(
        () => notes.add(_Note(id: 'n1', text: 'B')),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('update remplace l\'entité existante', () async {
      await notes.add(_Note(id: 'n1', text: 'Ancien'));
      await notes.update(_Note(id: 'n1', text: 'Nouveau'));
      final found = await notes.findById('n1');
      expect(found!.text, 'Nouveau');
    });

    test('update lève TaskNotFoundException si absent', () async {
      expect(
        () => notes.update(_Note(id: 'x', text: 'Nope')),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('delete retourne true puis false', () async {
      await notes.add(_Note(id: 'n1', text: 'À supprimer'));
      expect(await notes.delete('n1'), isTrue);
      expect(await notes.delete('n1'), isFalse);
    });

    test('findAllSorted trie avec le comparateur fourni', () async {
      await notes.add(_Note(id: '2', text: 'B'));
      await notes.add(_Note(id: '1', text: 'A'));
      await notes.add(_Note(id: '3', text: 'C'));

      final sorted = await notes.findAllSorted(
        compare: (a, b) => a.text.compareTo(b.text),
      );
      expect(sorted.map((n) => n.text).toList(), ['A', 'B', 'C']);
    });

    test('save est un no-op sans erreur', () async {
      await notes.add(_Note(id: 'n1', text: 'Ok'));
      await notes.save();
      expect(await notes.findAll(), hasLength(1));
    });
  });
}
