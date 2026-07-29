import 'package:keyla_point_ar/domain/entities/equipe_entity.dart';

abstract class EquipeRepository {
  Stream<List<EquipeEntity>> watchEquipes();

  Future<EquipeEntity> creerEquipe({required String nom, String? zone});

  Future<void> affecterSuperviseur({required String equipeId, required String superviseurId});

  Future<void> modifierEquipe(EquipeEntity equipe);

  Future<void> desactiverEquipe(String equipeId);
}
