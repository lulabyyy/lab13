// ===== Exercise 7: Evolution Chain =====
// ระดับ: ⭐⭐⭐ Hard
// เป้าหมาย: ดึง evolution chain จาก PokeAPI แสดงเป็น horizontal scroll
// ไฟล์ที่ต้องแก้: pokemon_detail/domain/entities/evolution_chain.dart,
//                pokemon_detail/domain/usecases/get_evolution_chain.dart,
//                pokemon_detail/data/datasources/pokemon_remote_data_source.dart,
//                pokemon_detail/presentation/pages/pokemon_detail_page.dart,
//                pokemon_detail/presentation/widgets/evolution_chain_widget.dart

// ============================================================
// Step 1: สร้าง Entity Classes
// ============================================================
// TODO: สร้างไฟล์ lib/features/pokemon_detail/domain/entities/evolution_chain.dart
//
// สร้าง 2 classes:
//
// 1. EvolutionNode - แทน Pokemon แต่ละตัวในชุด evolution
//    class EvolutionNode {
//      final int pokemonId;
//      final String name;
//      final String imageUrl;
//      final int? minLevel;           // null ถ้าไม่ใช่ level-up
//      final String? evolutionTrigger; // 'level-up', 'trade', 'use-item', 'friendship'
//      final List<EvolutionNode> evolvesTo; // Pokemon ที่วิวัฒนาต่อจากตัวนี้
//    }
//
// 2. EvolutionChain - root node
//    class EvolutionChain {
//      final EvolutionNode chain;
//    }
//
// Hint: ทำให้ Equatable และ copyWith() ได้ถ้าต้องการ

// ============================================================
// Step 2: สร้าง UseCase
// ============================================================
// TODO: สร้างไฟล์ lib/features/pokemon_detail/domain/usecases/get_evolution_chain.dart
//
// class GetEvolutionChain extends UseCase<EvolutionChain, int> {
//   final PokemonDetailRepository repository;
//
//   GetEvolutionChain(this.repository);
//
//   @override
//   Future<EvolutionChain> call(int pokemonId) async {
//     // TODO: เรียก repository.getEvolutionChain(pokemonId)
//     return await repository.getEvolutionChain(pokemonId);
//   }
// }
//
// Hint: ใช้ fallback chain เหมือน get_pokemon_detail.dart

// ============================================================
// Step 3: อัปเดต Repository
// ============================================================
// TODO: ใน pokemon_detail_repository.dart เพิ่ม method:
//
// Future<EvolutionChain> getEvolutionChain(int pokemonId);
//
// TODO: ใน pokemon_detail_repository_impl.dart implement method:
// - ใช้ fallback chain: remote → cache → mock
// - เรียก _getEvolutionChainFromRemote(pokemonId)

// ============================================================
// Step 4: อัปเดต Remote Data Source
// ============================================================
// TODO: ใน pokemon_remote_data_source.dart เพิ่ม method:
//
// Future<EvolutionChainModel> getEvolutionChain(int pokemonId) async {
//   // TODO: implement
//   // Step 4.1: เรียก /pokemon-species/{pokemonId}
//   //           เพื่อได้ evolution_chain.url
//   final speciesUrl = 'https://pokeapi.co/api/v2/pokemon-species/$pokemonId/';
//   final speciesResponse = await dio.get(speciesUrl);
//   final evolutionChainUrl = speciesResponse.data['evolution_chain']['url'];
//
//   // Step 4.2: เรียก evolution_chain.url
//   //           เพื่อได้ recursion chain data
//   final chainResponse = await dio.get(evolutionChainUrl);
//   final chainData = chainResponse.data;
//
//   // Step 4.3: parse recursion JSON structure
//   final chain = _parseChainData(chainData['chain']);
//
//   return EvolutionChainModel(chain: chain);
// }

