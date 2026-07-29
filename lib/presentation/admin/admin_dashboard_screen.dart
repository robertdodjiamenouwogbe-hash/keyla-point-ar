import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keyla_point_ar/presentation/shared/providers/core_providers.dart';

/// Tableau de bord Administrateur : vue globale sur les équipes, les
/// superviseurs et les statistiques agrégées.
///
/// Cet écran consomme [EquipeRepository] (à injecter comme
/// `pointJournalierRepositoryProvider` dans core_providers.dart) pour
/// lister les équipes et permettre la création / affectation de
/// superviseurs. Le squelette ci-dessous pose la structure d'écran et le
/// point d'entrée RBAC ; le câblage complet aux données Firestore suit le
/// même schéma que le tableau de bord Superviseur.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration — KEYLA POINT AR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).deconnexion(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _creerEquipeDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle équipe'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Bienvenue, ${user?.prenom ?? ''}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _CarteStatGlobale(),
          const SizedBox(height: 24),
          Text('Équipes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const _ListeEquipesPlaceholder(),
        ],
      ),
    );
  }

  Future<void> _creerEquipeDialog(BuildContext context, WidgetRef ref) async {
    final nomCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une équipe'),
        content: TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom de l\'équipe')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              // À relier à EquipeRepository.creerEquipe(nom: nomCtrl.text)
              // une fois equipeRepositoryProvider ajouté à core_providers.dart.
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}

class _CarteStatGlobale extends StatelessWidget {
  const _CarteStatGlobale();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _Stat(label: 'Équipes actives', value: '—'),
            _Stat(label: 'Superviseurs', value: '—'),
            _Stat(label: 'Agents recruteurs', value: '—'),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}

class _ListeEquipesPlaceholder extends StatelessWidget {
  const _ListeEquipesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Branchez equipeRepositoryProvider.watchEquipes() ici pour afficher '
          'la liste des équipes, leur superviseur affecté et un accès rapide '
          'aux statistiques de chacune.',
        ),
      ),
    );
  }
}
