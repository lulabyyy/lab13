import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pokedex_pro/core/error/failures.dart';
import 'package:pokedex_pro/core/usecases/usecase.dart';
import 'package:pokedex_pro/domain/entities/pokemon.dart';
import 'package:pokedex_pro/domain/repositories/pokemon_repository.dart';

/// UseCase: ดึงรายการ Pokemon พร้อม pagination
///
/// การใช้งาน:
/// ```dart
/// final result = await getPokemonList(
///   GetPokemonListParams(offset: 0, limit: 20),
/// );
/// result.fold(
///   (failure) => print(failure.message),
///   (pokemonList) => print(pokemonList),
/// );
/// ```
class GetPokemonList extends UseCase<List<Pokemon>, GetPokemonListParams> {
  final PokemonRepository repository;

  GetPokemonList(this.repository);

  @override
  Future<Either<Failure, List<Pokemon>>> call(GetPokemonListParams params) {
    return repository.getPokemonList(
      offset: params.offset,
      limit: params.limit,
    );
  }
}

class GetPokemonListParams extends Equatable {
  final int offset;
  final int limit;

  const GetPokemonListParams({
    this.offset = 0,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [offset, limit];
}