// ============================================================
// Step 5: Parse Recursive JSON Structure
// ============================================================
// TODO: เพิ่ม private method _parseChainData ใน remote data source:
//
// EvolutionNodeModel _parseChainData(Map<String, dynamic> chainData) {
//   // TODO: implement recursive parsing
//   // StructureของJSON:
//   // {
//   //   "species": {
//   //     "name": "charmander",
//   //     "url": "https://pokeapi.co/api/v2/pokemon-species/4/"
//   //   },
//   //   "evolution_details": [
//   //     {
//   //       "min_level": 16,
//   //       "trigger": {
//   //         "name": "level-up"
//   //       }
//   //     }
//   //   ],
//   //   "evolves_to": [
//   //     { ... charmeleon evolution data ... }
//   //   ]
//   // }
//
//   final species = chainData['species'] as Map<String, dynamic>;
//   final name = species['name'] as String;
//   final speciesUrl = species['url'] as String;
//
//   // TODO: extract pokemonId จาก URL
//   // URL format: https://pokeapi.co/api/v2/pokemon-species/{id}/
//   final pokemonId = int.parse(speciesUrl.split('/').where((p) => p.isNotEmpty).last);
//
//   // TODO: extract evolution details (minLevel, trigger)
//   final evolutionDetails = chainData['evolution_details'] as List;
//   int? minLevel;
//   String? trigger;
//
//   if (evolutionDetails.isNotEmpty) {
//     final details = evolutionDetails.first as Map<String, dynamic>;
//     minLevel = details['min_level'] as int?;
//     trigger = details['trigger']['name'] as String?;
//   }
//
//   // TODO: recursive parse evolvesTo
//   final evolvesToList = chainData['evolves_to'] as List;
//   final evolvesTo = evolvesToList
//     .map((e) => _parseChainData(e as Map<String, dynamic>))
//     .toList();
//
//   // TODO: สร้าง imageUrl (PokeAPI official artwork)
//   final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master'
//       '/pokemon/other/official-artwork/$pokemonId.png';
//
//   return EvolutionNodeModel(
//     pokemonId: pokemonId,
//     name: name,
//     imageUrl: imageUrl,
//     minLevel: minLevel,
//     evolutionTrigger: trigger,
//     evolvesTo: evolvesTo,
//   );
// }
//
// Hint: ตรวจสอบ null checks สำหรับ optional fields
// Hint: URL parser อาจต้อง handle edge cases

// ============================================================
// Step 6: สร้าง Widget
// ============================================================
// TODO: สร้างไฟล์ lib/features/pokemon_detail/presentation/widgets/evolution_chain_widget.dart
//
// class EvolutionChainWidget extends StatelessWidget {
//   final EvolutionChain evolutionChain;
//
//   const EvolutionChainWidget({required this.evolutionChain});
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement
//     // 1. ถ้า evolution chain มี nodes เดียว → แสดง "No evolution"
//     //    if (_countNodes(evolutionChain.chain) == 1) {
//     //      return Center(child: Text('No evolution'));
//     //    }
//     //
//     // 2. สร้าง flattened list ของทุก Pokemon ในชุด
//     //    ตัวอย่าง: [Charmander, Charmeleon, Charizard]
//     //    final evolutionSequence = _flattenChain(evolutionChain.chain);
//     //
//     // 3. สร้าง horizontal ListView
//     //    ListView.builder(
//     //      scrollDirection: Axis.horizontal,
//     //      itemCount: evolutionSequence.length,
//     //      itemBuilder: (context, index) {
//     //        // TODO: สร้าง evolution node widget
//     //      },
//     //    )
//   }
//
//   // TODO: helper method flatten recursive structure
//   // List<EvolutionNode> _flattenChain(EvolutionNode node) {
//   //   final result = [node];
//   //   for (final child in node.evolvesTo) {
//   //     result.addAll(_flattenChain(child));
//   //   }
//   //   return result;
//   // }
//
//   // TODO: helper method count total nodes
//   // int _countNodes(EvolutionNode node) {
//   //   int count = 1;
//   //   for (final child in node.evolvesTo) {
//   //     count += _countNodes(child);
//   //   }
//   //   return count;
//   // }
// }
//
// Hint: ใช้ Padding, Column, Image, Text สำหรับแต่ละ node
// Hint: เพิ่ม Arrow → ระหว่าง nodes เพื่อแสดง evolution flow

