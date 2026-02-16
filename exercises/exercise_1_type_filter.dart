// ===== Exercise 1: Type Filter =====
// ระดับ: ⭐ Easy
// เป้าหมาย: เพิ่ม filter by type ในหน้า Pokemon list
// ไฟล์ที่ต้องแก้: pokemon_list_event.dart, pokemon_list_state.dart,
//                pokemon_list_bloc.dart, pokemon_list_page.dart

// ============================================================
// Step 1: เพิ่ม Event ใน pokemon_list_event.dart
// ============================================================
// TODO: สร้าง FilterByType event class
// - ควรมี field `type` ประเภท String? (null = แสดงทั้งหมด)
// - extends PokemonListEvent
// - implement props getter สำหรับ Equatable
//
// ตัวอย่าง:
// class FilterByType extends PokemonListEvent {
//   final String? type;
//   const FilterByType(this.type);
//   @override
//   List<Object?> get props => [type];
// }

// ============================================================
// Step 2: เพิ่ม field ใน PokemonListLoaded state
// ============================================================
// TODO: แก้ไข PokemonListLoaded state ใน pokemon_list_state.dart
// - เพิ่ม field: `final String? selectedType;`
// - เพิ่มใน constructor
// - เพิ่มใน copyWith() method
// - เพิ่มใน props getter
//
// ตัวอย่าง copyWith:
// PokemonListLoaded copyWith({
//   List<PokemonListItem>? pokemons,
//   String? selectedType,
// }) {
//   return PokemonListLoaded(
//     pokemons: pokemons ?? this.pokemons,
//     selectedType: selectedType ?? this.selectedType,
//   );
// }

// ============================================================
// Step 3: เพิ่ม handler ใน BLoC
// ============================================================
// TODO: ใน pokemon_list_bloc.dart เพิ่ม handler สำหรับ FilterByType
//
// ขั้นตอน:
// 1. ใน constructor (หรือ _initEventHandlers) เพิ่ม:
//    on<FilterByType>(_onFilterByType);
//
// 2. สร้าง method _onFilterByType:
//
// Future<void> _onFilterByType(FilterByType event, Emitter emit) async {
//   final currentState = state;
//   if (currentState is! PokemonListLoaded) return;
//
//   // TODO: implement filter logic
//   // 1. ถ้า event.type == null → แสดงทั้งหมด (original list)
//   // 2. ถ้า event.type มีค่า → filter list ให้เหลือเฉพาะ Pokemon ที่มี type นี้
//   //
//   // Hint: สามารถใช้ list.where() เพื่อกรอง:
//   // final filtered = currentState.pokemons
//   //   .where((p) => p.types.contains(event.type))
//   //   .toList();
//   //
//   // 3. emit state ใหม่พร้อมกับ selectedType ที่อัปเดต
//
//   if (event.type == null) {
//     // แสดงทั้งหมด - TODO: implement
//     // emit(currentState.copyWith(selectedType: null));
//   } else {
//     // filter by type - TODO: implement
//     // emit(currentState.copyWith(selectedType: event.type));
//   }
// }

// ============================================================
// Step 4: เพิ่ม Type Filter UI ใน pokemon_list_page.dart
// ============================================================
// TODO: แก้ไข pokemon_list_page.dart เพื่อเพิ่ม filter UI
//
// ขั้นตอน:
// 1. เพิ่ม list ของ Pokemon types (อย่างน้อย 8 types):
//    final types = ['fire', 'water', 'grass', 'electric',
//                   'psychic', 'dragon', 'dark', 'fairy'];
//
// 2. ในส่วน BlocBuilder หรือ Column ของ pokemon_list_page ให้เพิ่ม
//    Wrap widget สำหรับแสดง filter chips:
//
//    Wrap(
//      spacing: 8,
//      runSpacing: 8,
//      children: [
//        // TODO: สร้าง FilterChip สำหรับ "All"
//        FilterChip(
//          label: const Text('All'),
//          // TODO: selected condition ควรเป็น selectedType == null
//          selected: false,
//          onSelected: (_) {
//            // TODO: emit FilterByType(null) event
//          },
//        ),
//        // TODO: สร้าง FilterChip สำหรับแต่ละ type
//        // Hint: ใช้ types.map() เพื่อสร้าง list ของ FilterChip
//        ...types.map((type) => FilterChip(
//          label: Text(type.toUpperCase()),
//          // TODO: selected condition ควรเป็น selectedType == type
//          selected: false,
//          onSelected: (_) {
//            // TODO: emit FilterByType(type) event
//          },
//        )),
//      ],
//    )
//
// 3. สร้าง List<FilterChip> หรือ widgets โดยใช้:
//    - FilterChip แสดง type
//    - onSelected callback เพื่อ emit event
//    - selected property ควรสอดคล้องกับ state.selectedType
//
// 4. วาง Wrap ไว้ด้านบนของ Pokemon list

// ============================================================
// Testing Checklist
// ============================================================
// - [ ] FilterByType event ถูกสร้างและ emit ได้
// - [ ] PokemonListLoaded state มี selectedType field
// - [ ] BLoC handler รับ event และ emit state ใหม่
// - [ ] UI แสดง filter chips สำหรับทุก type
// - [ ] คลิก filter chip เลือก type → list ถูก filter
// - [ ] คลิก "All" → แสดง Pokemon ทั้งหมด
// - [ ] selected chip ถูก highlight
// - [ ] Filter UI ไม่เลื่อนออกนอกหน้าจอ (ใช้ Wrap)

// ============================================================
// Extra Challenges (ถ้าจบแล้วอยาก challenge เพิ่ม)
// ============================================================
// 1. เพิ่ม multi-select: เลือก type ได้มากกว่า 1 ตัว
//    - เปลี่ยน selectedType เป็น Set<String>
//    - ใช้ AND logic: Pokemon ต้องมี ALL selected types
//
// 2. เพิ่ม animation: เมื่อ filter เปลี่ยน ให้ animate list
//    - ใช้ AnimatedList หรือ AnimatedListView
//
// 3. Save filter preference ใน SharedPreferences
//    - เมื่อกลับมาที่หน้า list ให้ remember filter ที่เลือกไว้
//
// 4. เพิ่ม sort: ให้เรียง Pokemon ตามชื่อ หรือ ID
//    - สร้าง SortBy event เหมือน FilterByType

// ============================================================
// Useful PokeAPI Info
// ============================================================
// Pokemon types จากการ hardcode (ทำให้ง่าย):
// const pokemonTypes = [
//   'fire', 'water', 'grass', 'electric', 'ice',
//   'fighting', 'poison', 'ground', 'flying', 'psychic',
//   'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy'
// ];
//
// PokeAPI endpoint: https://pokeapi.co/api/v2/pokemon/
// Response มี field "types" ที่เป็น List<PokemonType>
// PokemonType มี field "type" ที่มี "name"
//
// ตัวอย่าง Pikachu types: [
//   { "type": { "name": "electric" } }
// ]
