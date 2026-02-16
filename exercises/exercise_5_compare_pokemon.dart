// ===== Exercise 5: Compare Pokémon =====
// ระดับ: ⭐⭐ Medium
// เป้าหมาย: สร้างหน้าเปรียบเทียบ 2 ตัว — stats, type advantage
// ไฟล์ที่ต้องแก้: features/pokemon_compare/presentation/pages/compare_pokemon_page.dart,
//                features/pokemon_compare/presentation/bloc/compare_bloc.dart,
//                features/pokemon_compare/presentation/bloc/compare_event.dart,
//                features/pokemon_compare/presentation/bloc/compare_state.dart,
//                core/utils/type_effectiveness.dart

// ============================================================
// Step 1: สร้าง Utility Function สำหรับ Type Effectiveness
// ============================================================
// TODO: สร้างไฟล์ lib/core/utils/type_effectiveness.dart
//
// สร้าง function:
// double getTypeEffectiveness(String attackType, String defenseType)
//
// Return values:
// - 2.0 = super effective (effective)
// - 1.0 = neutral (ไม่มีประสิทธิพิเศษ)
// - 0.5 = not very effective (ไม่ประสิทธิ)
//
// Type chart example (ไม่ครบ ให้เพิ่มเอง):
// fire → grass = 2.0 (fire super effective to grass)
// fire → water = 0.5 (fire not effective to water)
// water → fire = 2.0
// grass → water = 0.5
// electric → water = 2.0
// psychic → fighting = 2.0
// dragon → dragon = 2.0
// dark → psychic = 2.0
// dark → ghost = 2.0
// fairy → dragon = 2.0
// fairy → dark = 2.0
// etc.
//
// Implementation approach:
// const typeChart = {
//   'fire': {
//     'grass': 2.0,
//     'ice': 2.0,
//     'bug': 2.0,
//     'steel': 2.0,
//     'water': 0.5,
//     'ground': 0.5,
//     'rock': 0.5,
//   },
//   'water': {
//     'fire': 2.0,
//     'ground': 2.0,
//     'rock': 2.0,
//     'grass': 0.5,
//     'water': 0.5,
//     'ice': 0.5,
//   },
//   // ... etc
// };
//
// double getTypeEffectiveness(String attackType, String defenseType) {
//   final chart = typeChart[attackType.toLowerCase()];
//   if (chart == null) return 1.0;
//   return chart[defenseType.toLowerCase()] ?? 1.0;
// }
//
// Hint: Type chart อาจดู https://bulbapedia.bulbagarden.net/wiki/Type

// ============================================================
// Step 2: สร้าง Compare BLoC Events และ States
// ============================================================
// TODO: สร้างไฟล์ lib/features/pokemon_compare/presentation/bloc/compare_event.dart
//
// abstract class CompareEvent extends Equatable {}
//
// class SelectPokemon1 extends CompareEvent {
//   final int pokemonId;
//   const SelectPokemon1(this.pokemonId);
//   @override
//   List<Object> get props => [pokemonId];
// }
//
// class SelectPokemon2 extends CompareEvent {
//   final int pokemonId;
//   const SelectPokemon2(this.pokemonId);
//   @override
//   List<Object> get props => [pokemonId];
// }
//
// class SwapPokemons extends CompareEvent {
//   const SwapPokemons();
//   @override
//   List<Object> get props => [];
// }
//
// class ClearComparison extends CompareEvent {
//   const ClearComparison();
//   @override
//   List<Object> get props => [];
// }

// TODO: สร้างไฟล์ lib/features/pokemon_compare/presentation/bloc/compare_state.dart
//
// abstract class CompareState extends Equatable {}
//
// class CompareInitial extends CompareState {
//   @override
//   List<Object> get props => [];
// }
//
// class CompareLoading extends CompareState {
//   final PokemonDetail? pokemon1;
//   final PokemonDetail? pokemon2;
//   const CompareLoading({this.pokemon1, this.pokemon2});
//   @override
//   List<Object?> get props => [pokemon1, pokemon2];
// }
//
// class CompareLoaded extends CompareState {
//   final PokemonDetail pokemon1;
//   final PokemonDetail pokemon2;
//   const CompareLoaded({
//     required this.pokemon1,
//     required this.pokemon2,
//   });
//   @override
//   List<Object> get props => [pokemon1, pokemon2];
// }
//
// class CompareError extends CompareState {
//   final String message;
//   const CompareError(this.message);
//   @override
//   List<Object> get props => [message];
// }

