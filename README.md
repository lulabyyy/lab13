# PokéDex Pro - Flutter Clean Architecture Project

โครงการตัวอย่าง Flutter ที่สอน Clean Architecture + BLoC pattern พร้อมระบบ fallback data source ในการดึงข้อมูล Pokémon จาก PokeAPI

---

## 📱 ชื่อโครงการและคำอธิบาย

**PokéDex Pro** คือ Flutter application สำหรับดูข้อมูล Pokémon ที่ implements:
- **Clean Architecture** (Domain → Data → Presentation layers)
- **BLoC Pattern** สำหรับ state management
- **Fallback Data Source Chain**: Remote API → Local Cache (Hive) → Mock Data
- **Error Handling** และ custom error UI
- **PokeAPI Integration** เพื่อดึงข้อมูล Pokémon จาก https://pokeapi.co

**แอปพิเคชันมีฟีเจอร์:**
- 📋 List ทั้ง Pokémon ทั้งหมด
- 🔍 Detail view แต่ละ Pokémon (stats, types, abilities)
- ⚡ Filter โดย Type (Fire, Water, Grass, etc.)
- 🔄 Offline support ด้วย local cache
- ⚙️ Fallback mechanism เมื่อ API ล้มเหลว
- 📚 8 exercises เพื่อฝึกฝน architecture

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│          PRESENTATION LAYER (UI)                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Pages: PokemonListPage, PokemonDetailPage       │   │
│  │ BLoC: PokemonListBloc, PokemonDetailBloc        │   │
│  │ Widgets: PokemonCard, StatsView, AbilitiesView │   │
│  └─────────────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────────────┘
                   │ (depends on)
┌──────────────────▼──────────────────────────────────────┐
│          DOMAIN LAYER (Business Logic)                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Entities: Pokemon, PokemonDetail, Ability       │   │
│  │ Repositories (abstract): PokemonRepository      │   │
│  │ UseCases: GetPokemonList, GetPokemonDetail      │   │
│  │           GetAbilityDetail, GetEvolutionChain   │   │
│  └─────────────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────────────┘
                   │ (depends on)
┌──────────────────▼──────────────────────────────────────┐
│          DATA LAYER (Repository Implementation)         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ RepositoryImpl: PokemonRepositoryImpl            │   │
│  │ DataSources:                                    │   │
│  │  • PokemonRemoteDataSource (PokeAPI)            │   │
│  │  • PokemonLocalDataSource (Hive)                │   │
│  │  • PokemonMockDataSource (fallback)             │   │
│  │ Models: PokemonModel, PokemonDetailModel       │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Fallback Data Source Chain

```
                    ┌─────────────────────┐
                    │  BLoC requests      │
                    │  Pokemon data       │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │  Try Remote Source  │
                    │  (PokeAPI)          │
                    └──────┬────┬─────────┘
                           │    │
                      ✓ Success  ✗ Error/Timeout
                           │    │
                           │    └──────────────────────┐
                           │                           │
                    ┌──────▼────────────┐   ┌──────────▼──────────┐
                    │ Cache + Return    │   │ Try Local Cache     │
                    │ (save to Hive)    │   │ (Hive database)     │
                    └──────────────────┘   └────────┬────┬───────┘
                                                    │    │
                                               ✓ Hit  ✗ Miss
                                                    │    │
                                                    │    └────────────┐
                                                    │                 │
                                           ┌────────▼───┐   ┌────────▼────────┐
                                           │ Return     │   │ Try Mock Source │
                                           │ cached     │   │ (hardcoded)     │
                                           │ data       │   │                 │
                                           └────────────┘   └────────┬────────┘
                                                                    │
                                                            ┌───────▼────────┐
                                                            │ Return mock    │
                                                            │ data or error  │
                                                            └────────────────┘
```

**Fallback Strategy:**
1. **Remote (PokeAPI)**: ดึงข้อมูล real-time จาก API, บันทึก cache
2. **Local (Hive)**: ใช้เมื่อ remote fail, รวดเร็วมาก
3. **Mock**: ใช้เมื่อทั้ง 2 ตัวข้างบน fail, data จำกัด แต่รับประกัน

---

## 📁 Folder Structure

