import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex_pro/injection.dart';
import 'package:pokedex_pro/presentation/bloc/pokemon_list/pokemon_list_bloc.dart';
import 'package:pokedex_pro/presentation/pages/pokemon_list_page.dart';

/// ===== PokéDex Pro - Clean Architecture Lab =====
///
/// สาธิต Flutter Clean Architecture ด้วย PokéDex app
/// - Domain Layer: Entities, UseCases, Repository Interface
/// - Data Layer: Models, DataSources (4 แหล่ง), Repository Implementation
/// - Presentation Layer: BLoC + Flutter UI
///
/// Multi-Source Fallback Chain:
/// PokeAPI (Primary) → SQLite (Local DB) → Hive (Cache)
///
/// เปิดดู HTML teaching material ใน pokedex-lab/ ควบคู่กัน

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ลงทะเบียน dependencies ทั้งหมด
  await initDependencies();

  runApp(const PokedexProApp());
}

class PokedexProApp extends StatelessWidget {
  const PokedexProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokéDex Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        brightness: Brightness.dark,
      ),
      home: BlocProvider(
        create: (_) => sl<PokemonListBloc>(),
        child: const PokemonListPage(),
      ),
    );
  }
}
