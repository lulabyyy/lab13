import 'package:equatable/equatable.dart';

/// Events สำหรับ PokemonListBloc
/// UI dispatch event → BLoC handle → emit state
abstract class PokemonListEvent extends Equatable {
  const PokemonListEvent();

  @override
  List<Object?> get props => [];
}

/// โหลดรายการ Pokemon (หน้าแรก)
class LoadPokemonList extends PokemonListEvent {
  const LoadPokemonList();
}

/// โหลดเพิ่ม (infinite scroll)
class LoadMorePokemon extends PokemonListEvent {
  const LoadMorePokemon();
}

/// ค้นหา Pokemon ตามชื่อ
class SearchPokemonEvent extends PokemonListEvent {
  final String query;

  const SearchPokemonEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// รีเฟรช list (pull to refresh)
class RefreshPokemonList extends PokemonListEvent {
  const RefreshPokemonList();
}
