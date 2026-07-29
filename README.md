# KEYLA POINT AR

Application Flutter de gestion des Agents Recruteurs (AR) pour **KEYLA DISTRIBUTION SARL** (Celtiis Bénin).

## Architecture

Clean Architecture en 3 couches, avec Riverpod pour l'injection de dépendances et la gestion d'état :

```
lib/
  core/            constantes (rôles, statuts), thème MD3, routeur (go_router)
  domain/          entités métier, interfaces repository, use cases (logique métier pure)
  data/            modèles (mapping Firestore/SQLite), datasources, implémentations repository
  presentation/    écrans par rôle (admin / superviseur / agent_recruteur), providers Riverpod
```

Règle de dépendance : `presentation` → `domain` ← `data`. Le domaine ne dépend d'aucun package Flutter/Firebase.

## Rôles (RBAC)

| Rôle | Accès |
|---|---|
| Administrateur | équipes, superviseurs, statistiques globales |
| Superviseur | son équipe, ses AR, validation des points, rapport WhatsApp |
| Agent Recruteur | sa saisie du jour, son historique |

Le contrôle d'accès est appliqué à deux niveaux :
1. **Navigation** (`core/router/app_router.dart`) : redirige chaque rôle vers son tableau de bord.
2. **Données** (`docs/firestore.rules`) : impose côté serveur les mêmes règles — ne jamais faire confiance au client seul.

## Mode hors ligne

La saisie des points journaliers est **offline-first** :
1. Écriture immédiate dans SQLite local (`data/datasources/local/local_database.dart`).
2. Si connecté, envoi immédiat vers Firestore.
3. Sinon, `SyncService` écoute `connectivity_plus` et synchronise dès le retour du réseau (`PointJournalierRepositoryImpl.synchroniserEnAttente`).

## Mise en route

```bash
flutter pub get

# Configurer Firebase (Authentication, Firestore, Storage, FCM)
dart pub global activate flutterfire_cli
flutterfire configure
# → génère lib/firebase_options.dart ; décommenter son import dans main.dart

# Déployer les règles de sécurité
firebase deploy --only firestore:rules

flutter run
```

## Prochaines étapes suggérées

- Compléter `EquipeRepository`/`UserRepository` (implémentations Firestore, sur le modèle de `PointJournalierRepositoryImpl`) et les brancher dans `core_providers.dart`.
- Écrans de gestion : création de superviseur/AR, affectation équipe, écran de statistiques et classement (fl_chart déjà ajouté au pubspec).
- Exports PDF/Excel/CSV (packages `pdf`, `excel`, `csv` déjà ajoutés).
- Cloud Function de contrôle final d'unicité du point journalier (1 point/AR/jour) et d'envoi FCM.
- Module IA d'analyse des performances (ex. appel à un modèle via Cloud Function pour la synthèse en langage naturel).
- Tests unitaires sur les use cases (`domain/usecases`), qui sont indépendants de Flutter/Firebase et donc facilement testables.
