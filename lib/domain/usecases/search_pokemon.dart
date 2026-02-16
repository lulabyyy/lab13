import 'package:dartz/dartz.dart';
import 'package:pokedex_pro/core/error/failures.dart';
import 'package:pokedex_pro/core/usecases/usecase.dart';
import 'package:pokedex_pro/domain/entities/pokemon.dart';
import 'package:pokedex_pro/domain/repositories/pokemon_repository.dart';

/// UseCase: ค้นหา Pokemon ตามชื่อ
class SearchPokemon extends UseCase<List<Pokemon>, String> {
  final PokemonRepository repository;

  SearchPokemon(this.repository);

  @override
  Future<Either<Failure, List<Pokemon>>> call(String params) {
    return repository.searchPokemon(params);
  }
}