// ============================================================
// Step 7: สร้าง Evolution Node Widget
// ============================================================
// TODO: ใน evolution_chain_widget.dart สร้าง helper widget:
//
// class _EvolutionNodeWidget extends StatelessWidget {
//   final EvolutionNode node;
//   final EvolutionNode? nextNode;
//
//   const _EvolutionNodeWidget({
//     required this.node,
//     this.nextNode,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // TODO: Pokemon image
//         Image.network(
//           node.imageUrl,
//           width: 80,
//           height: 80,
//           // Add error handling
//           errorBuilder: (context, error, stackTrace) {
//             return const Icon(Icons.image_not_supported);
//           },
//         ),
//         // TODO: Pokemon name
//         Text(node.name, style: Theme.of(context).textTheme.bodyMedium),
//
//         // TODO: Evolution trigger info (if exists and has next evolution)
//         if (nextNode != null && node.evolvesTo.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Text(
//               node.minLevel != null
//                 ? 'Lv. ${node.minLevel}'
//                 : node.evolutionTrigger ?? 'Unknown',
//               style: Theme.of(context).textTheme.labelSmall,
//             ),
//           ),
//       ],
//     );
//   }
// }
//
// Hint: Error handling สำหรับ image loading
// Hint: แสดง minLevel หรือ trigger ได้สวยงาม

// ============================================================
// Step 8: อัปเดต Pokemon Detail Page
// ============================================================
// TODO: ใน pokemon_detail_page.dart เพิ่ม:
//
// 1. เรียก GetEvolutionChain UseCase ใน initState หรือ BLoC event
// 2. แสดง EvolutionChainWidget ใน UI
//    BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
//      builder: (context, state) {
//        if (state is PokemonDetailLoaded) {
//          if (state.evolutionChain != null) {
//            return EvolutionChainWidget(
//              evolutionChain: state.evolutionChain!,
//            );
//          }
//        }
//        return const SizedBox.shrink();
//      },
//    )

// ============================================================
// Testing Checklist
// ============================================================
// - [ ] GetEvolutionChain UseCase ทำงาน
// - [ ] Remote data source เรียก PokeAPI /pokemon-species สำเร็จ
// - [ ] Recursive parser parse evolution chain ถูกต้อง
// - [ ] EvolutionChainWidget แสดง nodes ทั้งหมด
// - [ ] Horizontal scroll ทำงานได้
// - [ ] Images load ได้ และมี error handling
// - [ ] Evolution trigger (Lv. XX) แสดง
// - [ ] Pokemon ที่ไม่มี evolution แสดง "No evolution"
// - [ ] Fallback chain ทำงาน (remote → cache → mock)

// ============================================================
// API Response Examples
// ============================================================
// 1. Pokemon Species (Pikachu #25):
// GET https://pokeapi.co/api/v2/pokemon-species/25/
// Response:
// {
//   "evolution_chain": {
//     "url": "https://pokeapi.co/api/v2/evolution-chain/6/"
//   }
// }
//
// 2. Evolution Chain:
// GET https://pokeapi.co/api/v2/evolution-chain/6/
// Response:
// {
//   "chain": {
//     "species": { "name": "pichu", "url": "..." },
//     "evolution_details": [],
//     "evolves_to": [
//       {
//         "species": { "name": "pikachu", "url": "..." },
//         "evolution_details": [
//           {
//             "min_level": 7,
//             "trigger": { "name": "level-up" }
//           }
//         ],
//         "evolves_to": [
//           {
//             "species": { "name": "raichu", "url": "..." },
//             "evolution_details": [
//               {
//                 "trigger": { "name": "use-item" },
//                 "item": { "name": "thunder-stone" }
//               }
//             ],
//             "evolves_to": []
//           }
//         ]
//       }
//     ]
//   }
// }

// ============================================================
// Extra Challenges
// ============================================================
// 1. แสดง evolution trigger details ที่ละเอียด
//    - "Lv. 16" สำหรับ level-up
//    - "Thunder Stone" สำหรับ use-item
//    - "Trade" สำหรับ trade trigger
//
// 2. เพิ่ม branching evolution UI
//    - บาง Pokemon มี evolvesTo > 1 (branching)
//    - Eevee: Vaporeon, Jolteon, Flareon, etc.
//    - แสดง branch ทั้งหมด
//
// 3. Interactive evolution selector
//    - เมื่อผู้ใช้คลิก evolution node ให้ navigate ไปยัง Pokemon detail หน้านั้น
//    - เช่น คลิก Charmeleon → ดู Charmeleon detail
//
// 4. Animation
//    - เมื่อ load evolution chain ให้ animate nodes
//    - ใช้ ScaleTransition หรือ FadeTransition
