import 'dart:io' as io;

import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../repositories/json_task_repository.dart';
import '../services/task_service.dart';

/// Application CLI interactive de gestion de tâches.
class CliApp {
  final TaskService _service;
  final io.Stdin _stdin;
  final io.Stdout _stdout;

  CliApp({
    required this._service,
    io.Stdin? stdin,
    io.Stdout? stdout,
  })  : _stdin = stdin ?? io.stdin,
        _stdout = stdout ?? io.stdout;

  /// Boucle principale du menu.
  Future<void> run() async {
    _println('');
    _println('╔══════════════════════════════════════╗');
    _println('║     Task Manager — CLI Dart          ║');
    _println('╚══════════════════════════════════════╝');
    _println('');

    var running = true;
    while (running) {
      _printMenu();
      final choice = _readLine('Votre choix')?.trim();
      _println('');
      try {
        switch (choice) {
          case '1':
            await _addTask();
          case '2':
            await _listTasks();
          case '3':
            await _completeTask();
          case '4':
            await _deleteTask();
          case '5':
            running = false;
            _println(' ========= Au revoir ! ==========');
          default:
            _println('Option invalide. Choisissez 1–5.');
        }
      } on TaskException catch (e) {
        _println('Erreur: ${e.message}');
      } on FormatException catch (e) {
        _println('Erreur: ${e.message}');
      }
      if (running) _println('');
    }
  }

  void _printMenu() {
    _println('── Menu ──────────────────────────────');
    _println('  1. Ajouter une tâche');
    _println('  2. Lister les tâches');
    _println('  3. Marquer une tâche comme terminée');
    _println('  4. Supprimer une tâche');
    _println('  5. Quitter');
    _println('──────────────────────────────────────');
  }

  Future<void> _addTask() async {
    final title = _readLine('Titre de la tâche');
    if (title == null || title.trim().isEmpty) {
      throw const CliArgumentException('Le titre est obligatoire.');
    }

    final priorityRaw =
        _readLine('Priorité (low / medium / high) [medium]') ?? 'medium';
    final priorityInput =
        priorityRaw.trim().isEmpty ? 'medium' : priorityRaw.trim();
    final priority = Priority.fromString(priorityInput);

    final dueRaw = _readLine('Date limite (YYYY-MM-DD, optionnel)');
    DateTime? dueDate;
    if (dueRaw != null && dueRaw.trim().isNotEmpty) {
      dueDate = DateTime.parse(dueRaw.trim());
    }

    String? urgencyNote;
    if (priority == Priority.high) {
      urgencyNote = _readLine('Note d\'urgence (optionnel)');
      if (urgencyNote != null && urgencyNote.trim().isEmpty) {
        urgencyNote = null;
      }
    }

    final task = await _service.addTask(
      title: title,
      priority: priority,
      dueDate: dueDate,
      urgencyNote: urgencyNote,
    );
    _println('Tâche ajoutée: $task');
  }

  Future<void> _listTasks() async {
    final sortRaw =
        _readLine('Trier par (priority / date / created) [priority]') ??
            'priority';
    final sortKey = sortRaw.trim().isEmpty ? 'priority' : sortRaw.trim();
    final sortBy = switch (sortKey.toLowerCase()) {
      'date' || 'duedate' || 'due' => SortBy.dueDate,
      'created' || 'createdat' => SortBy.createdAt,
      'priority' => SortBy.priority,
      _ => throw CliArgumentException(
          'Tri invalide: "$sortKey". Utilisez: priority, date, created.',
        ),
    };

    await _displayTasks(sortBy: sortBy);
  }

  /// Affiche la liste des tâches enregistrées.
  /// Retourne `false` s'il n'y a aucune tâche.
  Future<bool> _displayTasks({SortBy sortBy = SortBy.priority}) async {
    final tasks = await _service.listTasks(sortBy: sortBy);
    if (tasks.isEmpty) {
      _println('Aucune tâche pour le moment.');
      return false;
    }
    _println('── Tâches (${tasks.length}) ──');
    for (final task in tasks) {
      _println('  $task');
    }
    return true;
  }

  Future<void> _completeTask() async {
    final hasTasks = await _displayTasks();
    if (!hasTasks) return;

    _println('');
    final id = _readLine('ID de la tâche à terminer');
    if (id == null || id.trim().isEmpty) {
      throw const CliArgumentException('L\'ID est obligatoire.');
    }
    final task = await _service.completeTask(id.trim());
    _println('Tâche terminée: $task');
  }

  Future<void> _deleteTask() async {
    final hasTasks = await _displayTasks();
    if (!hasTasks) return;

    _println('');
    final id = _readLine('ID de la tâche à supprimer');
    if (id == null || id.trim().isEmpty) {
      throw const CliArgumentException('L\'ID est obligatoire.');
    }
    await _service.deleteTask(id.trim());
    _println('Tâche id: $id supprimée.');
  }

  String? _readLine(String prompt) {
    _stdout.write('$prompt: ');
    return _stdin.readLineSync();
  }

  void _println(String message) => _stdout.writeln(message);
}
