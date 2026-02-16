import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex_pro/core/constants/api_constants.dart';
import 'package:pokedex_pro/domain/usecases/get_pokemon_list.dart';
import 'package:pokedex_pro/domain/usecases/search_pokemon.dart';
import 'pokemon_list_event.dart';
import 'pokemon_list_state.dart';

/// PokemonListBloc — จัดการ state ของหน้ารายการ Pokemon
///
/// Event Flow:
/// LoadPokemonList → [Loading] → getPokemonList() → [Loaded] or [Error]
/// LoadMorePokemon → [LoadingMore] → getPokemonList(offset) → [Loaded] or [Error]
/// SearchPokemonEvent → [Loading] → searchPokemon() → [Loaded] or [Error]
class PokemonListBloc extends Bloc<PokemonListEvent, PokemonListState> {
  final GetPokemonList getPokemonList;
  final SearchPokemon searchPokemon;

  PokemonListBloc({
    required this.getPokemonList,
    required this.searchPokemon,
  }) : super(const PokemonListInitial()) {
    on<LoadPokemonList>(_onLoadPokemonList);
    on<LoadMorePokemon>(_onLoadMorePokemon);
    on<SearchPokemonEvent>(_onSearchPokemon);
    on<RefreshPokemonList>(_onRefreshPokemonList);
  }

  Future<void> _onLoadPokemonList(
    LoadPokemonList event,
    Emitter<PokemonListState> emit,
  ) async {
    emit(const PokemonListLoading());

    final result = await getPokemonList(
      const GetPokemonListParams(offset: 0, limit: ApiConstants.defaultPageSize),
    );

    result.fold(
      (failure) => emit(PokemonListError(message: failure.message)),
      (pokemonList) => emit(PokemonListLoaded(
        pokemonList: pokemonList,
        hasReachedMax: pokemonList.length < ApiConstants.defaultPageSize,
        currentOffset: pokemonList.length,
      )),
    );
  }

  Future<void> _onLoadMorePokemon(
    LoadMorePokemon event,
    Emitter<PokemonListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PokemonListLoaded || currentState.hasReachedMax) return;

    emit(PokemonListLoadingMore(
      currentList: currentState.pokemonList,
      currentOffset: currentState.currentOffset,
    ));

    final result = await getPokemonList(
      GetPokemonListParams(
        offset: currentState.currentOffset,
        limit: ApiConstants.defaultPageSize,
      ),
    );

    result.fold(
      (failure) => emit(PokemonListError(
        message: failure.message,
        previousList: currentState.pokemonList,
      )),
      (newPokemon) => emit(PokemonListLoaded(
        pokemonList: [...currentState.pokemonList, ...newPokemon],
        hasReachedMax: newPokemon.length < ApiConstants.defaultPageSize,
        currentOffset: currentState.currentOffset + newPokemon.length,
      )),
    );
  }

  Future<void> _onSearchPokemon(
    SearchPokemonEvent event,
    Emitter<PokemonListState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadPokemonList());
      return;
    }

    emit(const PokemonListLoading());

    final result = await searchPokemon(event.query);

    result.fold(
      (failure) => emit(PokemonListError(message: failure.message)),
      (results) => emit(PokemonListLoaded(
        pokemonList: results,
        hasReachedMax: true,
      )),
    );
  }

  Future<void> _onRefreshPokemonList(
    RefreshPokemonList event,
    Emitter<PokemonListState> emit,
  ) async {
    // Refresh = โหลดใหม่จาก offset 0
    add(const LoadPokemonList());
  }
}
