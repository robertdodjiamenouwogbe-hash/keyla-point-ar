/// Rôles applicatifs de KEYLA POINT AR.
///
/// Le RBAC (contrôle d'accès par rôle) s'appuie sur cette énumération à la
/// fois côté client (navigation, UI) et doit être répliqué côté règles de
/// sécurité Firestore (voir docs/firestore.rules).
enum UserRole {
  administrateur,
  superviseur,
  agentRecruteur;

  String get label {
    switch (this) {
      case UserRole.administrateur:
        return 'Administrateur';
      case UserRole.superviseur:
        return 'Superviseur';
      case UserRole.agentRecruteur:
        return 'Agent Recruteur';
    }
  }

  /// Valeur stockée en base (Firestore field `role`).
  String get code {
    switch (this) {
      case UserRole.administrateur:
        return 'admin';
      case UserRole.superviseur:
        return 'superviseur';
      case UserRole.agentRecruteur:
        return 'ar';
    }
  }

  static UserRole fromCode(String code) {
    switch (code) {
      case 'admin':
        return UserRole.administrateur;
      case 'superviseur':
        return UserRole.superviseur;
      case 'ar':
        return UserRole.agentRecruteur;
      default:
        throw ArgumentError('Rôle inconnu: $code');
    }
  }
}

enum StatutValidation { enAttente, valide, rejete }

extension StatutValidationX on StatutValidation {
  String get code {
    switch (this) {
      case StatutValidation.enAttente:
        return 'en_attente';
      case StatutValidation.valide:
        return 'valide';
      case StatutValidation.rejete:
        return 'rejete';
    }
  }

  static StatutValidation fromCode(String code) {
    switch (code) {
      case 'en_attente':
        return StatutValidation.enAttente;
      case 'valide':
        return StatutValidation.valide;
      case 'rejete':
        return StatutValidation.rejete;
      default:
        throw ArgumentError('Statut inconnu: $code');
    }
  }
}
