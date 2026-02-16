import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex_pro/domain/usecases/get_pokemon_detail.dart';
import 'package:pokedex_pro/domain/usecases/toggle_favorite.dart';
import 'package:pokedex_pro/domain/repositories/pokemon_repository.dart';
import 'pokemon_detail_event.dart';
import 'pokemon_detail_state.dart';

/// PokemonDetailBloc — จัดการ state ของหน้ารายละเอียด Pokemon
///
/// Event Flow:
/// LoadPokemonDetail → [Loading] → getDetail() + getCards() + isFavorite() → [Loaded]
/// ToggleFavoriteEvent → toggleFavorite() → [Loaded with updated isFavorite]
class PokemonDetailBloc extends Bloc<PokemonDetailEvent, PokemonDetailState> {
  final GetPokemonDetail getPokemonDetail;
  final ToggleFavorite toggleFavorite;
  final PokemonRepository repository;

  PokemonDetailBloc({
    required this.getPokemonDetail,
    required this.toggleFavorite,
    required this.repository,
  }) : super(const PokemonDetailInitial()) {
    on<LoadPokemonDetail>(_onLoadDetail);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<LoadPokemonCards>(_onLoadCards);
  }

  Future<void> _onLoadDetail(
    LoadPokemonDetail event,
    Emitter<PokemonDetailState> emit,
  ) async {
    emit(const PokemonDetailLoading());

    // ดึง detail
    final detailResult = await getPokemonDetail(event.pokemonId);

    await detailResult.fold(
      (failure) async {
        emit(PokemonDetailError(failure.message));
      },
      (detail) async {
        // ดึง favorite status
        bool isFav = false;
        final favResult = await repository.isFavorite(event.pokemonId);
        favResult.fold((_) {}, (val) => isFav = val);

        emit(PokemonDetailLoaded(
          detail: detail,
          isFavorite: isFav,
        ));

        // ดึง cards แบบ async (ไม่ block UI)
        add(LoadPokemonCards(detail.name));
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<PokemonDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PokemonDetailLoaded) return;

    final result = await toggleFavorite(event.pokemonId);

    result.fold(
      (_) {}, // ถ้า fail ก็ไม่เปลี่ยน state
      (isNowFavorite) {
        emit(currentState.copyWith(isFavorite: isNowFavorite));
      },
    );
  }

  Future<void> _onLoadCards(
    LoadPokemonCards event,
    Emitter<PokemonDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PokemonDetailLoaded) return;

    final result = await repository.getPokemonCards(event.pokemonName);

    result.fold(
      (_) {}, // ถ้า fail ก็ไม่แสดง cards — ไม่ใช่ critical
      (cards) {
        emit(currentState.copyWith(cards: cards));
      },
    );
  }
}
