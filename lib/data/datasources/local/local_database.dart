import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Base SQLite locale utilisée pour le mode hors ligne.
///
/// Les points journaliers sont toujours écrits ici en premier
/// (`synchronise = 0`), puis remontés vers Firestore par [SyncService]
/// dès qu'une connexion réseau est disponible.
class LocalDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'keyla_point_ar.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE points_journaliers (
            id TEXT PRIMARY KEY,
            ar_id TEXT NOT NULL,
            equipe_id TEXT NOT NULL,
            date TEXT NOT NULL,
            nombre_recrutements INTEGER NOT NULL,
            latitude REAL,
            longitude REAL,
            commentaire TEXT,
            piece_jointe_path TEXT,
            statut TEXT NOT NULL DEFAULT 'en_attente',
            synchronise INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE users_cache (
            id TEXT PRIMARY KEY,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            telephone TEXT NOT NULL,
            role TEXT NOT NULL,
            equipe_id TEXT,
            actif INTEGER NOT NULL DEFAULT 1
          )
        ''');

        await db.execute('CREATE INDEX idx_points_ar ON points_journaliers(ar_id)');
        await db.execute('CREATE INDEX idx_points_sync ON points_journaliers(synchronise)');
      },
    );
  }
}
