import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';

/// Entité générique pour tester `JsonFileRepository<T>` hors des tâches.
class _Note implements Persistable {
  @override
  final String id;
  final String text;

  _Note({required this.id, required this.text});

  @override
  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

class _NoteRepository extends JsonFileRepository<_Note> {
  _NoteRepository({required super.filePath});

  @override
  String get collectionKey => 'notes';

  @override
  _Note deserialize(Map<String, dynamic> json) =>
      _Note(id: json['id'] as String, text: json['text'] as String);
}

void main() {
  group('JsonFileRepository<T> (génériques + JSON)', () {
    late Directory tempDir;
    late _NoteRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('json_repo_test_');
      repository = _NoteRepository(
        filePath: p.join(tempDir.path, 'notes.json'),
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('persiste et recharge une collection générique', () async {
      await repository.add(_Note(id: '1', text: 'Hello'));

      expect(File(repository.filePath).existsSync(), isTrue);

      final reloaded = _NoteRepository(filePath: repository.filePath);
      final all = await reloaded.findAll();
      expect(all, hasLength(1));
      expect(all.first.text, 'Hello');
    });

    test(
      'findAll retourne une liste vide si le fichier n\'existe pas',
      () async {
        final all = await repository.findAll();
        expect(all, isEmpty);
      },
    );

    test('lève PersistenceException si le JSON est corrompu', () async {
      final file = File(repository.filePath);
      await file.create(recursive: true);
      await file.writeAsString('{ pas du json');

      expect(() => repository.findAll(), throwsA(isA<PersistenceException>()));
    });

    test('invalidateCache force un rechargement depuis le disque', () async {
      await repository.add(_Note(id: '1', text: 'A'));

      final file = File(repository.filePath);
      await file.writeAsString(
        '{"version":1,"notes":[{"id":"1","text":"Modifié"}]}',
      );

      repository.invalidateCache();
      final all = await repository.findAll();
      expect(all.first.text, 'Modifié');
    });

    test('delete persiste la suppression', () async {
      await repository.add(_Note(id: '1', text: 'A'));
      await repository.add(_Note(id: '2', text: 'B'));
      expect(await repository.delete('1'), isTrue);

      final reloaded = _NoteRepository(filePath: repository.filePath);
      final all = await reloaded.findAll();
      expect(all.map((n) => n.id), ['2']);
    });

    test('fichier vide est traité comme collection vide', () async {
      final file = File(repository.filePath);
      await file.create(recursive: true);
      await file.writeAsString('   ');
      expect(await repository.findAll(), isEmpty);
    });
  });
}
