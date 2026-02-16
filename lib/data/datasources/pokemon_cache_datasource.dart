import 'package:hive/hive.dart';
import 'package:pokedex_pro/core/constants/api_constants.dart';
import 'package:pokedex_pro/core/error/exceptions.dart';
import 'package:pokedex_pro/data/models/pokemon_model.dart';
import 'package:pokedex_pro/data/models/pokemon_detail_model.dart';

/// DataSource สำหรับ Hive Cache (Last Resort)
/// เก็บ data ที่เคยโหลดมาแล้ว — เร็วที่สุดแต่อาจไม่ up-to-date
abstract class PokemonCacheDataSource {
  /// ดึงรายการ Pokemon จาก cache
  Future<List<PokemonModel>> getPokemonList({int offset = 0, int limit = 20});

  /// ดึงรายละเอียด Pokemon จาก cache
  Future<PokemonDetailModel> getPokemonDetail(int id);

  /// บันทึก Pokemon list ลง cache
  Future<void> cachePokemonList(List<PokemonModel> pokemonList);

  /// บันทึก Pokemon detail ลง cache
  Future<void> cachePokemonDetail(PokemonDetailModel detail);

  /// ล้าง cache ทั้งหมด
  Future<void> clearCache();

  /// ตรวจสอบว่า cache ยัง valid อยู่ไหม
  bool isCacheValid(String key);
}

class PokemonCacheDataSourceImpl implements PokemonCacheDataSource {
  final Box<dynamic> pokemonBox;

  PokemonCacheDataSourceImpl({required this.pokemonBox});

  @override
  Future<List<PokemonModel>> getPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final key = 'pokemon_list_${offset}_$limit';
      final cached = pokemonBox.get(key);

      if (cached == null) {
        throw const CacheException(message: 'No cached pokemon list');
      }

      // ตรวจสอบ cache expiry
      if (!isCacheValid(key)) {
        throw const CacheException(message: 'Pokemon list cache expired');
      }

      final List<dynamic> list = cached['data'];
      return list
          .map((item) => PokemonModel.fromCache(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to read pokemon list from cache: $e');
    }
  }

  @override
  Future<PokemonDetailModel> getPokemonDetail(int id) async {
    try {
      final key = 'pokemon_detail_$id';
      final cached = pokemonBox.get(key);

      if (cached == null) {
        throw const CacheException(message: 'No cached pokemon detail');
      }

      if (!isCacheValid(key)) {
        throw const CacheException(message: 'Pokemon detail cache expired');
      }

      return PokemonDetailModel.fromCache(Map<String, dynamic>.from(cached['data']));
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to read pokemon detail from cache: $e');
    }
  }

  @override
  Future<void> cachePokemonList(List<PokemonModel> pokemonList) async {
    try {
      final key = 'pokemon_list_0_${pokemonList.length}';
      await pokemonBox.put(key, {
        'data': pokemonList.map((p) => p.toCache()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw CacheException(message: 'Failed to cache pokemon list: $e');
    }
  }

  @override
  Future<void> cachePokemonDetail(PokemonDetailModel detail) async {
    try {
      final key = 'pokemon_detail_${detail.id}';
      await pokemonBox.put(key, {
        'data': detail.toCache(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw CacheException(message: 'Failed to cache pokemon detail: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await pokemonBox.clear();
  }

  @override
  bool isCacheValid(String key) {
    final cached = pokemonBox.get(key);
    if (cached == null) return false;

    final timestamp = cached['timestamp'] as int?;
    if (timestamp == null) return false;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cachedTime) < ApiConstants.cacheExpiry;
  }
}
