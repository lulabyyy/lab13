import 'package:flutter/material.dart';
import 'package:pokedex_pro/domain/entities/pokemon_detail.dart';

/// Widget แสดงว่า data มาจากแหล่งไหน
/// 🌐 PokeAPI | 🃏 TCG API | 💾 SQLite | 📦 Hive Cache
class DataSourceIndicator extends StatelessWidget {
  final DataSourceType dataSource;

  const DataSourceIndicator({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(dataSource.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            'Data from: ${dataSource.label}',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (dataSource) {
      case DataSourceType.api:
        return Colors.green;
      case DataSourceType.tcgApi:
        return Colors.orange;
      case DataSourceType.database:
        return Colors.blue;
      case DataSourceType.cache:
        return Colors.purple;
    }
  }
}
