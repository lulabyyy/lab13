import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokedex_pro/domain/entities/pokemon.dart';
import 'package:pokedex_pro/presentation/widgets/type_badge.dart';

/// Widget สำหรับแสดง Pokemon card ในหน้า list (grid item)
class PokemonCardWidget extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const PokemonCardWidget({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(
      pokemon.types.isNotEmpty ? pokemon.types.first : '',
    );

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                typeColor.withOpacity(0.6),
                typeColor.withOpacity(0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Pokeball background decoration
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.catching_pokemon,
                  size: 120,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Name
                    Text(
                      pokemon.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Types
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: pokemon.types
                          .map((t) => TypeBadge(type: t, small: true))
                          .toList(),
                    ),

                    const Spacer(),

                    // Pokemon Image
                    Center(
                      child: Hero(
                        tag: 'pokemon-${pokemon.id}',
                        child: CachedNetworkImage(
                          imageUrl: pokemon.artworkUrl,
                          height: 80,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const SizedBox(
                            height: 80,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.catching_pokemon,
                            size: 60,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    const typeColors = {
      'normal': Color(0xFFA8A878), 'fire': Color(0xFFF08030),
      'water': Color(0xFF6890F0), 'electric': Color(0xFFF8D030),
      'grass': Color(0xFF78C850), 'ice': Color(0xFF98D8D8),
      'fighting': Color(0xFFC03028), 'poison': Color(0xFFA040A0),
      'ground': Color(0xFFE0C068), 'flying': Color(0xFFA890F0),
      'psychic': Color(0xFFF85888), 'bug': Color(0xFFA8B820),
      'rock': Color(0xFFB8A038), 'ghost': Color(0xFF705898),
      'dragon': Color(0xFF7038F8), 'dark': Color(0xFF705848),
      'steel': Color(0xFFB8B8D0), 'fairy': Color(0xFFEE99AC),
    };
    return typeColors[type] ?? const Color(0xFFA8A878);
  }
}
