import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pokedex_pro/core/error/failures.dart';
import 'package:pokedex_pro/core/usecases/usecase.dart';
import 'package:pokedex_pro/domain/repositories/pokemon_repository.dart';

/// UseCase: sync data จาก API ลง local database สำหรับ offline use
class SyncOfflineData extends UseCase<void, SyncParams> {
  final PokemonRepository repository;

  SyncOfflineData(this.repository);

  @override
  Future<Either<Failure, void>> call(SyncParams params) {
    return repository.syncOfflineData(count: params.count);
  }
}

class SyncParams extends Equatable {
  final int count;
  const SyncParams({this.count = 50});

  @override
  List<Object?> get props => [count];
}
