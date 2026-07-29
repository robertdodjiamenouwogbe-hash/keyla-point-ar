import 'package:keyla_point_ar/domain/entities/point_journalier_entity.dart';
import 'package:keyla_point_ar/domain/repositories/point_journalier_repository.dart';

/// Règle métier : un AR ne peut saisir qu'un seul point par jour.
/// Le contrôle d'unicité définitif est fait côté serveur (règles Firestore),
/// ce use case applique un contrôle préventif côté client.
class SaisirPointJournalierUseCase {
  final PointJournalierRepository repository;

  SaisirPointJournalierUseCase(this.repository);

  Future<PointJournalierEntity> call({
    required String arId,
    required String equipeId,
    required int nombreRecrutements,
    double? latitude,
    double? longitude,
    String? commentaire,
    String? pieceJointePath,
  }) async {
    if (nombreRecrutements < 0) {
      throw ArgumentError('Le nombre de recrutements ne peut pas être négatif');
    }

    final aujourdHui = DateTime.now();
    final historique = await repository.watchHistoriqueAr(arId).first;
    final dejaSaisiAujourdhui = historique.any((point) =>
        point.date.year == aujourdHui.year &&
        point.date.month == aujourdHui.month &&
        point.date.day == aujourdHui.day);

    if (dejaSaisiAujourdhui) {
      throw StateError('Un point a déjà été saisi aujourd\'hui pour cet agent');
    }

    return repository.saisirPoint(
      arId: arId,
      equipeId: equipeId,
      nombreRecrutements: nombreRecrutements,
      latitude: latitude,
      longitude: longitude,
      commentaire: commentaire,
      pieceJointePath: pieceJointePath,
    );
  }
}
