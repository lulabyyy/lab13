import 'package:dartz/dartz.dart';
import 'package:pokedex_pro/core/error/exceptions.dart';
import 'package:pokedex_pro/core/error/failures.dart';
import 'package:pokedex_pro/core/network/network_info.dart';
import 'package:pokedex_pro/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_pro/data/datasources/pokemon_tcg_datasource.dart';
import 'package:pokedex_pro/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_pro/data/datasources/pokemon_cache_datasource.dart';
import 'package:pokedex_pro/data/models/pokemon_model.dart';
import 'package:pokedex_pro/domain/entities/pokemon.dart';
import 'package:pokedex_pro/domain/entities/pokemon_detail.dart';
import 'package:pokedex_pro/domain/entities/pokemon_card.dart';
import 'package:pokedex_pro/domain/repositories/pokemon_repository.dart';

/// === Repository Implementation ===
/// นี่คือหัวใจของ Fallback Strategy!
///
/// Fallback Chain:
/// PokeAPI (Primary) → SQLite (Local DB) → Hive (Cache)
///
/// เมื่อ source หนึ่งพัง จะลอง source ถัดไปอัตโนมัติ
/// พร้อมบันทึก data ลง local storage ทุกครั้งที่ดึงจาก API สำเร็จ
class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource remoteDataSource;
  final PokemonTcgDataSource tcgDataSource;
  final PokemonLocalDataSource localDataSource;
  final PokemonCacheDataSource cacheDataSource;
  final NetworkInfo networkInfo;

  PokemonRepositoryImpl({
    required this.remoteDataSource,
    required this.tcgDataSource,
    required this.localDataSource,
    required this.cacheDataSource,
    required this.networkInfo,
  });

  // ============================================
  // GET POKEMON LIST — Fallback Chain
  // ============================================
  @override
  Future<Either<Failure, List<Pokemon>>> getPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    // === Source 1: PokeAPI (Primary) ===
    if (await networkInfo.isConnected) {
      try {
        final pokemonList = await remoteDataSource.getPokemonList(
          offset: offset,
          limit: limit,
        );

        // ✅ สำเร็จ → บันทึกลง local storage
        _cacheListInBackground(pokemonList);

        return Right(pokemonList);
      } on ServerException catch (e) {
        // ❌ API พัง → ลอง source ถัดไป
        print('⚠️ PokeAPI failed: ${e.message}');
      }
    }

    // === Source 2: SQLite (Local DB) ===
    try {
      final localList = await localDataSource.getPokemonList(
        offset: offset,
        limit: limit,
      );
      return Right(localList);
    } on DatabaseException catch (e) {
      // ❌ SQLite พัง → ลอง source ถัดไป
      print('⚠️ SQLite failed: ${e.message}');
    }

    // === Source 3: Hive Cache (Last Resort) ===
    try {
      final cachedList = await cacheDataSource.getPokemonList(
        offset: offset,
        limit: limit,
      );
      return Right(cachedList);
    } on CacheException catch (e) {
      // ❌ ทุก source พังหมด!
      print('❌ All sources failed: ${e.message}');
    }

    // === ทุก source พัง → return Failure ===
    return const Left(ServerFailure(
      message: 'ไม่สามารถดึงข้อมูล Pokemon ได้ — กรุณาลองใหม่อีกครั้ง',
    ));
  }

  // ============================================
  // GET POKEMON DETAIL — Fallback Chain
  // ============================================
  @override
  Future<Either<Failure, PokemonDetail>> getPokemonDetail(int id) async {
    // === Source 1: PokeAPI ===
    if (await networkInfo.isConnected) {
      try {
        final detail = await remoteDataSource.getPokemonDetail(id);

        // ✅ สำเร็จ → บันทึกลง local storage
        _cacheDetailInBackground(detail);

        return Right(detail);
      } on ServerException catch (e) {
        print('⚠️ PokeAPI detail failed: ${e.message}');
      }
    }

    // === Source 2: SQLite ===
    try {
      final localDetail = await localDataSource.getPokemonDetail(id);
      return Right(localDetail);
    } on DatabaseException catch (e) {
      print('⚠️ SQLite detail failed: ${e.message}');
    }

    // === Source 3: Hive Cache ===
    try {
      final cachedDetail = await cacheDataSource.getPokemonDetail(id);
      return Right(cachedDetail);
    } on CacheException catch (e) {
      print('❌ All detail sources failed: ${e.message}');
    }

    return Left(NotFoundFailure(
      message: 'ไม่พบข้อมูล Pokemon #$id',
    ));
  }

  // ============================================
  // SEARCH — PokeAPI → SQLite
  // ============================================
  @override
  Future<Either<Failure, List<Pokemon>>> searchPokemon(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.searchPokemonByName(query);
        return Right([PokemonModel.fromEntity(Pokemon(
          id: result.id,
          name: result.name,
          imageUrl: result.imageUrl,
          types: result.types,
        ))]);
      } on ServerException {
        // PokeAPI search ต้อง exact name — ถ้า fail ลอง local
      }
    }

    // Fallback: ค้นหาจาก local DB (รองรับ partial match)
    try {
      final localResults = await localDataSource.searchPokemon(query);
      return Right(localResults);
    } on DatabaseException {
      return Left(NotFoundFailure(
        message: 'ไม่พบ Pokemon ชื่อ "$query"',
      ));
    }
  }

  // ============================================
  // GET POKEMON CARDS — TCG API only
  // ============================================
  @override
  Future<Either<Failure, List<PokemonCard>>> getPokemonCards(String name) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final cards = await tcgDataSource.searchCards(name);
      return Right(cards);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // ============================================
  // FAVORITES — SQLite only
  // ============================================
  @override
  Future<Either<Failure, List<Pokemon>>> getFavorites() async {
    try {
      final favorites = await localDataSource.getFavorites();
      return Right(favorites);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(int pokemonId) async {
    try {
      final result = await localDataSource.toggleFavorite(pokemonId);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int pokemonId) async {
    try {
      final result = await localDataSource.isFavorite(pokemonId);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  // ============================================
  // SYNC OFFLINE DATA
  // ============================================
  @override
  Future<Either<Failure, void>> syncOfflineData({int count = 50}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        message: 'ต้องมีอินเทอร์เน็ตเพื่อ sync ข้อมูล',
      ));
    }

    try {
      // ดึง pokemon ทีละ batch แล้วบันทึกลง SQLite
      const batchSize = 20;
      for (var offset = 0; offset < count; offset += batchSize) {
        final limit = (offset + batchSize > count) ? count - offset : batchSize;
        final pokemonList = await remoteDataSource.getPokemonList(
          offset: offset,
          limit: limit,
        );

        for (final pokemon in pokemonList) {
          await localDataSource.savePokemon(pokemon);

          // ดึง detail ด้วย (ถ้ามี id)
          try {
            if (pokemon.id > 0) {
              final detail = await remoteDataSource.getPokemonDetail(pokemon.id);
              await localDataSource.savePokemonDetail(detail);
            }
          } catch (_) {
            // ถ้า detail fail ก็ข้ามไป — ไม่ให้ sync ทั้งหมดพัง
          }
        }
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: 'Sync failed: ${e.message}'));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: 'Sync save failed: ${e.message}'));
    }
  }

  // ============================================
  // BACKGROUND CACHING HELPERS
  // ============================================
  void _cacheListInBackground(List<PokemonModel> list) {
    // บันทึกลง Hive cache (เร็ว)
    cacheDataSource.cachePokemonList(list).catchError((_) {});

    // บันทึกลง SQLite (ช้ากว่า แต่ reliable กว่า)
    for (final pokemon in list) {
      localDataSource.savePokemon(pokemon).catchError((_) {});
    }
  }

  void _cacheDetailInBackground(dynamic detail) {
    cacheDataSource.cachePokemonDetail(detail).catchError((_) {});
    localDataSource.savePokemonDetail(detail).catchError((_) {});
  }
}
