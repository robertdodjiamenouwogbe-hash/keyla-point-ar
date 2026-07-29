import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:keyla_point_ar/core/constants/user_role.dart';
import 'package:keyla_point_ar/data/datasources/local/local_database.dart';
import 'package:keyla_point_ar/data/datasources/remote/point_journalier_remote_datasource.dart';
import 'package:keyla_point_ar/data/models/point_journalier_model.dart';
import 'package:keyla_point_ar/domain/entities/point_journalier_entity.dart';
import 'package:keyla_point_ar/domain/repositories/point_journalier_repository.dart';

/// Implémentation "offline-first" : toute saisie est d'abord écrite en
/// SQLite local, puis synchronisée vers Firestore dès que la connectivité
/// le permet (voir [synchroniserEnAttente]).
class PointJournalierRepositoryImpl implements PointJournalierRepository {
  final PointJournalierRemoteDataSource remote;
  final Connectivity connectivity;
  final _uuid = const Uuid();

  PointJournalierRepositoryImpl({required this.remote, required this.connectivity});

  @override
  Stream<List<PointJournalierEntity>> watchPointsEnAttente(String equipeId) {
    return remote.watchEnAttente(equipeId);
  }

  @override
  Stream<List<PointJournalierEntity>> watchHistoriqueAr(String arId) {
    return remote.watchHistoriqueAr(arId);
  }

  @override
  Stream<List<PointJournalierEntity>> watchPointsEquipe({
    required String equipeId,
    required DateTime debut,
    required DateTime fin,
  }) {
    // Filtrage par période fait côté client sur le flux existant pour
    // limiter le nombre d'index composites Firestore nécessaires.
    return remote.watchEnAttente(equipeId).map(
          (points) => points.where((p) => p.date.isAfter(debut) && p.date.isBefore(fin)).toList(),
        );
  }

  @override
  Future<PointJournalierEntity> saisirPoint({
    required String arId,
    required String equipeId,
    required int nombreRecrutements,
    double? latitude,
    double? longitude,
    String? commentaire,
    String? pieceJointePath,
  }) async {
    final model = PointJournalierModel(
      id: _uuid.v4(),
      arId: arId,
      equipeId: equipeId,
      date: DateTime.now(),
      nombreRecrutements: nombreRecrutements,
      latitude: latitude,
      longitude: longitude,
      commentaire: commentaire,
      pieceJointeUrl: pieceJointePath,
      synchronise: false,
    );

    final db = await LocalDatabase.instance;
    await db.insert('points_journaliers', model.toSqlite());

    final connectiviteResult = await connectivity.checkConnectivity();
    final enLigne = !connectiviteResult.contains(ConnectivityResult.none);
    if (enLigne) {
      await remote.upsert(model);
      await db.update(
        'points_journaliers',
        {'synchronise': 1},
        where: 'id = ?',
        whereArgs: [model.id],
      );
      return model.copyWith(synchronise: true);
    }

    return model;
  }

  @override
  Future<void> validerPoint({required String pointId, required String superviseurId}) {
    return remote.updateStatut(pointId: pointId, statut: StatutValidation.valide.code, superviseurId: superviseurId);
  }

  @override
  Future<void> rejeterPoint({required String pointId, required String superviseurId, required String motif}) {
    return remote.updateStatut(
      pointId: pointId,
      statut: StatutValidation.rejete.code,
      superviseurId: superviseurId,
      motifRejet: motif,
    );
  }

  /// À appeler au retour de connexion (écouté par [SyncService]) : pousse
  /// vers Firestore tous les points saisis hors ligne.
  Future<void> synchroniserEnAttente() async {
    final db = await LocalDatabase.instance;
    final rows = await db.query('points_journaliers', where: 'synchronise = 0');

    for (final row in rows) {
      final model = PointJournalierModel.fromSqlite(row);
      await remote.upsert(model);
      await db.update('points_journaliers', {'synchronise': 1}, where: 'id = ?', whereArgs: [model.id]);
    }
  }
}
