import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:keyla_point_ar/core/constants/user_role.dart';
import 'package:keyla_point_ar/core/theme/app_theme.dart';
import 'package:keyla_point_ar/domain/entities/point_journalier_entity.dart';
import 'package:keyla_point_ar/domain/usecases/saisir_point_journalier_usecase.dart';
import 'package:keyla_point_ar/presentation/shared/providers/core_providers.dart';

final historiqueArProvider = StreamProvider.autoDispose<List<PointJournalierEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(pointJournalierRepositoryProvider).watchHistoriqueAr(user.id);
});

class ArDashboardScreen extends ConsumerWidget {
  const ArDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final historiqueAsync = ref.watch(historiqueArProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour, ${user?.prenom ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).deconnexion(),
          ),
        ],
      ),
      body: historiqueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (historique) {
          final aujourdHui = DateTime.now();
          final pointDuJour = historique.where((p) =>
              p.date.year == aujourdHui.year && p.date.month == aujourdHui.month && p.date.day == aujourdHui.day);
          final dejaSaisi = pointDuJour.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CarteSaisieDuJour(dejaSaisi: dejaSaisi, point: dejaSaisi ? pointDuJour.first : null),
              const SizedBox(height: 24),
              Text('Historique', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...historique.map((p) => _LignePoint(point: p)),
            ],
          );
        },
      ),
    );
  }
}

class _CarteSaisieDuJour extends ConsumerStatefulWidget {
  final bool dejaSaisi;
  final PointJournalierEntity? point;

  const _CarteSaisieDuJour({required this.dejaSaisi, this.point});

  @override
  ConsumerState<_CarteSaisieDuJour> createState() => _CarteSaisieDuJourState();
}

class _CarteSaisieDuJourState extends ConsumerState<_CarteSaisieDuJour> {
  final _nombreCtrl = TextEditingController();
  bool _envoi = false;
  String? _erreur;

  Future<void> _envoyer() async {
    final nombre = int.tryParse(_nombreCtrl.text);
    if (nombre == null) {
      setState(() => _erreur = 'Entrez un nombre valide');
      return;
    }
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      final user = ref.read(currentUserProvider)!;
      final useCase = SaisirPointJournalierUseCase(ref.read(pointJournalierRepositoryProvider));
      await useCase(
        arId: user.id,
        equipeId: user.equipeId!,
        nombreRecrutements: nombre,
      );
      _nombreCtrl.clear();
    } catch (e) {
      setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dejaSaisi) {
      final point = widget.point!;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Point du jour saisi', style: Theme.of(context).textTheme.titleMedium),
                    Text('${point.nombreRecrutements} recrutement(s) — statut : ${point.statut.name}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saisir mon point du jour', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _nombreCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nombre de recrutements'),
            ),
            if (_erreur != null) ...[
              const SizedBox(height: 8),
              Text(_erreur!, style: TextStyle(color: AppTheme.danger)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _envoi ? null : _envoyer,
                child: _envoi ? const CircularProgressIndicator(color: Colors.white) : const Text('Valider ma saisie'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LignePoint extends StatelessWidget {
  final PointJournalierEntity point;
  const _LignePoint({required this.point});

  @override
  Widget build(BuildContext context) {
    final color = switch (point.statut) {
      StatutValidation.valide => AppTheme.success,
      StatutValidation.rejete => AppTheme.danger,
      StatutValidation.enAttente => AppTheme.warning,
    };
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(Icons.circle, color: color, size: 12)),
      title: Text('${point.nombreRecrutements} recrutement(s)'),
      subtitle: Text(DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(point.date)),
      trailing: Text(point.statut.name),
    );
  }
}
