import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keyla_point_ar/data/models/point_journalier_model.dart';

/// Accès direct à la collection Firestore `points_journaliers`.
///
/// Règle de sécurité attendue côté Firestore (voir docs/firestore.rules) :
/// un AR ne peut écrire que ses propres points ; un superviseur ne peut
/// modifier (valider/rejeter) que les points de son équipe.
class PointJournalierRemoteDataSource {
  final FirebaseFirestore firestore;

  PointJournalierRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _collection => firestore.collection('points_journaliers');

  Stream<List<PointJournalierModel>> watchEnAttente(String equipeId) {
    return _collection
        .where('equipeId', isEqualTo: equipeId)
        .where('statut', isEqualTo: 'en_attente')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PointJournalierModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<PointJournalierModel>> watchHistoriqueAr(String arId) {
    return _collection
        .where('arId', isEqualTo: arId)
        .orderBy('date', descending: true)
        .limit(90)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PointJournalierModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> upsert(PointJournalierModel model) async {
    await _collection.doc(model.id).set(model.toMap(), SetOptions(merge: true));
  }

  Future<void> updateStatut({
    required String pointId,
    required String statut,
    required String superviseurId,
    String? motifRejet,
  }) async {
    await _collection.doc(pointId).update({
      'statut': statut,
      'valideParId': superviseurId,
      'dateValidation': DateTime.now().toIso8601String(),
      if (motifRejet != null) 'motifRejet': motifRejet,
    });
  }
}
