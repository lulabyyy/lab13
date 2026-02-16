import 'package:pokedex_pro/domain/entities/pokemon.dart';
import 'package:pokedex_pro/domain/entities/pokemon_detail.dart';

/// PokemonModel — Data layer model ที่รู้วิธี serialize/deserialize
/// extends Pokemon entity จาก Domain layer
class PokemonModel extends Pokemon {
  const PokemonModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.types,
  });

  /// สร้างจาก PokeAPI JSON response
  /// GET https://pokeapi.co/api/v2/pokemon/{id}
  factory PokemonModel.fromPokeApi(Map<String, dynamic> json) {
    return PokemonModel(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['sprites']?['other']?['official-artwork']?['front_default']
          ?? json['sprites']?['front_default']
          ?? '',
      types: (json['types'] as List<dynamic>?)
          ?.map((t) => t['type']['name'] as String)
          .toList() ?? [],
    );
  }

  /// สร้างจาก PokeAPI list endpoint (มีแค่ name + url)
  /// GET https://pokeapi.co/api/v2/pokemon?offset=0&limit=20
  factory PokemonModel.fromPokeApiListItem(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final id = int.parse(url.split('/').where((s) => s.isNotEmpty).last);
    return PokemonModel(
      id: id,
      name: json['name'] as String,
      imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      types: [], // list endpoint ไม่มี types — ต้อง fetch detail เพิ่ม
    );
  }

  /// สร้างจาก TCG API JSON (fallback)
  factory PokemonModel.fromTcgApi(Map<String, dynamic> json) {
    final name = (json['name'] as String).split(' ').first.toLowerCase();
    return PokemonModel(
      id: 0, // TCG API ไม่มี national dex number
      name: name,
      imageUrl: json['images']?['small'] ?? '',
      types: (json['types'] as List<dynamic>?)
          ?.map((t) => (t as String).toLowerCase())
          .toList() ?? [],
    );
  }

  /// สร้างจาก SQLite database row
  factory PokemonModel.fromDatabase(Map<String, dynamic> row) {
    return PokemonModel(
      id: row['id'] as int,
      name: row['name'] as String,
      imageUrl: row['image_url'] as String,
      types: (row['types'] as String).split(','),
    );
  }

  /// สร้างจาก Hive cache (Map)
  factory PokemonModel.fromCache(Map<String, dynamic> map) {
    return PokemonModel(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      types: List<String>.from(map['types'] ?? []),
    );
  }

  /// แปลงเป็น Map สำหรับ SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'types': types.join(','),
    };
  }

  /// แปลงเป็น Map สำหรับ Hive cache
  Map<String, dynamic> toCache() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'types': types,
    };
  }

  /// แปลง Entity → Model
  factory PokemonModel.fromEntity(Pokemon entity) {
    return PokemonModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      types: entity.types,
    );
  }
}
