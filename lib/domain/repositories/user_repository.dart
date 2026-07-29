import 'package:keyla_point_ar/core/constants/user_role.dart';
import 'package:keyla_point_ar/domain/entities/user_entity.dart';

abstract class UserRepository {
  Stream<List<UserEntity>> watchUsersByRole(UserRole role);

  Stream<List<UserEntity>> watchAgentsByEquipe(String equipeId);

  Future<UserEntity> creerUtilisateur({
    required String nom,
    required String prenom,
    required String telephone,
    String? email,
    required UserRole role,
    String? equipeId,
  });

  Future<void> desactiverUtilisateur(String userId);

  Future<UserEntity?> getUserById(String userId);
}
