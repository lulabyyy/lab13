import 'package:dartz/dartz.dart';
import 'package:pokedex_pro/core/error/failures.dart';
import 'package:pokedex_pro/domain/entities/pokemon.dart';
import 'package:pokedex_pro/domain/entities/pokemon_detail.dart';
import 'package:pokedex_pro/domain/entities/pokemon_card.dart';

/// Abstract Repository — Domain layer กำหนด interface
/// Data layer จะ implement จริง (Dependency Inversion)
///
/// ทุก method return Either<Failure, T>:
/// - Left(Failure) = error
/// - Right(T) = success data
abstract class PokemonRepository {
  /// ดึงรายการ Pokemon พร้อม pagination
  Future<Either<Failure, List<Pokemon>>> getPokemonList({
    int offset = 0,
    int limit = 20,
  });

  /// ดึงรายละเอียด Pokemon ตาม id หรือ name
  Future<Either<Failure, PokemonDetail>> getPokemonDetail(int id);

  /// ค้นหา Pokemon ตามชื่อ
  Future<Either<Failure, List<Pokemon>>> searchPokemon(String query);

  /// ดึง Pokemon Card จาก TCG API
  Future<Either<Failure, List<PokemonCard>>> getPokemonCards(String name);

  /// ดึง favorites list
  Future<Either<Failure, List<Pokemon>>> getFavorites();

  /// toggle favorite (add/remove)
  Future<Either<Failure, bool>> toggleFavorite(int pokemonId);

  /// ตรวจสอบว่า Pokemon นี้เป็น favorite หรือไม่
  Future<Either<Failure, bool>> isFavorite(int pokemonId);

  /// sync data จาก API ลง local database สำหรับ offline use
  Future<Either<Failure, void>> syncOfflineData({int count = 50});
}
