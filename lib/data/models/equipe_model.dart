import 'package:keyla_point_ar/domain/entities/equipe_entity.dart';

class EquipeModel extends EquipeEntity {
  const EquipeModel({
    required super.id,
    required super.nom,
    super.superviseurId,
    super.zone,
    super.active,
    required super.dateCreation,
  });

  factory EquipeModel.fromMap(String id, Map<String, dynamic> map) {
    return EquipeModel(
      id: id,
      nom: map['nom'] as String,
      superviseurId: map['superviseurId'] as String?,
      zone: map['zone'] as String?,
      active: map['active'] as bool? ?? true,
      dateCreation: DateTime.parse(map['dateCreation'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'superviseurId': superviseurId,
      'zone': zone,
      'active': active,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }
}
