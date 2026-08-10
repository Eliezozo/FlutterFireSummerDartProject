import 'dart:io' as io;

/// Interface d'entrée/sortie console — permet de tester la CLI sans stdin réel.
abstract interface class ConsoleIo {
  String? readLine(String prompt);
  void writeln(String message);
}

/// Implémentation réelle via `stdin` / `stdout`.
class StdConsoleIo implements ConsoleIo {
  final io.Stdin _stdin;
  final io.Stdout _stdout;

  StdConsoleIo({io.Stdin? stdin, io.Stdout? stdout})
    : _stdin = stdin ?? io.stdin,
      _stdout = stdout ?? io.stdout;

  @override
  String? readLine(String prompt) {
    _stdout.write('$prompt: ');
    return _stdin.readLineSync();
  }

  @override
  void writeln(String message) => _stdout.writeln(message);
}
