import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pokedex_pro/core/constants/api_constants.dart';
import 'package:pokedex_pro/core/network/network_info.dart';
import 'package:pokedex_pro/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_pro/data/datasources/pokemon_tcg_datasource.dart';
import 'package:pokedex_pro/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_pro/data/datasources/pokemon_cache_datasource.dart';
import 'package:pokedex_pro/data/repositories/pokemon_repository_impl.dart';
import 'package:pokedex_pro/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_pro/domain/usecases/get_pokemon_list.dart';
import 'package:pokedex_pro/domain/usecases/get_pokemon_detail.dart';
import 'package:pokedex_pro/domain/usecases/search_pokemon.dart';
import 'package:pokedex_pro/domain/usecases/get_favorites.dart';
import 'package:pokedex_pro/domain/usecases/toggle_favorite.dart';
import 'package:pokedex_pro/domain/usecases/sync_offline_data.dart';
import 'package:pokedex_pro/presentation/bloc/pokemon_list/pokemon_list_bloc.dart';
import 'package:pokedex_pro/presentation/bloc/pokemon_detail/pokemon_detail_bloc.dart';

/// ===== Dependency Injection Setup =====
/// ใช้ get_it เป็น Service Locator
/// ลงทะเบียน dependencies ทั้งหมดที่นี่
///
/// Registration types:
/// - registerFactory → สร้าง instance ใหม่ทุกครั้งที่เรียก
/// - registerLazySingleton → สร้างครั้งเดียว, reuse ตลอด
/// - registerSingleton → สร้างทันที, reuse ตลอด

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ============================================
  // External
  // ============================================

  // Dio — HTTP client สำหรับ PokeAPI
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    ));
    // เพิ่ม logging interceptor สำหรับ debug
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (log) => print('🌐 $log'),
    ));
    return dio;
  });

  // Connectivity
  sl.registerLazySingleton(() => Connectivity());

  // Hive Box
  await Hive.initFlutter();
  final pokemonBox = await Hive.openBox(ApiConstants.hivePokemonBox);
  sl.registerLazySingleton(() => pokemonBox);

  // ============================================
  // Core
  // ============================================
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // ============================================
  // Data Sources
  // ============================================
  sl.registerLazySingleton<PokemonRemoteDataSource>(
    () => PokemonRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<PokemonTcgDataSource>(
    () => PokemonTcgDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<PokemonLocalDataSource>(
    () => PokemonLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<PokemonCacheDataSource>(
    () => PokemonCacheDataSourceImpl(pokemonBox: sl()),
  );

  // ============================================
  // Repository
  // ============================================
  sl.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(
      remoteDataSource: sl(),
      tcgDataSource: sl(),
      localDataSource: sl(),
      cacheDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ============================================
  // Use Cases
  // ============================================
  sl.registerLazySingleton(() => GetPokemonList(sl()));
  sl.registerLazySingleton(() => GetPokemonDetail(sl()));
  sl.registerLazySingleton(() => SearchPokemon(sl()));
  sl.registerLazySingleton(() => GetFavorites(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));
  sl.registerLazySingleton(() => SyncOfflineData(sl()));

  // ============================================
  // BLoCs
  // ============================================
  // BLoC ใช้ registerFactory → สร้าง instance ใหม่ทุกครั้ง
  // เพราะ BLoC มี lifecycle ที่ผูกกับ Widget
  sl.registerFactory(
    () => PokemonListBloc(
      getPokemonList: sl(),
      searchPokemon: sl(),
    ),
  );

  sl.registerFactory(
    () => PokemonDetailBloc(
      getPokemonDetail: sl(),
      toggleFavorite: sl(),
      repository: sl(),
    ),
  );
}
