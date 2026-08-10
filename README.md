# Task Manager — CLI Dart

Application en ligne de commande de gestion de tâches, écrite en **Dart pur** (sans Flutter).

**Architecture : layered (en couches) — ce projet n’est pas flat.**  
Détails : [`ARCHITECTURE.md`](ARCHITECTURE.md) · [`metadata.yaml`](metadata.yaml)

## Fonctionnalités

- Ajouter une tâche (titre, priorité `low` / `medium` / `high`, date limite optionnelle)
- Lister les tâches avec tri par priorité, date d'échéance ou date de création
- Marquer une tâche comme terminée (la liste s'affiche d'abord)
- Supprimer une tâche (la liste s'affiche d'abord)
- **Persistance locale JSON** via `JsonTaskRepository` (`add` / `update` / `save` → `File.writeAsString`)

## Prérequis

- [Dart SDK](https://dart.dev/get-dart) ≥ 3.12 (Linux, macOS ou Windows)

Vérification :

```bash
dart --version
```

## Installation

```bash
git clone https://github.com/Eliezozo/FlutterFireSummerDartProject.git
cd FlutterFireSummerDartProject
dart pub get
```

Les dépendances (`path`, `intl`, `test`, `lints`) sont déclarées dans `pubspec.yaml`.

## Lancer l'application

```bash
dart run
```

Le fichier de persistance est créé automatiquement :

```
data/tasks.json
```

Pour utiliser un autre fichier :

```bash
dart run bin/task_manager.dart /tmp/mes_taches.json
```

Un exemple de fichier est fourni : [`data/tasks.example.json`](data/tasks.example.json).

### Menu interactif

```
1. Ajouter une tâche
2. Lister les tâches
3. Marquer une tâche comme terminée
4. Supprimer une tâche
5. Quitter
```

Les options 3 et 4 affichent d'abord la liste des tâches enregistrées, puis demandent l'ID.

Saisie type pour ajouter une tâche :

```
Titre de la tâche: Récolter le cacao
Priorité (low / medium / high) [medium]: high
Date limite (YYYY-MM-DD, optionnel): 2026-09-15
Note d'urgence (optionnel): Pompe HS
```

## Persistance JSON

`JsonTaskRepository` implémente `Repository<Task>` et **écrit réellement** le fichier :

| Méthode | Rôle |
|---------|------|
| `add(Task)` | Ajoute la tâche en cache puis appelle `save()` |
| `update(Task)` | Remplace la tâche puis appelle `save()` |
| `delete(id)` | Retire la tâche puis appelle `save()` |
| `save()` | `File.writeAsString` du JSON indenté `{ version, tasks: [...] }` |

Format du fichier :

```json
{
  "version": 1,
  "tasks": [
    {
      "id": "1",
      "title": "Récolter le cacao",
      "priority": "medium",
      "dueDate": "2026-09-01T00:00:00.000",
      "isCompleted": false,
      "createdAt": "2026-08-01T10:00:00.000",
      "type": "RegularTask"
    }
  ]
}
```

Les erreurs disque (permissions, chemin introuvable, JSON corrompu) lèvent `PersistenceException`.

Les identifiants sont calculés à partir du **max id déjà persisté** dans le JSON, pour éviter les collisions au redémarrage.

## Architecture en couches (layered)

```
présentation  →  application  →  data  →  domain
                                      ↖ core (interfaces + erreurs)
```

| Couche | Chemin | Rôle |
|--------|--------|------|
| core | `lib/src/core/` | Contrats (`Repository<T>`, `Serializable`) et exceptions |
| domain | `lib/src/domain/` | `Task` → `UrgentTask` / `RegularTask`, `Priority` |
| data | `lib/src/data/` | `JsonTaskRepository` (JSON) + dépôts génériques |
| application | `lib/src/application/` | `TaskService` |
| presentation | `lib/src/presentation/` | `CliApp` + `ConsoleIo` |

Arborescence :

```
bin/task_manager.dart                 # Point d'entrée CLI
lib/
  task_manager.dart                   # Exports publics
  src/
    core/
      errors/                         # TaskException et sous-classes
      interfaces/                     # Serializable, Identifiable, Persistable, Repository<T>
    domain/
      models/                         # Priority, Task, UrgentTask, RegularTask, SortBy
    data/
      repositories/                   # JsonTaskRepository, JsonFileRepository<T>, InMemoryRepository<T>
    application/
      services/                       # TaskService
    presentation/
      cli/                            # CliApp, ConsoleIo
test/                                 # 9 fichiers de tests unitaires
metadata.yaml                         # architecture: layered (pas flat)
ARCHITECTURE.md                       # Documentation des couches
.github/workflows/ci.yml              # CI : format + analyze + test
data/tasks.example.json               # Exemple de persistance
```

## Concepts Dart illustrés

| Concept | Implémentation |
|---------|----------------|
| Classe abstraite + héritage | **`Task → UrgentTask`** (chemin principal) et `RegularTask` |
| Interface | `abstract interface class Serializable`, `Identifiable`, `Persistable`, `Repository<T>`, `ConsoleIo` |
| Génériques | `Repository<T>`, `InMemoryRepository<T>`, `JsonFileRepository<T extends Persistable>` |
| Exceptions personnalisées | `TaskException` → `TaskNotFoundException`, `InvalidTaskException`, `PersistenceException`, `CliArgumentException` |
| Persistance JSON | `JsonTaskRepository.add` / `update` / `save` + `File.writeAsString` |

### Héritage : `Task → UrgentTask`

```
Task (abstract)
  ├── UrgentTask   // priorité forcée high + note d'urgence
  └── RegularTask  // tâche standard (low / medium)
```

### Interfaces (`abstract interface class`)

- `Serializable` — `toJson()`
- `Identifiable` — `id`
- `Persistable` — combinaison des deux
- `Repository<T>` — contrat CRUD générique (`add`, `update`, `delete`, `save`, `findAll`, …)
- `ConsoleIo` — I/O console testable

### Exceptions personnalisées (CLI)

| Exception | Message CLI |
|-----------|-------------|
| `TaskNotFoundException` | Introuvable |
| `InvalidTaskException` | Données invalides |
| `PersistenceException` | Erreur de sauvegarde |
| `CliArgumentException` | Saisie incorrecte |
| `FormatException` | Format incorrect |

## Lancer les tests

```bash
dart test
```

Fichiers de tests (`package:test`) :

| Fichier | Couverture |
|---------|------------|
| `test/priority_test.dart` | Parsing et tri des priorités |
| `test/task_inheritance_test.dart` | Héritage **Task → UrgentTask** |
| `test/serializable_interface_test.dart` | Interfaces Serializable / Persistable |
| `test/in_memory_repository_test.dart` | `Repository<T>` hors Task |
| `test/json_file_repository_test.dart` | Dépôt JSON générique |
| `test/json_task_repository_test.dart` | **add / update / save** + écriture fichier |
| `test/task_service_test.dart` | Service métier + ids persistés |
| `test/exceptions_test.dart` | Exceptions personnalisées |
| `test/cli_app_test.dart` | Menu CLI et messages d'erreur |

Analyse statique :

```bash
dart analyze
dart format --output=none --set-exit-if-changed .
```

## CI/CD

GitHub Actions (`.github/workflows/ci.yml`) à chaque push / pull request :

1. `dart pub get`
2. `dart format`
3. `dart analyze --fatal-infos`
4. `dart test`

## Extensions possibles

- Exporter un rapport PDF ou CSV des tâches
- Ajouter un filtre « uniquement urgentes » / « en retard »
- Remplacer le fichier JSON par une base SQLite en implémentant `Repository<Task>`
- Ajouter une commande non interactive (`dart run -- add "Titre"`)

made by Eliezozo.
