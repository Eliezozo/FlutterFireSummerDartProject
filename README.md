# Task Manager — CLI Dart

Application en ligne de commande de gestion de tâches, écrite en **Dart pur** (sans Flutter).

## Fonctionnalités

- Ajouter une tâche (titre, priorité `low` / `medium` / `high`, date limite optionnelle)
- Lister les tâches avec tri par priorité, date d'échéance ou date de création
- Marquer une tâche comme terminée (la liste s'affiche d'abord)
- Supprimer une tâche (la liste s'affiche d'abord)
- Persistance locale dans un fichier JSON (`data/tasks.json` par défaut)

## Concepts Dart illustrés

| Concept | Implémentation |
|---------|----------------|
| Classe abstraite + héritage | **`Task → UrgentTask`** (chemin principal) et `RegularTask` |
| Interface | `abstract interface class Serializable`, `Identifiable`, `Persistable`, `Repository<T>`, `ConsoleIo` |
| Génériques | `Repository<T extends Identifiable>`, `InMemoryRepository<T>`, `JsonFileRepository<T extends Persistable>` |
| Exceptions personnalisées | `TaskException` → `TaskNotFoundException`, `InvalidTaskException`, `PersistenceException`, `CliArgumentException` |

### Héritage : `Task → UrgentTask`

```
Task (abstract)
  ├── UrgentTask   // priorité forcée high + note d'urgence
  └── RegularTask  // tâche standard (low / medium)
```

`UrgentTask` **étend** `Task` : priorité toujours `high`, libellé `URGENT`, `isUrgent == true`.

### Interfaces (`abstract interface class`)

En Dart 3, une interface se déclare avec `abstract interface class` et s'utilise via `implements` :

- `Serializable` — `toJson()`
- `Identifiable` — `id`
- `Persistable` — combinaison des deux
- `Repository<T>` — contrat CRUD générique
- `ConsoleIo` — I/O console testable

### Génériques : `Repository<T>`

Le dépôt n'est **pas** figé aux tâches. Deux implémentations concrètes :

- `InMemoryRepository<T extends Identifiable>` — mémoire (tests, démo)
- `JsonFileRepository<T extends Persistable>` — fichier JSON générique
  - `JsonTaskRepository extends JsonFileRepository<Task>` — spécialisation tâches

`findAllSorted({compare})` fait partie du contrat générique `Repository<T>`.

### Exceptions personnalisées

La CLI intercepte **chaque sous-type** pour un message clair :

| Exception | Message CLI |
|-----------|-------------|
| `TaskNotFoundException` | Introuvable |
| `InvalidTaskException` | Données invalides |
| `PersistenceException` | Erreur de sauvegarde |
| `CliArgumentException` | Saisie incorrecte |
| `FormatException` | Format incorrect |
| autre `TaskException` | Erreur |
| tout le reste | Erreur inattendue |

## Architecture en couches

```
présentation  →  application  →  data  →  domain
                                      ↖ core (interfaces + erreurs)
```

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
      repositories/                   # InMemoryRepository<T>, JsonFileRepository<T>, JsonTaskRepository
    application/
      services/                       # TaskService (dépend de Repository<Task>)
    presentation/
      cli/                            # CliApp, ConsoleIo
test/
  priority_test.dart
  task_inheritance_test.dart          # Task → UrgentTask
  serializable_interface_test.dart
  in_memory_repository_test.dart      # Repository<T> hors Task
  json_file_repository_test.dart      # JsonFileRepository<T> générique
  json_task_repository_test.dart
  task_service_test.dart
  exceptions_test.dart
  cli_app_test.dart
.github/workflows/ci.yml              # CI : format + analyze + test
data/tasks.json                       # Créé automatiquement à l'exécution
```

## Prérequis

- [Dart SDK](https://dart.dev/get-dart) ≥ 3.12

## Installation

```bash
git clone https://github.com/Eliezozo/FlutterFireSummerDartProject.git
cd FlutterFireSummerDartProject
dart pub get
```

## Lancer l'application

```bash
dart run
```

### Menu interactif

```
1. Ajouter une tâche
2. Lister les tâches
3. Marquer une tâche comme terminée
4. Supprimer une tâche
5. Quitter
```

Les options 3 et 4 affichent d'abord la liste des tâches enregistrées, puis demandent l'ID.

## Lancer les tests

```bash
dart test
```

Plus de 5 fichiers de tests unitaires (`package:test`) couvrent :

- le parsing et le tri des priorités
- l'héritage **`Task → UrgentTask`**
- les interfaces `Serializable` / `Persistable`
- les génériques `Repository<T>` (y compris avec un type autre que `Task`)
- la persistance JSON et l'invalidation du cache
- le service métier et les exceptions personnalisées
- la CLI (saisie, liste avant complete/delete, messages d'erreur typés)

## CI/CD

Un workflow GitHub Actions (`.github/workflows/ci.yml`) exécute à chaque push / pull request :

1. `dart pub get`
2. `dart format`
3. `dart analyze --fatal-infos`
4. `dart test`

made by Eliezozo.
