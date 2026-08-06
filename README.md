# Task Manager — CLI Dart

Application en ligne de commande de gestion de tâches, écrite en **Dart pur** (sans Flutter).

## Fonctionnalités

- Ajouter une tâche (titre, priorité `low` / `medium` / `high`, date limite optionnelle)
- Lister les tâches avec tri par priorité, date d'échéance ou date de création
- Marquer une tâche comme terminée
- Supprimer une tâche
- Persistance locale dans un fichier JSON (`data/tasks.json` par défaut)

## Concepts Dart illustrés

| Concept | Implémentation |
|---------|----------------|
| Classe abstraite + héritage | `Task` → `RegularTask` / `UrgentTask` |
| Interface | `Serializable` (`implements`) |
| Génériques | `Repository<T>` / `JsonTaskRepository implements Repository<Task>` |
| Exceptions personnalisées | `TaskNotFoundException`, `InvalidTaskException`, `PersistenceException`, … |

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

## Lancer les tests

```bash
dart test
```

Les tests couvrent notamment :

- le parsing et le tri des priorités
- l'héritage `Task` / `UrgentTask`
- la sérialisation JSON et la persistance
- le service métier et les exceptions personnalisées
- l'interface `Serializable`

## Structure du projet

```
bin/task_manager.dart          # Point d'entrée CLI
lib/
  task_manager.dart            # Exports publics
  src/
    models/                    # Priority, Task, RegularTask, UrgentTask, Serializable
    repositories/              # Repository<T>, JsonTaskRepository
    services/                  # TaskService
    exceptions/                # Exceptions métier
    cli/                       # Menu interactif
test/task_manager_test.dart    # Tests unitaires
data/tasks.json                # Créé automatiquement à l'exécution
```
```
made by Eliezozo. 

```

## Licence

MIT
