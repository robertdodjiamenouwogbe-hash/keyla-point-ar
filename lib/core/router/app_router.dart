import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keyla_point_ar/core/constants/user_role.dart';
import 'package:keyla_point_ar/presentation/admin/admin_dashboard_screen.dart';
import 'package:keyla_point_ar/presentation/agent_recruteur/ar_dashboard_screen.dart';
import 'package:keyla_point_ar/presentation/auth/login_screen.dart';
import 'package:keyla_point_ar/presentation/shared/providers/core_providers.dart';
import 'package:keyla_point_ar/presentation/superviseur/superviseur_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final onLoginPage = state.matchedLocation == '/login';

      if (user == null) {
        return onLoginPage ? null : '/login';
      }

      if (onLoginPage) {
        return switch (user.role) {
          UserRole.administrateur => '/admin',
          UserRole.superviseur => '/superviseur',
          UserRole.agentRecruteur => '/agent',
        };
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/superviseur', builder: (context, state) => const SuperviseurDashboardScreen()),
      GoRoute(path: '/agent', builder: (context, state) => const ArDashboardScreen()),
    ],
  );
});

/// Fait recalculer les redirections de go_router à chaque changement
/// d'état d'authentification.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
