import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:keyla_point_ar/data/models/user_model.dart';
import 'package:keyla_point_ar/domain/entities/user_entity.dart';
import 'package:keyla_point_ar/domain/repositories/auth_repository.dart';

/// Implémentation basée sur Firebase Authentication + Cloud Firestore.
///
/// L'identifiant de connexion des AR et superviseurs est le numéro de
/// téléphone (converti en pseudo-email interne `<telephone>@keyla.local`)
/// pour rester compatible avec Firebase Auth email/mot de passe sans
/// nécessiter de vérification SMS payante.
class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl({required this.firebaseAuth, required this.firestore});

  String _pseudoEmail(String telephone) => '${telephone.replaceAll('+', '')}@keyla.local';

  @override
  Stream<UserEntity?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return _fetchUserDoc(fbUser.uid);
    });
  }

  @override
  Future<UserEntity> connexion({required String identifiant, required String motDePasse}) async {
    final email = identifiant.contains('@') ? identifiant : _pseudoEmail(identifiant);
    final credential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: motDePasse);
    final uid = credential.user!.uid;
    final user = await _fetchUserDoc(uid);
    if (user == null) {
      throw StateError('Profil utilisateur introuvable pour ce compte');
    }
    if (!user.actif) {
      await firebaseAuth.signOut();
      throw StateError('Ce compte a été désactivé. Contactez votre superviseur.');
    }
    return user;
  }

  @override
  Future<void> deconnexion() => firebaseAuth.signOut();

  @override
  Future<UserEntity?> utilisateurCourant() async {
    final fbUser = firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return _fetchUserDoc(fbUser.uid);
  }

  Future<UserEntity?> _fetchUserDoc(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }
}
