import 'package:dartz/dartz.dart';
import 'package:pokedex_pro/core/error/failures.dart';
import 'package:pokedex_pro/core/usecases/usecase.dart';
import 'package:pokedex_pro/domain/repositories/pokemon_repository.dart';

/// UseCase: toggle favorite status ของ Pokemon
/// return true = added to favorites, false = removed
class ToggleFavorite extends UseCase<bool, int> {
  final PokemonRepository repository;

  ToggleFavorite(this.repository);

  @override
  Future<Either<Failure, bool>> call(int params) {
    return repository.toggleFavorite(params);
  }
}
