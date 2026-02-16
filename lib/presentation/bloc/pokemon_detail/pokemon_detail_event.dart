import 'package:equatable/equatable.dart';

/// Events สำหรับ PokemonDetailBloc
abstract class PokemonDetailEvent extends Equatable {
  const PokemonDetailEvent();

  @override
  List<Object?> get props => [];
}

/// โหลดรายละเอียด Pokemon
class LoadPokemonDetail extends PokemonDetailEvent {
  final int pokemonId;

  const LoadPokemonDetail(this.pokemonId);

  @override
  List<Object?> get props => [pokemonId];
}

/// toggle favorite
class ToggleFavoriteEvent extends PokemonDetailEvent {
  final int pokemonId;

  const ToggleFavoriteEvent(this.pokemonId);

  @override
  List<Object?> get props => [pokemonId];
}

/// โหลด Pokemon Cards จาก TCG API
class LoadPokemonCards extends PokemonDetailEvent {
  final String pokemonName;

  const LoadPokemonCards(this.pokemonName);

  @override
  List<Object?> get props => [pokemonName];
}
