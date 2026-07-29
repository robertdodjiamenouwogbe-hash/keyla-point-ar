import 'package:equatable/equatable.dart';

class EquipeEntity extends Equatable {
  final String id;
  final String nom;
  final String? superviseurId;
  final String? zone;
  final bool active;
  final DateTime dateCreation;

  const EquipeEntity({
    required this.id,
    required this.nom,
    this.superviseurId,
    this.zone,
    this.active = true,
    required this.dateCreation,
  });

  EquipeEntity copyWith({String? nom, String? superviseurId, String? zone, bool? active}) {
    return EquipeEntity(
      id: id,
      nom: nom ?? this.nom,
      superviseurId: superviseurId ?? this.superviseurId,
      zone: zone ?? this.zone,
      active: active ?? this.active,
      dateCreation: dateCreation,
    );
  }

  @override
  List<Object?> get props => [id, nom, superviseurId, zone, active, dateCreation];
}
