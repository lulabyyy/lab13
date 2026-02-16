import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokedex_pro/domain/entities/pokemon_detail.dart';
import 'package:pokedex_pro/presentation/bloc/pokemon_detail/pokemon_detail_bloc.dart';
import 'package:pokedex_pro/presentation/bloc/pokemon_detail/pokemon_detail_event.dart';
import 'package:pokedex_pro/presentation/bloc/pokemon_detail/pokemon_detail_state.dart';
import 'package:pokedex_pro/presentation/widgets/stats_chart.dart';
import 'package:pokedex_pro/presentation/widgets/type_badge.dart';
import 'package:pokedex_pro/presentation/widgets/data_source_indicator.dart';
import 'package:get_it/get_it.dart';

/// หน้ารายละเอียด Pokemon — แสดง stats, types, abilities, TCG cards
class PokemonDetailPage extends StatelessWidget {
  final int pokemonId;
  final String pokemonName;

  const PokemonDetailPage({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<PokemonDetailBloc>()
        ..add(LoadPokemonDetail(pokemonId)),
      child: Scaffold(
        body: BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
          builder: (context, state) {
            if (state is PokemonDetailLoading) {
              return _buildLoadingView();
            }
            if (state is PokemonDetailError) {
              return _buildErrorView(context, state.message);
            }
            if (state is PokemonDetailLoaded) {
              return _buildDetailView(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          title: Text(pokemonName.toUpperCase()),
        ),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: Text(pokemonName.toUpperCase())),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PokemonDetailBloc>().add(LoadPokemonDetail(pokemonId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, PokemonDetailLoaded state) {
    final detail = state.detail;
    final typeColor = _getTypeColor(detail.types.isNotEmpty ? detail.types.first : '');

    return CustomScrollView(
      slivers: [
        // ===== Hero Image AppBar =====
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: typeColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              detail.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [typeColor.withOpacity(0.8), typeColor],
                    ),
                  ),
                ),
                Center(
                  child: Hero(
                    tag: 'pokemon-${detail.id}',
                    child: CachedNetworkImage(
                      imageUrl: detail.imageUrl,
                      height: 180,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const CircularProgressIndicator(),
                      errorWidget: (_, __, ___) => const Icon(Icons.error, size: 64),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Favorite button
            IconButton(
              icon: Icon(
                state.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: state.isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () {
                context.read<PokemonDetailBloc>().add(ToggleFavoriteEvent(pokemonId));
              },
            ),
          ],
        ),

        // ===== Content =====
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Data Source Indicator
                DataSourceIndicator(dataSource: detail.dataSource),
                const SizedBox(height: 16),

                // Pokemon ID + Category
                Row(
                  children: [
                    Text(
                      '#${detail.id.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (detail.category != null) ...[
                      const SizedBox(width: 12),
                      Text(detail.category!, style: TextStyle(color: Colors.grey[500])),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Types
                Wrap(
                  spacing: 8,
                  children: detail.types.map((t) => TypeBadge(type: t)).toList(),
                ),
                const SizedBox(height: 16),

                // Description
                if (detail.description != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        detail.description!,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Height & Weight
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.straighten,
                        label: 'Height',
                        value: '${detail.heightInMeters} m',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.fitness_center,
                        label: 'Weight',
                        value: '${detail.weightInKg} kg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Chart
                const Text(
                  'Base Stats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                StatsChart(stats: detail.stats, typeColor: typeColor),
                const SizedBox(height: 24),

                // Abilities
                const Text(
                  'Abilities',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detail.abilities.map((ability) {
                    return Chip(
                      label: Text(ability.replaceAll('-', ' ')),
                      backgroundColor: typeColor.withOpacity(0.15),
                    );
                  }).toList(),
                ),

                // TCG Cards
                if (state.cards.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    '🃏 TCG Cards',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.cards.length,
                      itemBuilder: (context, index) {
                        final card = state.cards[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: card.imageUrl ?? '',
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                card.rarity ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    const typeColors = {
      'normal': Color(0xFFA8A878),
      'fire': Color(0xFFF08030),
      'water': Color(0xFF6890F0),
      'electric': Color(0xFFF8D030),
      'grass': Color(0xFF78C850),
      'ice': Color(0xFF98D8D8),
      'fighting': Color(0xFFC03028),
      'poison': Color(0xFFA040A0),
      'ground': Color(0xFFE0C068),
      'flying': Color(0xFFA890F0),
      'psychic': Color(0xFFF85888),
      'bug': Color(0xFFA8B820),
      'rock': Color(0xFFB8A038),
      'ghost': Color(0xFF705898),
      'dragon': Color(0xFF7038F8),
      'dark': Color(0xFF705848),
      'steel': Color(0xFFB8B8D0),
      'fairy': Color(0xFFEE99AC),
    };
    return typeColors[type] ?? const Color(0xFFA8A878);
  }
}