```
pokedex-pro/
├── lib/
│   ├── core/                          # Core utilities
│   │   ├── constants/                 # Constants เช่น API URLs
│   │   ├── data/
│   │   │   └── local/                 # Hive setup
│   │   ├── error/                     # Custom exceptions
│   │   ├── presentation/              # Global widgets/themes
│   │   └── utils/                     # Type effectiveness, helpers
│   │
│   ├── features/                      # Feature-specific code
│   │   ├── pokemon_list/              # List Pokemon feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── pokemon_remote_data_source.dart
│   │   │   │   │   └── pokemon_local_data_source.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── pokemon_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── pokemon_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── pokemon.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── pokemon_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       └── get_pokemon_list.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── pokemon_list_bloc.dart
│   │   │       │   ├── pokemon_list_event.dart
│   │   │       │   └── pokemon_list_state.dart
│   │   │       ├── pages/
│   │   │       │   └── pokemon_list_page.dart
│   │   │       └── widgets/
│   │   │           ├── pokemon_card.dart
│   │   │           └── pokemon_list_item.dart
│   │   │
│   │   └── pokemon_detail/            # Detail Pokemon feature
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   ├── config/
│   │   ├── router/                    # Navigation routing
│   │   └── service_locator.dart       # Dependency injection setup
│   │
│   └── main.dart                      # Entry point
│
├── pubspec.yaml                       # Dependencies
├── exercises/                         # 8 exercises for students
│   ├── EXERCISES.md
│   ├── exercise_1_type_filter.dart
│   ├── exercise_5_compare_pokemon.dart
│   └── exercise_7_evolution_chain.dart
│
├── test/                              # Unit tests
│   ├── features/
│   └── mocks/
│
└── README.md                          # This file
```

---

## 🚀 How to Run

### Prerequisites
```bash
# Flutter version: >= 3.10
# Dart version: >= 3.0
flutter --version
dart --version
```

### Installation

```bash
# 1. Clone repository
cd pokedex-pro

# 2. Install dependencies
flutter pub get

# 3. Generate code (if using build_runner)
flutter pub run build_runner build

# 4. Run app
flutter run

# 5. Run tests
flutter test
```

### Run ด้วย Android Emulator

```bash
# Start emulator ก่อน
emulator -avd Pixel_5_API_33

# Run app
flutter run -d emulator-5554
```

### Run ด้วย iOS Simulator

```bash
# Start simulator
open -a Simulator

# Run app
flutter run -d iPhone
```

---

## 📦 Dependencies

```yaml
# Main dependencies (from pubspec.yaml)

# BLoC & State Management
  bloc: ^8.1.0
  flutter_bloc: ^8.1.0

# Clean Architecture & Dependency Injection
  get_it: ^7.5.0
  dartz: ^0.10.1

# Local Storage
  hive: ^2.2.0
  hive_flutter: ^1.1.0

# API & Networking
  dio: ^5.2.0

# Models & Serialization
  equatable: ^2.0.5
  json_serializable: ^6.7.0
  json_annotation: ^4.8.0

# UI & Themes
  flutter_svg: ^2.0.5
  google_fonts: ^5.1.0

# Navigation
  go_router: ^10.1.0

# Dev Dependencies
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  bloc_test: ^9.1.0
```

---

## 🎓 Exercises Reference

โครงการนี้มี **8 แบบฝึกหัด** ให้นักเรียนฝึกฝน:

| # | ชื่อ | ระดับ | โฟลเดอร์ |
|---|------|-------|---------|
| 1 | Type Filter | ⭐ Easy | `exercises/exercise_1_type_filter.dart` |
| 2 | Error UI | ⭐ Easy | (core/presentation/widgets/) |
| 3 | Ability Detail | ⭐⭐ Medium | (pokemon_detail/domain/) |
| 4 | Pagination | ⭐⭐ Medium | (pokemon_list/presentation/) |
| 5 | Compare Pokémon | ⭐⭐ Medium | `exercises/exercise_5_compare_pokemon.dart` |
| 6 | Cache Expiry (TTL) | ⭐⭐ Medium | (core/data/local/) |
| 7 | Evolution Chain | ⭐⭐⭐ Hard | `exercises/exercise_7_evolution_chain.dart` |
| 8 | Third Data Source | ⭐⭐⭐ Hard | (pokemon_detail/data/datasources/) |

### วิธีทำแบบฝึกหัด

```bash
# 1. อ่าน EXERCISES.md
cat exercises/EXERCISES.md

# 2. เลือกแบบฝึกหัด เช่น exercise 1
cat exercises/exercise_1_type_filter.dart

# 3. ทำตามขั้นตอน TODO ใน exercise file
# 4. แก้ไขไฟล์ที่ระบุใน "ไฟล์ที่ต้องแก้"
# 5. Test ด้วย `flutter run`
```

