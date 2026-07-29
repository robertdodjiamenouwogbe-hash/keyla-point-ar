import 'package:equatable/equatable.dart';
import 'package:keyla_point_ar/core/constants/user_role.dart';

/// Saisie quotidienne d'un Agent Recruteur.
class PointJournalierEntity extends Equatable {
  final String id;
  final String arId;
  final String equipeId;
  final DateTime date;
  final int nombreRecrutements;
  final double? latitude;
  final double? longitude;
  final String? commentaire;
  final String? pieceJointeUrl;
  final StatutValidation statut;
  final String? motifRejet;
  final String? valideParId;
  final DateTime? dateValidation;
  final bool synchronise; // false = en attente de sync (mode hors ligne)

  const PointJournalierEntity({
    required this.id,
    required this.arId,
    required this.equipeId,
    required this.date,
    required this.nombreRecrutements,
    this.latitude,
    this.longitude,
    this.commentaire,
    this.pieceJointeUrl,
    this.statut = StatutValidation.enAttente,
    this.motifRejet,
    this.valideParId,
    this.dateValidation,
    this.synchronise = true,
  });

  PointJournalierEntity copyWith({
    StatutValidation? statut,
    String? motifRejet,
    String? valideParId,
    DateTime? dateValidation,
    bool? synchronise,
  }) {
    return PointJournalierEntity(
      id: id,
      arId: arId,
      equipeId: equipeId,
      date: date,
      nombreRecrutements: nombreRecrutements,
      latitude: latitude,
      longitude: longitude,
      commentaire: commentaire,
      pieceJointeUrl: pieceJointeUrl,
      statut: statut ?? this.statut,
      motifRejet: motifRejet ?? this.motifRejet,
      valideParId: valideParId ?? this.valideParId,
      dateValidation: dateValidation ?? this.dateValidation,
      synchronise: synchronise ?? this.synchronise,
    );
  }

  @override
  List<Object?> get props => [
        id,
        arId,
        equipeId,
        date,
        nombreRecrutements,
        latitude,
        longitude,
        commentaire,
        pieceJointeUrl,
        statut,
        motifRejet,
        valideParId,
        dateValidation,
        synchronise,
      ];
}