// ============================================================
// Step 3: สร้าง Compare BLoC
// ============================================================
// TODO: สร้างไฟล์ lib/features/pokemon_compare/presentation/bloc/compare_bloc.dart
//
// class CompareBloc extends Bloc<CompareEvent, CompareState> {
//   final GetPokemonDetail getPokemonDetail;
//
//   CompareBloc({required this.getPokemonDetail})
//     : super(CompareInitial()) {
//     on<SelectPokemon1>(_onSelectPokemon1);
//     on<SelectPokemon2>(_onSelectPokemon2);
//     on<SwapPokemons>(_onSwapPokemons);
//     on<ClearComparison>(_onClearComparison);
//   }
//
//   Future<void> _onSelectPokemon1(SelectPokemon1 event, Emitter emit) async {
//     // TODO: implement
//     // 1. ถ้า state is CompareLoaded → เก็บ pokemon2
//     //    ถ้า state is CompareLoading → เก็บ pokemon2
//     // 2. emit CompareLoading(pokemon1: null, pokemon2: pokemon2)
//     // 3. fetch pokemon1
//     // 4. ถ้า pokemon2 ยังไม่ได้เลือก emit CompareLoading(pokemon1: pokemon1)
//     // 5. ถ้า pokemon2 เลือกแล้ว emit CompareLoaded(pokemon1, pokemon2)
//   }
//
//   Future<void> _onSelectPokemon2(SelectPokemon2 event, Emitter emit) async {
//     // TODO: implement (similar to _onSelectPokemon1)
//   }
//
//   Future<void> _onSwapPokemons(SwapPokemons event, Emitter emit) async {
//     // TODO: implement
//     // swap pokemon1 และ pokemon2 ใน state
//   }
//
//   Future<void> _onClearComparison(ClearComparison event, Emitter emit) {
//     // TODO: implement
//     emit(CompareInitial());
//   }
// }

// ============================================================
// Step 4: สร้าง Compare Page
// ============================================================
// TODO: สร้างไฟล์ lib/features/pokemon_compare/presentation/pages/compare_pokemon_page.dart
//
// class ComparePokemonPage extends StatelessWidget {
//   const ComparePokemonPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Compare Pokémon')),
//       body: BlocBuilder<CompareBloc, CompareState>(
//         builder: (context, state) {
//           // TODO: implement UI for different states
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 // TODO: Step 4.1 - Pokemon Selection Section
//                 // Slot 1: เลือก Pokemon ตัวที่ 1
//                 // Slot 2: เลือก Pokemon ตัวที่ 2
//                 // Button "Swap" สลับสองตัว
//                 // Button "Clear" ล้างการเลือก
//
//                 // TODO: Step 4.2 - Comparison Section (show only when both selected)
//                 // Show stats comparison
//                 // Show type advantage
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// ============================================================
// Step 5: สร้าง Pokemon Selection Widget
// ============================================================
// TODO: ใน compare_pokemon_page.dart สร้าง widget:
//
// class _PokemonSelectionSlot extends StatelessWidget {
//   final String title; // 'Pokémon 1' หรือ 'Pokémon 2'
//   final PokemonDetail? selectedPokemon;
//   final VoidCallback onSelectTap;
//
//   const _PokemonSelectionSlot({
//     required this.title,
//     this.selectedPokemon,
//     required this.onSelectTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Column(
//         children: [
//           Text(title, style: Theme.of(context).textTheme.titleMedium),
//           if (selectedPokemon == null)
//             GestureDetector(
//               onTap: onSelectTap,
//               child: Container(
//                 height: 150,
//                 color: Colors.grey[300],
//                 child: const Icon(Icons.add),
//               ),
//             )
//           else
//             Column(
//               children: [
//                 Image.network(
//                   selectedPokemon!.imageUrl,
//                   width: 150,
//                   height: 150,
//                 ),
//                 Text(selectedPokemon!.name),
//                 GestureDetector(
//                   onTap: onSelectTap,
//                   child: const Text('Change'),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }

