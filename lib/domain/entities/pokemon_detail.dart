import 'package:equatable/equatable.dart';

/// รายละเอียด Pokemon — stats, abilities, description
class PokemonDetail extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height; // in decimetres
  final int weight; // in hectograms
  final List<PokemonStat> stats;
  final List<String> abilities;
  final String? description;
  final String? category;
  final DataSourceType dataSource; // แสดงว่า data มาจากแหล่งไหน

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.stats,
    required this.abilities,
    this.description,
    this.category,
    this.dataSource = DataSourceType.api,
  });

  /// แปลงส่วนสูงเป็นเมตร
  double get heightInMeters => height / 10.0;

  /// แปลงน้ำหนักเป็นกิโลกรัม
  double get weightInKg => weight / 10.0;

  @override
  List<Object?> get props => [id, name, types, stats, abilities, dataSource];
}

/// Stats ของ Pokemon (HP, Attack, Defense, ...)
class PokemonStat extends Equatable {
  final String name;
  final int baseStat;
  final int effort;

  const PokemonStat({
    required this.name,
    required this.baseStat,
    this.effort = 0,
  });

  @override
  List<Object?> get props => [name, baseStat, effort];
}

/// Enum แสดงว่า data มาจาก source ไหน
/// ใช้แสดงใน UI ให้ผู้ใช้รู้ว่า data มาจากไหน
enum DataSourceType {
  api('PokeAPI', '🌐'),
  tcgApi('TCG API', '🃏'),
  database('SQLite', '💾'),
  cache('Hive Cache', '📦');

  final String label;
  final String icon;
  const DataSourceType(this.label, this.icon);
}
