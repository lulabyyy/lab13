import 'package:dartz/dartz.dart';
import 'package:pokedex_pro/core/error/failures.dart';
import 'package:pokedex_pro/core/usecases/usecase.dart';
import 'package:pokedex_pro/domain/entities/pokemon_detail.dart';
import 'package:pokedex_pro/domain/repositories/pokemon_repository.dart';

/// UseCase: ดึงรายละเอียด Pokemon ตาม ID
class GetPokemonDetail extends UseCase<PokemonDetail, int> {
  final PokemonRepository repository;

  GetPokemonDetail(this.repository);

  @override
  Future<Either<Failure, PokemonDetail>> call(int params) {
    return repository.getPokemonDetail(params);
  }
}
