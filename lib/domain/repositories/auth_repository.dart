import 'package:keyla_point_ar/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity> connexion({required String identifiant, required String motDePasse});

  Future<void> deconnexion();

  Future<UserEntity?> utilisateurCourant();
}
