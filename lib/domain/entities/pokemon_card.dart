import 'package:equatable/equatable.dart';

/// Pokemon Card — ข้อมูลจาก TCG API (การ์ดโปเกมอน)
/// ใช้ร่วมกับ PokeAPI data เพื่อ merge ข้อมูล
class PokemonCard extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? largeImageUrl;
  final String? rarity;
  final String? set;
  final String? artist;

  const PokemonCard({
    required this.id,
    required this.name,
    this.imageUrl,
    this.largeImageUrl,
    this.rarity,
    this.set,
    this.artist,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, rarity];
}
