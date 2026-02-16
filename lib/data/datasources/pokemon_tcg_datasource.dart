import 'package:dio/dio.dart';
import 'package:pokedex_pro/core/constants/api_constants.dart';
import 'package:pokedex_pro/core/error/exceptions.dart';
import 'package:pokedex_pro/data/models/pokemon_card_model.dart';

/// DataSource สำหรับ Pokémon TCG API (Fallback Source)
/// https://api.pokemontcg.io/v2/
abstract class PokemonTcgDataSource {
  /// ค้นหา Pokemon cards ตามชื่อ
  Future<List<PokemonCardModel>> searchCards(String name);
}

class PokemonTcgDataSourceImpl implements PokemonTcgDataSource {
  final Dio dio;

  PokemonTcgDataSourceImpl({required this.dio});

  @override
  Future<List<PokemonCardModel>> searchCards(String name) async {
    try {
      final response = await dio.get(
        '${ApiConstants.tcgApiBaseUrl}${ApiConstants.tcgCardsEndpoint}',
        queryParameters: {
          'q': 'name:$name',
          'pageSize': 10,
          'orderBy': '-set.releaseDate',
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch TCG cards',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((json) => PokemonCardModel.fromTcgApi(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: 'TCG API error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
