import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keyla_point_ar/data/datasources/remote/point_journalier_remote_datasource.dart';
import 'package:keyla_point_ar/data/repositories/auth_repository_impl.dart';
import 'package:keyla_point_ar/data/repositories/point_journalier_repository_impl.dart';
import 'package:keyla_point_ar/domain/entities/user_entity.dart';
import 'package:keyla_point_ar/domain/repositories/auth_repository.dart';
import 'package:keyla_point_ar/domain/repositories/point_journalier_repository.dart';

// --- Instances SDK ---

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) => fb.FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

// --- Data sources ---

final pointRemoteDataSourceProvider = Provider<PointJournalierRemoteDataSource>((ref) {
  return PointJournalierRemoteDataSource(ref.watch(firestoreProvider));
});

// --- Repositories (injection d'interface -> implémentation) ---

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final pointJournalierRepositoryProvider = Provider<PointJournalierRepository>((ref) {
  return PointJournalierRepositoryImpl(
    remote: ref.watch(pointRemoteDataSourceProvider),
    connectivity: ref.watch(connectivityProvider),
  );
});

// --- État d'authentification global ---

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider).value;
});
