import 'package:pokedex_pro/domain/entities/pokemon_card.dart';

/// PokemonCardModel — การ์ดจาก TCG API
class PokemonCardModel extends PokemonCard {
  const PokemonCardModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.largeImageUrl,
    super.rarity,
    super.set,
    super.artist,
  });

  /// สร้างจาก TCG API JSON
  /// GET https://api.pokemontcg.io/v2/cards?q=name:pikachu
  factory PokemonCardModel.fromTcgApi(Map<String, dynamic> json) {
    return PokemonCardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['images']?['small'] as String?,
      largeImageUrl: json['images']?['large'] as String?,
      rarity: json['rarity'] as String?,
      set: json['set']?['name'] as String?,
      artist: json['artist'] as String?,
    );
  }
}
