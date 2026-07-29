import 'package:keyla_point_ar/core/constants/user_role.dart';
import 'package:keyla_point_ar/domain/entities/point_journalier_entity.dart';

class PointJournalierModel extends PointJournalierEntity {
  const PointJournalierModel({
    required super.id,
    required super.arId,
    required super.equipeId,
    required super.date,
    required super.nombreRecrutements,
    super.latitude,
    super.longitude,
    super.commentaire,
    super.pieceJointeUrl,
    super.statut,
    super.motifRejet,
    super.valideParId,
    super.dateValidation,
    super.synchronise,
  });

  /// Depuis Firestore (source distante).
  factory PointJournalierModel.fromMap(String id, Map<String, dynamic> map) {
    return PointJournalierModel(
      id: id,
      arId: map['arId'] as String,
      equipeId: map['equipeId'] as String,
      date: DateTime.parse(map['date'] as String),
      nombreRecrutements: map['nombreRecrutements'] as int,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      commentaire: map['commentaire'] as String?,
      pieceJointeUrl: map['pieceJointeUrl'] as String?,
      statut: StatutValidationX.fromCode(map['statut'] as String? ?? 'en_attente'),
      motifRejet: map['motifRejet'] as String?,
      valideParId: map['valideParId'] as String?,
      dateValidation: map['dateValidation'] != null ? DateTime.parse(map['dateValidation'] as String) : null,
      synchronise: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'arId': arId,
      'equipeId': equipeId,
      'date': date.toIso8601String(),
      'nombreRecrutements': nombreRecrutements,
      'latitude': latitude,
      'longitude': longitude,
      'commentaire': commentaire,
      'pieceJointeUrl': pieceJointeUrl,
      'statut': statut.code,
      'motifRejet': motifRejet,
      'valideParId': valideParId,
      'dateValidation': dateValidation?.toIso8601String(),
    };
  }

  /// Depuis / vers la table SQLite locale (mode hors ligne).
  factory PointJournalierModel.fromSqlite(Map<String, dynamic> row) {
    return PointJournalierModel(
      id: row['id'] as String,
      arId: row['ar_id'] as String,
      equipeId: row['equipe_id'] as String,
      date: DateTime.parse(row['date'] as String),
      nombreRecrutements: row['nombre_recrutements'] as int,
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      commentaire: row['commentaire'] as String?,
      pieceJointeUrl: row['piece_jointe_path'] as String?,
      statut: StatutValidationX.fromCode(row['statut'] as String? ?? 'en_attente'),
      synchronise: (row['synchronise'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'ar_id': arId,
      'equipe_id': equipeId,
      'date': date.toIso8601String(),
      'nombre_recrutements': nombreRecrutements,
      'latitude': latitude,
      'longitude': longitude,
      'commentaire': commentaire,
      'piece_jointe_path': pieceJointeUrl,
      'statut': statut.code,
      'synchronise': synchronise ? 1 : 0,
    };
  }
}
