import 'package:equatable/equatable.dart';

/// Pokemon Entity — ข้อมูลพื้นฐานสำหรับแสดงในหน้า list
/// Entity = business object ที่ไม่ผูกกับ data source ใดๆ
class Pokemon extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  /// URL สำหรับแสดงรูป sprite
  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  /// URL สำหรับแสดงรูป official artwork
  String get artworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  @override
  List<Object?> get props => [id, name, imageUrl, types];
}
