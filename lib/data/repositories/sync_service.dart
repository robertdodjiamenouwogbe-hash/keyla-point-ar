import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:keyla_point_ar/data/repositories/point_journalier_repository_impl.dart';

/// Écoute les changements de connectivité et déclenche la synchronisation
/// des données saisies hors ligne dès qu'une connexion est rétablie.
class SyncService {
  final PointJournalierRepositoryImpl pointRepository;
  final Connectivity connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  SyncService({required this.pointRepository, required this.connectivity});

  void demarrer() {
    _subscription = connectivity.onConnectivityChanged.listen((results) async {
      final enLigne = !results.contains(ConnectivityResult.none);
      if (enLigne) {
        await pointRepository.synchroniserEnAttente();
      }
    });
  }

  void arreter() {
    _subscription?.cancel();
  }
}
