import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:pokedex_pro/core/constants/api_constants.dart';
import 'package:pokedex_pro/core/error/exceptions.dart' as app;
import 'package:pokedex_pro/data/models/pokemon_model.dart';
import 'package:pokedex_pro/data/models/pokemon_detail_model.dart';

/// DataSource สำหรับ SQLite (Offline Database)
/// เก็บ Pokemon data ที่ sync มาจาก API
abstract class PokemonLocalDataSource {
  /// ดึงรายการ Pokemon จาก local DB
  Future<List<PokemonModel>> getPokemonList({int offset = 0, int limit = 20});

  /// ดึงรายละเอียด Pokemon จาก local DB
  Future<PokemonDetailModel> getPokemonDetail(int id);

  /// ค้นหา Pokemon ใน local DB
  Future<List<PokemonModel>> searchPokemon(String query);

  /// บันทึก Pokemon ลง local DB
  Future<void> savePokemon(PokemonModel pokemon);

  /// บันทึกรายละเอียด Pokemon ลง local DB
  Future<void> savePokemonDetail(PokemonDetailModel detail);

  /// ดึง favorites
  Future<List<PokemonModel>> getFavorites();

  /// toggle favorite
  Future<bool> toggleFavorite(int pokemonId);

  /// ตรวจสอบว่าเป็น favorite หรือไม่
  Future<bool> isFavorite(int pokemonId);
}

class PokemonLocalDataSourceImpl implements PokemonLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, ApiConstants.dbName);

    return openDatabase(
      fullPath,
      version: ApiConstants.dbVersion,
      onCreate: (db, version) async {
        // สร้างตาราง pokemon
        await db.execute('''
          CREATE TABLE ${ApiConstants.tablePokemon} (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            image_url TEXT NOT NULL,
            types TEXT NOT NULL,
            height INTEGER DEFAULT 0,
            weight INTEGER DEFAULT 0,
            stats TEXT DEFAULT '',
            abilities TEXT DEFAULT '',
            description TEXT,
            category TEXT,
            updated_at INTEGER DEFAULT 0
          )
        ''');

        // สร้างตาราง favorites
        await db.execute('''
          CREATE TABLE ${ApiConstants.tableFavorites} (
            pokemon_id INTEGER PRIMARY KEY,
            added_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<PokemonModel>> getPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final db = await database;
      final results = await db.query(
        ApiConstants.tablePokemon,
        orderBy: 'id ASC',
        limit: limit,
        offset: offset,
      );

      if (results.isEmpty) {
        throw const app.DatabaseException(message: 'No pokemon data in local database');
      }

      return results.map((row) => PokemonModel.fromDatabase(row)).toList();
    } catch (e) {
      if (e is app.DatabaseException) rethrow;
      throw app.DatabaseException(message: 'Failed to query pokemon: $e');
    }
  }

  @override
  Future<PokemonDetailModel> getPokemonDetail(int id) async {
    try {
      final db = await database;
      final results = await db.query(
        ApiConstants.tablePokemon,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        throw const app.DatabaseException(message: 'Pokemon not found in local database');
      }

      return PokemonDetailModel.fromDatabase(results.first);
    } catch (e) {
      if (e is app.DatabaseException) rethrow;
      throw app.DatabaseException(message: 'Failed to query pokemon detail: $e');
    }
  }

  @override
  Future<List<PokemonModel>> searchPokemon(String query) async {
    try {
      final db = await database;
      final results = await db.query(
        ApiConstants.tablePokemon,
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'id ASC',
        limit: 20,
      );
      return results.map((row) => PokemonModel.fromDatabase(row)).toList();
    } catch (e) {
      throw app.DatabaseException(message: 'Failed to search pokemon: $e');
    }
  }

  @override
  Future<void> savePokemon(PokemonModel pokemon) async {
    try {
      final db = await database;
      await db.insert(
        ApiConstants.tablePokemon,
        {...pokemon.toDatabase(), 'updated_at': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw app.DatabaseException(message: 'Failed to save pokemon: $e');
    }
  }

  @override
  Future<void> savePokemonDetail(PokemonDetailModel detail) async {
    try {
      final db = await database;
      await db.insert(
        ApiConstants.tablePokemon,
        {...detail.toDatabase(), 'updated_at': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw app.DatabaseException(message: 'Failed to save pokemon detail: $e');
    }
  }

  @override
  Future<List<PokemonModel>> getFavorites() async {
    try {
      final db = await database;
      final results = await db.rawQuery('''
        SELECT p.* FROM ${ApiConstants.tablePokemon} p
        INNER JOIN ${ApiConstants.tableFavorites} f ON p.id = f.pokemon_id
        ORDER BY f.added_at DESC
      ''');
      return results.map((row) => PokemonModel.fromDatabase(row)).toList();
    } catch (e) {
      throw app.DatabaseException(message: 'Failed to get favorites: $e');
    }
  }

  @override
  Future<bool> toggleFavorite(int pokemonId) async {
    try {
      final db = await database;
      final existing = await db.query(
        ApiConstants.tableFavorites,
        where: 'pokemon_id = ?',
        whereArgs: [pokemonId],
      );

      if (existing.isNotEmpty) {
        await db.delete(
          ApiConstants.tableFavorites,
          where: 'pokemon_id = ?',
          whereArgs: [pokemonId],
        );
        return false; // removed from favorites
      } else {
        await db.insert(ApiConstants.tableFavorites, {
          'pokemon_id': pokemonId,
          'added_at': DateTime.now().millisecondsSinceEpoch,
        });
        return true; // added to favorites
      }
    } catch (e) {
      throw app.DatabaseException(message: 'Failed to toggle favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite(int pokemonId) async {
    try {
      final db = await database;
      final results = await db.query(
        ApiConstants.tableFavorites,
        where: 'pokemon_id = ?',
        whereArgs: [pokemonId],
      );
      return results.isNotEmpty;
    } catch (e) {
      throw app.DatabaseException(message: 'Failed to check favorite: $e');
    }
  }
}
