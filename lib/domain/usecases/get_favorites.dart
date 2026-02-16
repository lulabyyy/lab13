import 'package:dartz/dartz.dart';
import 'package:pokedex_pro/core/error/failures.dart';
import 'package:pokedex_pro/core/usecases/usecase.dart';
import 'package:pokedex_pro/domain/entities/pokemon.dart';
import 'package:pokedex_pro/domain/repositories/pokemon_repository.dart';

/// UseCase: ดึงรายการ Pokemon ที่ชอบ (favorites)
class GetFavorites extends UseCase<List<Pokemon>, NoParams> {
  final PokemonRepository repository;

  GetFavorites(this.repository);

  @override
  Future<Either<Failure, List<Pokemon>>> call(NoParams params) {
    return repository.getFavorites();
  }
}
