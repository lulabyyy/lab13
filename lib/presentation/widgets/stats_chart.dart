import 'package:flutter/material.dart';
import 'package:pokedex_pro/domain/entities/pokemon_detail.dart';

/// กราฟแท่งแสดง Base Stats ของ Pokemon
/// แต่ละ stat แสดงเป็น bar + ตัวเลข
class StatsChart extends StatelessWidget {
  final List<PokemonStat> stats;
  final Color typeColor;

  const StatsChart({
    super.key,
    required this.stats,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stats.map((stat) => _buildStatRow(stat)).toList(),
    );
  }

  Widget _buildStatRow(PokemonStat stat) {
    final maxStat = 255.0; // max base stat ใน Pokemon
    final percentage = stat.baseStat / maxStat;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Stat name
          SizedBox(
            width: 80,
            child: Text(
              stat.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),

          // Stat value
          SizedBox(
            width: 40,
            child: Text(
              '${stat.baseStat}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),

          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  stat.baseStat >= 100
                      ? typeColor
                      : stat.baseStat >= 50
                          ? typeColor.withOpacity(0.7)
                          : Colors.red[300]!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
