import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pokedex_pro/core/error/failures.dart';

/// Base UseCase — ทุก UseCase implement interface นี้
/// [Type] = return type, [Params] = parameter type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// สำหรับ UseCase ที่ไม่ต้องการ parameter
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
