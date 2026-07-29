import 'package:keyla_point_ar/domain/entities/point_journalier_entity.dart';

abstract class PointJournalierRepository {
  /// Points en attente de validation pour une équipe (vue Superviseur).
  Stream<List<PointJournalierEntity>> watchPointsEnAttente(String equipeId);

  /// Historique des points d'un AR (vue Agent Recruteur).
  Stream<List<PointJournalierEntity>> watchHistoriqueAr(String arId);

  /// Tous les points d'une équipe sur une période (statistiques).
  Stream<List<PointJournalierEntity>> watchPointsEquipe({
    required String equipeId,
    required DateTime debut,
    required DateTime fin,
  });

  /// Saisie d'un point journalier. Fonctionne hors ligne (écrit en local
  /// d'abord, marqué `synchronise = false`, puis synchronisé par
  /// [SyncService] dès qu'une connexion est disponible).
  Future<PointJournalierEntity> saisirPoint({
    required String arId,
    required String equipeId,
    required int nombreRecrutements,
    double? latitude,
    double? longitude,
    String? commentaire,
    String? pieceJointePath,
  });

  Future<void> validerPoint({required String pointId, required String superviseurId});

  Future<void> rejeterPoint({
    required String pointId,
    required String superviseurId,
    required String motif,
  });
}
