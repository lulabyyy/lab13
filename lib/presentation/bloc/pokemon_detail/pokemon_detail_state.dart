import 'package:equatable/equatable.dart';
import 'package:pokedex_pro/domain/entities/pokemon_detail.dart';
import 'package:pokedex_pro/domain/entities/pokemon_card.dart';

/// States สำหรับ PokemonDetailBloc
abstract class PokemonDetailState extends Equatable {
  const PokemonDetailState();

  @override
  List<Object?> get props => [];
}

class PokemonDetailInitial extends PokemonDetailState {
  const PokemonDetailInitial();
}

class PokemonDetailLoading extends PokemonDetailState {
  const PokemonDetailLoading();
}

/// โหลดสำเร็จ — มีข้อมูล detail + cards + favorite status
class PokemonDetailLoaded extends PokemonDetailState {
  final PokemonDetail detail;
  final List<PokemonCard> cards;
  final bool isFavorite;

  const PokemonDetailLoaded({
    required this.detail,
    this.cards = const [],
    this.isFavorite = false,
  });

  PokemonDetailLoaded copyWith({
    PokemonDetail? detail,
    List<PokemonCard>? cards,
    bool? isFavorite,
  }) {
    return PokemonDetailLoaded(
      detail: detail ?? this.detail,
      cards: cards ?? this.cards,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [detail, cards, isFavorite];
}

class PokemonDetailError extends PokemonDetailState {
  final String message;

  const PokemonDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
