import 'package:dio/dio.dart';
import 'package:pokedex_pro/core/constants/api_constants.dart';
import 'package:pokedex_pro/core/error/exceptions.dart';
import 'package:pokedex_pro/data/models/pokemon_model.dart';
import 'package:pokedex_pro/data/models/pokemon_detail_model.dart';

/// DataSource สำหรับ PokeAPI (Primary Source)
/// https://pokeapi.co/api/v2/
abstract class PokemonRemoteDataSource {
  /// ดึงรายการ Pokemon
  Future<List<PokemonModel>> getPokemonList({int offset = 0, int limit = 20});

  /// ดึงรายละเอียด Pokemon ตาม id
  Future<PokemonDetailModel> getPokemonDetail(int id);

  /// ค้นหา Pokemon ตามชื่อ
  Future<PokemonDetailModel> searchPokemonByName(String name);
}

class PokemonRemoteDataSourceImpl implements PokemonRemoteDataSource {
  final Dio dio;

  PokemonRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PokemonModel>> getPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      // Step 1: ดึง list ของชื่อ + URL
      final response = await dio.get(
        '${ApiConstants.pokeApiBaseUrl}${ApiConstants.pokemonEndpoint}',
        queryParameters: {'offset': offset, 'limit': limit},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch pokemon list',
          statusCode: response.statusCode,
        );
      }

      final results = response.data['results'] as List<dynamic>;
      return results
          .map((json) => PokemonModel.fromPokeApiListItem(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PokemonDetailModel> getPokemonDetail(int id) async {
    try {
      // Step 1: ดึง pokemon data (stats, types, abilities)
      final pokemonResponse = await dio.get(
        '${ApiConstants.pokeApiBaseUrl}${ApiConstants.pokemonEndpoint}/$id',
      );

      if (pokemonResponse.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch pokemon detail',
          statusCode: pokemonResponse.statusCode,
        );
      }

      var detail = PokemonDetailModel.fromPokeApi(
        pokemonResponse.data as Map<String, dynamic>,
      );

      // Step 2: ดึง species data (description, category)
      try {
        final speciesResponse = await dio.get(
          '${ApiConstants.pokeApiBaseUrl}${ApiConstants.pokemonSpeciesEndpoint}/$id',
        );
        if (speciesResponse.statusCode == 200) {
          detail = detail.withSpeciesData(
            speciesResponse.data as Map<String, dynamic>,
          );
        }
      } catch (_) {
        // species data เป็น optional — ถ้า fail ก็ไม่เป็นไร
      }

      return detail;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PokemonDetailModel> searchPokemonByName(String name) async {
    try {
      final response = await dio.get(
        '${ApiConstants.pokeApiBaseUrl}${ApiConstants.pokemonEndpoint}/${name.toLowerCase()}',
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Pokemon not found: $name',
          statusCode: response.statusCode,
        );
      }

      return PokemonDetailModel.fromPokeApi(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// แปลง DioException → custom Exception
  ServerException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException(
          message: 'Connection timeout to PokeAPI',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        return ServerException(
          message: e.response?.statusMessage ?? 'Bad response from PokeAPI',
          statusCode: e.response?.statusCode,
        );
      default:
        return ServerException(
          message: 'Network error: ${e.message}',
        );
    }
  }
}