// ============================================================
// Step 6: สร้าง Stats Comparison Widget
// ============================================================
// TODO: ใน compare_pokemon_page.dart สร้าง widget:
//
// class _StatsComparisonWidget extends StatelessWidget {
//   final PokemonDetail pokemon1;
//   final PokemonDetail pokemon2;
//
//   const _StatsComparisonWidget({
//     required this.pokemon1,
//     required this.pokemon2,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final stats = ['HP', 'Attack', 'Defense', 'Sp. Atk', 'Sp. Def', 'Speed'];
//
//     return Column(
//       children: [
//         const Text('Stats Comparison'),
//         // TODO: สำหรับแต่ละ stat สร้าง mirror bar chart
//         // Layout:
//         // [Pokemon 1 bar] [Stat Name] [Pokemon 2 bar]
//         //
//         // Example:
//         // [====] HP [============]
//         // [======] Att [=====]
//         //
//         // ใช้ Row + Expanded
//         ...stats.map((statName) {
//           final stat1Value = _getStatValue(pokemon1, statName);
//           final stat2Value = _getStatValue(pokemon2, statName);
//           final maxValue = max(stat1Value, stat2Value).toDouble();
//
//           return Row(
//             children: [
//               // TODO: Pokemon 1 bar (left side)
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: Container(
//                     width: (stat1Value / maxValue) * 100,
//                     height: 20,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ),
//               // TODO: Stat name (middle)
//               SizedBox(
//                 width: 60,
//                 child: Center(child: Text(statName)),
//               ),
//               // TODO: Pokemon 2 bar (right side)
//               Expanded(
//                 child: Container(
//                   width: (stat2Value / maxValue) * 100,
//                   height: 20,
//                   color: Colors.red,
//                 ),
//               ),
//             ],
//           );
//         }),
//       ],
//     );
//   }
//
//   int _getStatValue(PokemonDetail pokemon, String statName) {
//     // TODO: extract stat value from pokemon.stats
//     // stats คือ List<PokemonStat>
//     // ค้นหา stat ที่มี name ตรง และ return baseStat
//     return pokemon.stats
//         .firstWhere((s) => s.name == statName, orElse: () => PokemonStat(name: '', baseStat: 0))
//         .baseStat;
//   }
// }

// ============================================================
// Step 7: สร้าง Type Advantage Widget
// ============================================================
// TODO: ใน compare_pokemon_page.dart สร้าง widget:
//
// class _TypeAdvantageWidget extends StatelessWidget {
//   final PokemonDetail pokemon1;
//   final PokemonDetail pokemon2;
//
//   const _TypeAdvantageWidget({
//     required this.pokemon1,
//     required this.pokemon2,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const Text('Type Advantage'),
//         // TODO: คำนวณ damage output ของแต่ละตัว
//         // 1. pokemon1 attack types vs pokemon2 defense types
//         // 2. pokemon2 attack types vs pokemon1 defense types
//         //
//         // Algorithm:
//         // for each attack type ใน pokemon1:
//         //   for each defense type ใน pokemon2:
//         //     effectiveness *= getTypeEffectiveness(attackType, defenseType)
//         //
//         // เช่น Charizard (Fire/Flying) vs Dragonite (Dragon/Flying):
//         // Charizard attacks:
//         //   - Fire → Dragon defense: 0.5 × Fire → Flying: 2.0 = 1.0
//         //   - Flying → Dragon: 0.5, Flying → Flying: 2.0 = 1.0
//         // Dragonite attacks:
//         //   - Dragon → Fire: 1.0, Dragon → Flying: 1.0 = 1.0
//         //   - Flying → Fire: 1.0, Flying → Flying: 2.0 = 1.0
//         //
//         // แสดงผล:
//         // "Charizard vs Dragonite: Neutral matchup"
//         // หรือ "Pikachu has type advantage vs Charizard!"
//
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Column(
//               children: [
//                 Text('${pokemon1.name} vs ${pokemon2.name}'),
//                 Text(_getAdvantageText(pokemon1, pokemon2)),
//               ],
//             ),
//             Column(
//               children: [
//                 Text('${pokemon2.name} vs ${pokemon1.name}'),
//                 Text(_getAdvantageText(pokemon2, pokemon1)),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   String _getAdvantageText(PokemonDetail attacker, PokemonDetail defender) {
//     // TODO: implement
//     // คำนวณ average effectiveness
//     // ถ้า > 1.2 = "has type advantage"
//     // ถ้า < 0.8 = "is weak to"
//     // ถ้า 0.8-1.2 = "neutral matchup"
//     return 'Calculating...';
//   }
// }

// ============================================================
// Step 8: เชื่อมต่อกับ Navigation
// ============================================================
// TODO: เพิ่ม route ใน main.dart หรือ router:
// GoRoute(
//   path: '/compare',
//   builder: (context, state) => BlocProvider(
//     create: (context) => CompareBlocImpl(...),
//     child: const ComparePokemonPage(),
//   ),
// ),

// ============================================================
// Testing Checklist
// ============================================================
// - [ ] ComparePokemonPage render ได้
// - [ ] เลือก Pokemon 1 ได้
// - [ ] เลือก Pokemon 2 ได้
// - [ ] Stats comparison แสดง bar chart mirror ถูกต้อง
// - [ ] Type advantage คำนวณถูกต้อง
// - [ ] Swap button สลับ pokemon 1 และ 2
// - [ ] Clear button ล้างการเลือกทั้งหมด
// - [ ] UI responsive (ต่างขนาด screen)
// - [ ] Images load ได้

// ============================================================
// Extra Challenges
// ============================================================
// 1. เพิ่ม Detailed Type Chart
//    - แสดง effectiveness ของแต่ละ type ที่ detailed
//    - เช่น "Pikachu (Electric) x2 vs Charizard (Fire/Flying)"
//
// 2. History ของ comparisons ที่เคย ทำ
//    - บันทึก ใน SharedPreferences
//    - ให้ click ไป compare ซ้ำได้เร็ว
//
// 3. Share comparison result
//    - Generate image หรือ text
//    - Share ผ่าน social media หรือ messaging
//
// 4. Competitive build calculator
//    - แสดง optimal build (items, moves) สำหรับ matchup นี้
//    - (requires Pokemon moves and items data)
