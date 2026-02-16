import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex_pro/domain/entities/pokemon.dart';
import 'package:pokedex_pro/presentation/bloc/pokemon_list/pokemon_list_bloc.dart';
import 'package:pokedex_pro/presentation/bloc/pokemon_list/pokemon_list_event.dart';
import 'package:pokedex_pro/presentation/bloc/pokemon_list/pokemon_list_state.dart';
import 'package:pokedex_pro/presentation/pages/pokemon_detail_page.dart';
import 'package:pokedex_pro/presentation/widgets/pokemon_card_widget.dart';

/// หน้ารายการ Pokemon — แสดง grid ของ Pokemon cards
/// รองรับ: search, pull-to-refresh, infinite scroll
class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // โหลด Pokemon list ตอนเปิดหน้า
    context.read<PokemonListBloc>().add(const LoadPokemonList());

    // ตรวจจับ scroll ถึงล่างสุด → load more
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PokemonListBloc>().add(const LoadMorePokemon());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔴 PokéDex Pro'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // TODO: navigate to favorites page
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== Search Bar =====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหา Pokemon...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<PokemonListBloc>().add(
                                const SearchPokemonEvent(''),
                              );
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              onChanged: (query) {
                context.read<PokemonListBloc>().add(SearchPokemonEvent(query));
              },
            ),
          ),

          // ===== Pokemon Grid =====
          Expanded(
            child: BlocBuilder<PokemonListBloc, PokemonListState>(
              builder: (context, state) {
                if (state is PokemonListLoading) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('กำลังโหลด Pokemon...'),
                      ],
                    ),
                  );
                }

                if (state is PokemonListError) {
                  return _buildErrorView(state);
                }

                List<Pokemon> pokemonList = [];
                bool isLoadingMore = false;
                bool hasReachedMax = false;

                if (state is PokemonListLoaded) {
                  pokemonList = state.pokemonList;
                  hasReachedMax = state.hasReachedMax;
                } else if (state is PokemonListLoadingMore) {
                  pokemonList = state.currentList;
                  isLoadingMore = true;
                }

                if (pokemonList.isEmpty) {
                  return const Center(
                    child: Text('ไม่พบ Pokemon', style: TextStyle(fontSize: 18)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<PokemonListBloc>().add(const RefreshPokemonList());
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: pokemonList.length + (isLoadingMore ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= pokemonList.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final pokemon = pokemonList[index];
                      return PokemonCardWidget(
                        pokemon: pokemon,
                        onTap: () => _navigateToDetail(pokemon),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(PokemonListError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PokemonListBloc>().add(const LoadPokemonList());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PokemonDetailPage(pokemonId: pokemon.id, pokemonName: pokemon.name),
      ),
    );
  }
}
