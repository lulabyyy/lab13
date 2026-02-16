import 'package:pokedex_pro/domain/entities/pokemon_detail.dart';

/// PokemonDetailModel — รายละเอียดจาก PokeAPI
class PokemonDetailModel extends PokemonDetail {
  const PokemonDetailModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.types,
    required super.height,
    required super.weight,
    required super.stats,
    required super.abilities,
    super.description,
    super.category,
    super.dataSource,
  });

  /// สร้างจาก PokeAPI pokemon endpoint
  factory PokemonDetailModel.fromPokeApi(Map<String, dynamic> json) {
    return PokemonDetailModel(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['sprites']?['other']?['official-artwork']?['front_default']
          ?? json['sprites']?['front_default']
          ?? '',
      types: (json['types'] as List<dynamic>)
          .map((t) => t['type']['name'] as String)
          .toList(),
      height: json['height'] as int,
      weight: json['weight'] as int,
      stats: (json['stats'] as List<dynamic>).map((s) {
        return PokemonStat(
          name: _formatStatName(s['stat']['name'] as String),
          baseStat: s['base_stat'] as int,
          effort: s['effort'] as int,
        );
      }).toList(),
      abilities: (json['abilities'] as List<dynamic>)
          .map((a) => a['ability']['name'] as String)
          .toList(),
      dataSource: DataSourceType.api,
    );
  }

  /// เพิ่ม description + category จาก species endpoint
  PokemonDetailModel withSpeciesData(Map<String, dynamic> speciesJson) {
    // หา description ภาษาอังกฤษ
    final flavorEntries = speciesJson['flavor_text_entries'] as List<dynamic>? ?? [];
    final enFlavor = flavorEntries.firstWhere(
      (e) => e['language']['name'] == 'en',
      orElse: () => null,
    );

    // หา category (genus)
    final genera = speciesJson['genera'] as List<dynamic>? ?? [];
    final enGenus = genera.firstWhere(
      (g) => g['language']['name'] == 'en',
      orElse: () => null,
    );

    return PokemonDetailModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: types,
      height: height,
      weight: weight,
      stats: stats,
      abilities: abilities,
      description: enFlavor != null
          ? (enFlavor['flavor_text'] as String).replaceAll(RegExp(r'[\n\f\r]'), ' ')
          : null,
      category: enGenus != null ? enGenus['genus'] as String : null,
      dataSource: dataSource,
    );
  }

  /// สร้างจาก SQLite database
  factory PokemonDetailModel.fromDatabase(Map<String, dynamic> row) {
    return PokemonDetailModel(
      id: row['id'] as int,
      name: row['name'] as String,
      imageUrl: row['image_url'] as String,
      types: (row['types'] as String).split(','),
      height: row['height'] as int,
      weight: row['weight'] as int,
      stats: _parseStatsFromDb(row['stats'] as String),
      abilities: (row['abilities'] as String).split(','),
      description: row['description'] as String?,
      category: row['category'] as String?,
      dataSource: DataSourceType.database,
    );
  }

  /// สร้างจาก Hive cache
  factory PokemonDetailModel.fromCache(Map<String, dynamic> map) {
    return PokemonDetailModel(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      types: List<String>.from(map['types'] ?? []),
      height: map['height'] as int,
      weight: map['weight'] as int,
      stats: (map['stats'] as List<dynamic>).map((s) {
        return PokemonStat(
          name: s['name'] as String,
          baseStat: s['baseStat'] as int,
          effort: s['effort'] as int? ?? 0,
        );
      }).toList(),
      abilities: List<String>.from(map['abilities'] ?? []),
      description: map['description'] as String?,
      category: map['category'] as String?,
      dataSource: DataSourceType.cache,
    );
  }

  /// แปลงเป็น Map สำหรับ SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'types': types.join(','),
      'height': height,
      'weight': weight,
      'stats': stats.map((s) => '${s.name}:${s.baseStat}:${s.effort}').join('|'),
      'abilities': abilities.join(','),
      'description': description,
      'category': category,
    };
  }

  /// แปลงเป็น Map สำหรับ Hive cache
  Map<String, dynamic> toCache() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'types': types,
      'height': height,
      'weight': weight,
      'stats': stats.map((s) => {
        'name': s.name,
        'baseStat': s.baseStat,
        'effort': s.effort,
      }).toList(),
      'abilities': abilities,
      'description': description,
      'category': category,
    };
  }

  /// Parse stats string จาก DB: "HP:45:0|Attack:49:0|..."
  static List<PokemonStat> _parseStatsFromDb(String statsStr) {
    return statsStr.split('|').map((s) {
      final parts = s.split(':');
      return PokemonStat(
        name: parts[0],
        baseStat: int.tryParse(parts[1]) ?? 0,
        effort: int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0,
      );
    }).toList();
  }

  /// แปลงชื่อ stat จาก API ให้อ่านง่าย
  static String _formatStatName(String name) {
    switch (name) {
      case 'hp': return 'HP';
      case 'attack': return 'Attack';
      case 'defense': return 'Defense';
      case 'special-attack': return 'Sp. Atk';
      case 'special-defense': return 'Sp. Def';
      case 'speed': return 'Speed';
      default: return name;
    }
  }
}
