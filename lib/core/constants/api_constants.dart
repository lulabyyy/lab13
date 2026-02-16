/// API endpoints และค่าคงที่สำหรับ data sources ทั้งหมด
class ApiConstants {
  // ===== PokeAPI (Primary) =====
  static const String pokeApiBaseUrl = 'https://pokeapi.co/api/v2';
  static const String pokemonEndpoint = '/pokemon';
  static const String pokemonSpeciesEndpoint = '/pokemon-species';
  static const String abilityEndpoint = '/ability';
  static const String evolutionChainEndpoint = '/evolution-chain';

  // ===== Pokémon TCG API (Fallback) =====
  static const String tcgApiBaseUrl = 'https://api.pokemontcg.io/v2';
  static const String tcgCardsEndpoint = '/cards';

  // ===== Timeouts =====
  static const int connectTimeout = 10000; // 10 seconds
  static const int receiveTimeout = 15000; // 15 seconds

  // ===== Pagination =====
  static const int defaultPageSize = 20;
  static const int maxPokemonId = 1010;

  // ===== Cache =====
  static const String hivePokemonBox = 'pokemon_cache';
  static const String hiveSettingsBox = 'settings';
  static const Duration cacheExpiry = Duration(hours: 24);

  // ===== SQLite =====
  static const String dbName = 'pokedex_pro.db';
  static const int dbVersion = 1;
  static const String tablePokemon = 'pokemon';
  static const String tableFavorites = 'favorites';
}
