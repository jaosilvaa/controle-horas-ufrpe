import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:controle_horas/src/data/models/atividade_model.dart';

class DatabaseService {
  static DatabaseService? _instance;
  Database? _db;

  DatabaseService._();
  factory DatabaseService() => _instance ??= DatabaseService._();

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    // Desktop (Windows / Linux / macOS) → precisa de FFI
    // Mobile (Android / iOS)            → sqflite nativo, sem FFI
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      ffi.sqfliteFfiInit();
      databaseFactory = ffi.databaseFactoryFfi;
    }

    final dir = await getDatabasesPath(); // vem de sqflite, funciona em todos
    final path = p.join(dir, 'controle_horas.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE atividades (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          natureza TEXT NOT NULL,
          classificacao TEXT NOT NULL,
          tipo TEXT NOT NULL,
          titulo TEXT NOT NULL,
          horas_calculadas REAL NOT NULL,
          data_criacao TEXT NOT NULL,
          data_inicial TEXT,
          data_final TEXT
        )
      '''),
    );
  }

  Future<AtividadeModel> inserir(AtividadeModel a) async {
    final db = await database;
    final id = await db.insert('atividades', a.toMap());
    return a.copyWith(id: id);
  }

  Future<List<AtividadeModel>> listarTodas() async {
    final db = await database;
    final rows = await db.query('atividades', orderBy: 'data_criacao DESC');
    return rows.map(AtividadeModel.fromMap).toList();
  }

  Future<List<AtividadeModel>> listarPorNatureza(String natureza) async {
    final db = await database;
    final rows = await db.query(
      'atividades',
      where: 'natureza = ?',
      whereArgs: [natureza],
      orderBy: 'data_criacao DESC',
    );
    return rows.map(AtividadeModel.fromMap).toList();
  }

  Future<AtividadeModel> atualizar(AtividadeModel a) async {
    final db = await database;
    await db.update(
      'atividades',
      a.toMap(),
      where: 'id = ?',
      whereArgs: [a.id],
    );
    return a;
  }

  Future<void> deletar(int id) async {
    final db = await database;
    await db.delete('atividades', where: 'id = ?', whereArgs: [id]);
  }
}
