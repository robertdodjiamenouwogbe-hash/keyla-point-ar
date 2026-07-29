import 'package:keyla_point_ar/core/constants/user_role.dart';
import 'package:keyla_point_ar/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.telephone,
    super.email,
    required super.role,
    super.equipeId,
    super.actif,
    required super.dateCreation,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      nom: map['nom'] as String,
      prenom: map['prenom'] as String,
      telephone: map['telephone'] as String,
      email: map['email'] as String?,
      role: UserRole.fromCode(map['role'] as String),
      equipeId: map['equipeId'] as String?,
      actif: map['actif'] as bool? ?? true,
      dateCreation: DateTime.parse(map['dateCreation'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'role': role.code,
      'equipeId': equipeId,
      'actif': actif,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity e) => UserModel(
        id: e.id,
        nom: e.nom,
        prenom: e.prenom,
        telephone: e.telephone,
        email: e.email,
        role: e.role,
        equipeId: e.equipeId,
        actif: e.actif,
        dateCreation: e.dateCreation,
      );
}
