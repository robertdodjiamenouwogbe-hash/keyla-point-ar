import 'package:intl/intl.dart';
import 'package:keyla_point_ar/core/constants/user_role.dart';
import 'package:keyla_point_ar/domain/entities/equipe_entity.dart';
import 'package:keyla_point_ar/domain/entities/point_journalier_entity.dart';
import 'package:keyla_point_ar/domain/entities/user_entity.dart';

/// Construit le texte formaté du rapport quotidien envoyé par le
/// superviseur sur WhatsApp, à partir des points validés du jour.
class GenererRapportWhatsAppUseCase {
  String call({
    required EquipeEntity equipe,
    required List<UserEntity> agents,
    required List<PointJournalierEntity> pointsDuJour,
  }) {
    final dateStr = DateFormat('dd/MM/yyyy', 'fr_FR').format(DateTime.now());
    final buffer = StringBuffer();

    buffer.writeln('📊 *RAPPORT JOURNALIER — ${equipe.nom}*');
    buffer.writeln('📅 $dateStr');
    buffer.writeln('');

    final valides = pointsDuJour.where((p) => p.statut == StatutValidation.valide).toList();
    final totalRecrutements = valides.fold<int>(0, (sum, p) => sum + p.nombreRecrutements);

    buffer.writeln('*Total recrutements validés : $totalRecrutements*');
    buffer.writeln('*Agents actifs : ${agents.length}*');
    buffer.writeln('');
    buffer.writeln('Détail par agent :');

    for (final agent in agents) {
      final point = valides.where((p) => p.arId == agent.id).cast<PointJournalierEntity?>().firstOrNull;
      final nb = point?.nombreRecrutements ?? 0;
      final statutIcon = point != null ? '✅' : '⏳';
      buffer.writeln('$statutIcon ${agent.nomComplet} : $nb recrutement(s)');
    }

    buffer.writeln('');
    buffer.writeln('_Généré automatiquement par KEYLA POINT AR_');

    return buffer.toString();
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