---

## 📚 Teaching Material Reference

### Related Learning Resources
- **pokedex-lab/** - Workshop materials สำหรับทำความเข้าใจ architecture
- **docs/ARCHITECTURE.md** - รายละเอียด Clean Architecture
- **docs/BLOC_PATTERN.md** - BLoC pattern tutorial
- **docs/FALLBACK_STRATEGY.md** - ลังกลศาสตร์ fallback chain

### PokeAPI Documentation
- Official: https://pokeapi.co/docs/v2
- ตัวอย่าง endpoint:
  - `/pokemon/1` - Bulbasaur
  - `/pokemon/pikachu` - Pikachu
  - `/type/electric` - Electric type info
  - `/evolution-chain/1` - Evolution chain

### Flutter & Clean Architecture
- Flutter official docs: https://flutter.dev
- BLoC library: https://bloclibrary.dev
- Clean Architecture: https://resocoder.com/clean-architecture

---

## 🔧 Configuration

### Hive Setup (Local Database)

ไฟล์: `lib/config/hive_setup.dart`

```dart
Future<void> initHive() async {
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  // Register adapters
  Hive.registerAdapter(PokemonAdapter());
  Hive.registerAdapter(PokemonDetailAdapter());

  // Open boxes
  await Hive.openBox<PokemonModel>('pokemon_cache');
  await Hive.openBox<PokemonDetailModel>('pokemon_detail_cache');
}
```

### Service Locator (Dependency Injection)

ไฟล์: `lib/config/service_locator.dart`

```dart
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Register data sources
  getIt.registerSingleton<PokemonRemoteDataSource>(
    PokemonRemoteDataSourceImpl(dio: getIt()),
  );

  // Register repositories
  getIt.registerSingleton<PokemonRepository>(
    PokemonRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Register use cases
  getIt.registerSingleton<GetPokemonList>(
    GetPokemonList(getIt()),
  );

  // Register BLoCs
  getIt.registerSingleton<PokemonListBloc>(
    PokemonListBloc(getPokemonList: getIt()),
  );
}
```

---

## 🐛 Troubleshooting

### Issue: PokeAPI ช้าหรือ timeout
**วิธีแก้:**
1. ตรวจสอบ network connection
2. ลองใช้ VPN (PokeAPI บางครั้งเชื่อมต่อได้ช้า)
3. Check Dio timeout settings ใน `pokemon_remote_data_source.dart`

```dart
final dio = Dio()
  ..options.connectTimeout = const Duration(seconds: 10)
  ..options.receiveTimeout = const Duration(seconds: 10);
```

### Issue: Hive database corrupted
**วิธีแก้:**
```bash
# ลบ cache files
rm -rf /path/to/app/data
# Rebuild app
flutter clean
flutter pub get
flutter run
```

### Issue: Build runner issue
**วิธีแก้:**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🤝 Contributing

บน project นี้ คือ learning resource ใส่สักหระหว่างสอน:

1. ทำตามแบบฝึกหัดใน exercises/
2. Create feature branch: `git checkout -b feature/exercise-1`
3. Commit changes: `git commit -m "Complete exercise 1: Type Filter"`
4. Push: `git push origin feature/exercise-1`

---

## 📄 License

MIT License - สามารถใช้งานได้อย่างอิสระ

---

## 👨‍🏫 For Instructors

### How to Use This Project in Class

**Week 1: Architecture Fundamentals**
- อธิบาย Clean Architecture layers
- ดู folder structure และ dependencies
- Run app แล้วเล่นกับ UI

**Week 2-3: Implement Exercises**
- ให้นักเรียน pick exercises ตามเลเวล
- Pair programming หรือ individual
- Code review ในชั้นเรียน

**Week 4: Advanced Topics**
- Discuss fallback strategy
- Performance optimization
- Testing (unit tests, widget tests)

### Setting Up Classroom Version

```bash
# Create blank version for students
git checkout -b classroom/starter
# Remove solutions from exercise files
# Commit as template
```

---

## 📞 Support

สำหรับคำถามหรือปัญหา:
- อ่าน exercises/EXERCISES.md
- ดู TODO comments ในไฟล์ exercise
- ถาม instructor หรือ classmate

---

**Happy Coding! ฟลัตเตอร์เทพ! 🚀**

*Last Updated: 2024*
*Flutter Version: 3.10+*
# lab13
