import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keyla_point_ar/core/theme/app_theme.dart';
import 'package:keyla_point_ar/domain/entities/equipe_entity.dart';
import 'package:keyla_point_ar/domain/entities/point_journalier_entity.dart';
import 'package:keyla_point_ar/domain/entities/user_entity.dart';
import 'package:keyla_point_ar/domain/usecases/generer_rapport_whatsapp_usecase.dart';
import 'package:keyla_point_ar/presentation/shared/providers/core_providers.dart';

final pointsEnAttenteProvider = StreamProvider.autoDispose<List<PointJournalierEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.equipeId == null) return const Stream.empty();
  return ref.watch(pointJournalierRepositoryProvider).watchPointsEnAttente(user!.equipeId!);
});

class SuperviseurDashboardScreen extends ConsumerWidget {
  const SuperviseurDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final pointsAsync = ref.watch(pointsEnAttenteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation des points'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined),
            tooltip: 'Générer le rapport WhatsApp',
            onPressed: () => _genererRapport(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).deconnexion(),
          ),
        ],
      ),
      body: pointsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (points) {
          if (points.isEmpty) {
            return const Center(child: Text('Aucun point en attente de validation'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: points.length,
            itemBuilder: (context, index) => _CartePointAValider(point: points[index], superviseurId: user!.id),
          );
        },
      ),
    );
  }

  Future<void> _genererRapport(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user?.equipeId == null) return;

    // Dans une implémentation complète, les agents et l'équipe proviennent
    // de userRepository.watchAgentsByEquipe / equipeRepository — simplifié
    // ici pour le squelette.
    final points = ref.read(pointsEnAttenteProvider).value ?? [];
    final rapport = GenererRapportWhatsAppUseCase().call(
      equipe: EquipeEntity(id: user!.equipeId!, nom: 'Mon équipe', dateCreation: DateTime.now()),
      agents: const <UserEntity>[],
      pointsDuJour: points,
    );

    await Clipboard.setData(ClipboardData(text: rapport));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rapport copié — collez-le dans WhatsApp')),
      );
    }
  }
}

class _CartePointAValider extends ConsumerWidget {
  final PointJournalierEntity point;
  final String superviseurId;

  const _CartePointAValider({required this.point, required this.superviseurId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${point.nombreRecrutements} recrutement(s)', style: Theme.of(context).textTheme.titleMedium),
            Text('Agent : ${point.arId}', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejeter(context, ref),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                    child: const Text('Rejeter'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ref
                        .read(pointJournalierRepositoryProvider)
                        .validerPoint(pointId: point.id, superviseurId: superviseurId),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rejeter(BuildContext context, WidgetRef ref) async {
    final motifCtrl = TextEditingController();
    final motif = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motif du rejet'),
        content: TextField(controller: motifCtrl, decoration: const InputDecoration(hintText: 'Ex : donnée incohérente')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, motifCtrl.text), child: const Text('Confirmer')),
        ],
      ),
    );
    if (motif != null && motif.isNotEmpty) {
      await ref
          .read(pointJournalierRepositoryProvider)
          .rejeterPoint(pointId: point.id, superviseurId: superviseurId, motif: motif);
    }
  }
}
