import 'package:flutter/material.dart';
import 'package:pokedex_pro/domain/entities/pokemon.dart';
import 'package:pokedex_pro/domain/usecases/get_favorites.dart';
import 'package:pokedex_pro/core/usecases/usecase.dart';
import 'package:pokedex_pro/presentation/pages/pokemon_detail_page.dart';
import 'package:pokedex_pro/presentation/widgets/pokemon_card_widget.dart';
import 'package:get_it/get_it.dart';

/// หน้า Favorites — แสดง Pokemon ที่ชอบ
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Pokemon> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() { _isLoading = true; _error = null; });

    final getFavorites = GetIt.I<GetFavorites>();
    final result = await getFavorites(NoParams());

    result.fold(
      (failure) => setState(() { _error = failure.message; _isLoading = false; }),
      (favorites) => setState(() { _favorites = favorites; _isLoading = false; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('❤️ Favorites'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _favorites.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('ยังไม่มี Pokemon ที่ชอบ', style: TextStyle(fontSize: 18)),
                          Text('กดหัวใจในหน้ารายละเอียดเพื่อเพิ่ม', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          final pokemon = _favorites[index];
                          return PokemonCardWidget(
                            pokemon: pokemon,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PokemonDetailPage(
                                    pokemonId: pokemon.id,
                                    pokemonName: pokemon.name,
                                  ),
                                ),
                              );
                              _loadFavorites(); // reload เมื่อกลับมา
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
