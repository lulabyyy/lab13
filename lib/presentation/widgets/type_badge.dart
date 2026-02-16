import 'package:flutter/material.dart';

/// Badge แสดง type ของ Pokemon (Fire, Water, Grass, ...)
/// รองรับ 2 ขนาด: ปกติ (detail page) และเล็ก (card)
class TypeBadge extends StatelessWidget {
  final String type;
  final bool small;

  const TypeBadge({super.key, required this.type, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[type] ?? Colors.grey;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 16,
        vertical: small ? 2 : 6,
      ),
      decoration: BoxDecoration(
        color: small ? Colors.white.withOpacity(0.25) : color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: small ? 10 : 13,
        ),
      ),
    );
  }

  static const _typeColors = {
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
}
