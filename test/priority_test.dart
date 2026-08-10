import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';

void main() {
  group('Priority.fromString', () {
    test('parse les valeurs valides en minuscules', () {
      expect(Priority.fromString('low'), Priority.low);
      expect(Priority.fromString('medium'), Priority.medium);
      expect(Priority.fromString('high'), Priority.high);
    });

    test('parse les valeurs valides sans tenir compte de la casse', () {
      expect(Priority.fromString('LOW'), Priority.low);
      expect(Priority.fromString('Medium'), Priority.medium);
      expect(Priority.fromString('HIGH'), Priority.high);
    });

    test('ignore les espaces autour de la valeur', () {
      expect(Priority.fromString('  high  '), Priority.high);
    });

    test('lève FormatException pour une valeur invalide', () {
      expect(
        () => Priority.fromString('critique'),
        throwsA(isA<FormatException>()),
      );
    });

    test('lève FormatException pour une chaîne vide', () {
      expect(() => Priority.fromString(''), throwsA(isA<FormatException>()));
    });
  });

  group('Priority.sortWeight', () {
    test('ordonne high > medium > low', () {
      expect(Priority.high.sortWeight, greaterThan(Priority.medium.sortWeight));
      expect(Priority.medium.sortWeight, greaterThan(Priority.low.sortWeight));
    });

    test('toString retourne le nom de l\'énumération', () {
      expect(Priority.low.toString(), 'low');
      expect(Priority.medium.toString(), 'medium');
      expect(Priority.high.toString(), 'high');
    });
  });
}
