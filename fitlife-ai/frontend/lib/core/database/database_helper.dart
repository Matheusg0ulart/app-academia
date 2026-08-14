// lib/core/database/database_helper.dart
//
// Singleton de conexão com o banco SQLite local.
// Garante que apenas uma instância do banco está aberta.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'local_schema.dart';

class DatabaseHelper {
  // ── Singleton ───────────────────────────────────────────────
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static Database? _database;

  /// Retorna a instância do banco, criando se necessário.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ── Inicialização ────────────────────────────────────────────
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, 'fitlife_ai.db');

    return openDatabase(
      path,
      version: kDatabaseVersion,
      onCreate:  _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // Habilita foreign keys no SQLite
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Executa cada statement separado por ';'
    for (final sql in _splitStatements(kCreateTablesSQL)) {
      await db.execute(sql);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Futuras migrações podem ser adicionadas aqui por versão
    // Exemplo: if (oldVersion < 2) { await db.execute(...); }
  }

  // ── Helpers ──────────────────────────────────────────────────

  /// Divide um bloco de SQL em statements individuais.
  List<String> _splitStatements(String sql) {
    return sql
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // ── CRUD genérico ─────────────────────────────────────────────

  /// Insere um registro e retorna o ID gerado.
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Atualiza registros por condição WHERE.
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// Remove registros por condição WHERE.
  Future<int> delete(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Executa uma query SELECT e retorna lista de mapas.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      columns:   columns,
      where:     where,
      whereArgs: whereArgs,
      orderBy:   orderBy,
      limit:     limit,
      offset:    offset,
    );
  }

  /// Executa um SQL raw (JOINs, etc.).
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? args,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  /// Executa um bloco dentro de uma transação.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  /// Fecha o banco (útil em testes).
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
