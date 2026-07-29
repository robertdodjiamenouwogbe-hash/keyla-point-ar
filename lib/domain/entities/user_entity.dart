import 'package:equatable/equatable.dart';
import 'package:keyla_point_ar/core/constants/user_role.dart';

/// Entité métier représentant un utilisateur, quel que soit son rôle.
class UserEntity extends Equatable {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? email;
  final UserRole role;
  final String? equipeId; // null pour un Administrateur
  final bool actif;
  final DateTime dateCreation;

  const UserEntity({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.email,
    required this.role,
    this.equipeId,
    this.actif = true,
    required this.dateCreation,
  });

  String get nomComplet => '$prenom $nom';

  UserEntity copyWith({
    String? nom,
    String? prenom,
    String? telephone,
    String? email,
    UserRole? role,
    String? equipeId,
    bool? actif,
  }) {
    return UserEntity(
      id: id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      role: role ?? this.role,
      equipeId: equipeId ?? this.equipeId,
      actif: actif ?? this.actif,
      dateCreation: dateCreation,
    );
  }

  @override
  List<Object?> get props => [id, nom, prenom, telephone, email, role, equipeId, actif, dateCreation];
}
