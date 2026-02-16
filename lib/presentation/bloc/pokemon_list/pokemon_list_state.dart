import 'package:equatable/equatable.dart';
import 'package:pokedex_pro/domain/entities/pokemon.dart';

/// States สำหรับ PokemonListBloc
/// BLoC emit state → UI rebuild ตาม state ปัจจุบัน
abstract class PokemonListState extends Equatable {
  const PokemonListState();

  @override
  List<Object?> get props => [];
}

/// สถานะเริ่มต้น — ยังไม่ได้โหลด
class PokemonListInitial extends PokemonListState {
  const PokemonListInitial();
}

/// กำลังโหลด
class PokemonListLoading extends PokemonListState {
  const PokemonListLoading();
}

/// โหลดสำเร็จ — มีข้อมูล
class PokemonListLoaded extends PokemonListState {
  final List<Pokemon> pokemonList;
  final bool hasReachedMax;
  final int currentOffset;

  const PokemonListLoaded({
    required this.pokemonList,
    this.hasReachedMax = false,
    this.currentOffset = 0,
  });

  /// สร้าง state ใหม่จาก state เดิม + data เพิ่ม
  PokemonListLoaded copyWith({
    List<Pokemon>? pokemonList,
    bool? hasReachedMax,
    int? currentOffset,
  }) {
    return PokemonListLoaded(
      pokemonList: pokemonList ?? this.pokemonList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }

  @override
  List<Object?> get props => [pokemonList, hasReachedMax, currentOffset];
}

/// กำลังโหลดเพิ่ม (infinite scroll) — แสดง list เดิม + loading indicator ล่างสุด
class PokemonListLoadingMore extends PokemonListState {
  final List<Pokemon> currentList;
  final int currentOffset;

  const PokemonListLoadingMore({
    required this.currentList,
    required this.currentOffset,
  });

  @override
  List<Object?> get props => [currentList, currentOffset];
}

/// เกิด error
class PokemonListError extends PokemonListState {
  final String message;
  final List<Pokemon>? previousList; // เก็บ list เดิมไว้ให้ retry ได้

  const PokemonListError({
    required this.message,
    this.previousList,
  });

  @override
  List<Object?> get props => [message, previousList];
}
