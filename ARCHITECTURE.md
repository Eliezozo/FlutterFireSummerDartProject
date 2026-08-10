# Architecture — layered (pas flat)

Ce projet utilise une **architecture en couches** (*layered architecture*).
Ce n’est **pas** une architecture plate (*flat*).

Voir aussi [`metadata.yaml`](metadata.yaml) (`architecture: layered`, `is_flat: false`).

## Flux des dépendances

```
presentation  →  application  →  data  →  domain
                                   ↖ core (contrats + erreurs)
```

Une couche supérieure peut dépendre d’une couche inférieure, jamais l’inverse.

| Couche | Dossier | Responsabilité |
|--------|---------|----------------|
| **presentation** | `lib/src/presentation/cli/` | Menu CLI, saisie utilisateur (`CliApp`, `ConsoleIo`) |
| **application** | `lib/src/application/services/` | Cas d’usage (`TaskService`) |
| **data** | `lib/src/data/repositories/` | Persistance JSON (`JsonTaskRepository`) et génériques |
| **domain** | `lib/src/domain/models/` | Entités : `Task` → `UrgentTask`, `RegularTask` |
| **core** | `lib/src/core/` | Interfaces (`Repository<T>`, `Serializable`) et exceptions |

## Persistance JSON (exigence du cours)

La classe **`JsonTaskRepository`** implémente `Repository<Task>` et contient
explicitement :

- `add(Task)` — ajoute puis appelle `save()`
- `update(Task)` — met à jour puis appelle `save()`
- `delete(String)` — supprime puis appelle `save()`
- `save()` — écrit le fichier avec `File.writeAsString`

Fichier cible : `data/tasks.json` (exemple versionné : `data/tasks.example.json`).

## Génériques

- `Repository<T extends Identifiable>` — contrat CRUD
- `InMemoryRepository<T>` — implémentation mémoire (tests)
- `JsonFileRepository<T extends Persistable>` — dépôt JSON générique (démo hors Task)
- `JsonTaskRepository` — dépôt JSON **spécialisé tâches**, avec écriture fichier complète
