import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:keyla_point_ar/core/router/app_router.dart';
import 'package:keyla_point_ar/core/theme/app_theme.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    try {
      await initializeDateFormatting('fr_FR', null);
      await Firebase.initializeApp();
      runApp(const ProviderScope(child: KeylaPointArApp()));
    } catch (e, stack) {
      runApp(_ErrorApp(error: e.toString(), stack: stack.toString()));
    }
  }, (error, stack) {
    runApp(_ErrorApp(error: error.toString(), stack: stack.toString()));
  });
}

class _ErrorApp extends StatelessWidget {
  final String error;
  final String stack;
  const _ErrorApp({required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Erreur au démarrage')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SelectableText(stack, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class KeylaPointArApp extends ConsumerWidget {
  const KeylaPointArApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'KEYLA POINT AR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
