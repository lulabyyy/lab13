# PokéDex Pro - Flutter Exercises

โครงการนี้มี 8 แบบฝึกหัด เพื่อให้นักเรียนได้ฝึกฝน Flutter Architecture (Clean Architecture + BLoC) และ API integration

---

## Exercise 1: Type Filter ⭐ Easy

**เป้าหมาย:** เพิ่มความสามารถกรอง Pokémon ตามประเภท (Type) ในหน้า Pokemon list

**คำอธิบาย (Thai):**
ในหน้า Pokemon list ปัจจุบัน ยังไม่มีการกรองตามประเภท ให้เพิ่ม filter UI แสดง filter chips สำหรับแต่ละประเภท (Fire, Water, Grass, etc.) เมื่อผู้ใช้คลิก filter chip จะต้องกรอง Pokemon list เฉพาะ Pokemon ที่มีประเภทนั้น พร้อมจัดเก็บ state ของ filter ที่เลือกอยู่

**ไฟล์ที่ต้องแก้:**
- `lib/features/pokemon_list/presentation/bloc/pokemon_list_event.dart`
- `lib/features/pokemon_list/presentation/bloc/pokemon_list_state.dart`
- `lib/features/pokemon_list/presentation/bloc/pokemon_list_bloc.dart`
- `lib/features/pokemon_list/presentation/pages/pokemon_list_page.dart`

**Hints:**
1. สร้าง event `FilterByType` ที่รับค่า type string (หรือ null เพื่อแสดงทั้งหมด)
2. เพิ่ม `selectedType` field ใน `PokemonListLoaded` state
3. ใน BLoC handler ให้กรอง Pokemon list ตาม type ที่เลือก
4. ใน UI ให้สร้าง `FilterChip` widgets สำหรับแต่ละ type และเพิ่ม event เมื่อคลิก

---

## Exercise 2: Error UI ⭐ Easy

**เป้าหมาย:** สร้าง custom error page ที่แสดงข้อมูลข้อผิดพลาด และปุ่ม retry

**คำอธิบาย (Thai):**
เมื่อการเรียก API ล้มเหลว ระบบควรแสดง error page ที่มีรายละเอียดว่าเกิดข้อผิดพลาดจากที่ใด (เช่น Network error, Server error, Cache error) และเสนอให้ผู้ใช้กดปุ่ม "Retry" เพื่อพยายามดึงข้อมูลใหม่

**ไฟล์ที่ต้องแก้:**
- `lib/features/pokemon_list/presentation/pages/pokemon_list_page.dart`
- `lib/core/presentation/widgets/error_widget.dart` (สร้างใหม่)

**Hints:**
1. ใน `pokemon_list_page.dart` เพิ่ม condition เพื่อตรวจสอบ `state is PokemonListError`
2. สร้าง widget `CustomErrorWidget` แสดงข้อมูลข้อผิดพลาดและปุ่ม retry
3. เพิ่ม error message property ใน `PokemonListError` state เพื่อแสดงข้อมูลแหล่งที่มาของข้อผิดพลาด
4. เมื่อกดปุ่ม retry ให้เรียก event เพื่อ retry การดึงข้อมูล

---

## Exercise 3: Ability Detail ⭐⭐ Medium

**เป้าหมาย:** สร้าง `GetAbilityDetail` UseCase เพื่อดึงข้อมูล ability เพิ่มเติมจาก PokeAPI

**คำอธิบาย (Thai):**
Pokémon แต่ละตัวมี abilities หลายตัว ปัจจุบันแสดงเฉพาะชื่อ ability เท่านั้น ให้สร้าง UseCase ใหม่ที่ดึงข้อมูลรายละเอียดของ ability จาก PokeAPI endpoint `/ability/{id}` เพื่อแสดงข้อมูลเพิ่มเติมเช่น description

**ไฟล์ที่ต้องแก้:**
- `lib/features/pokemon_detail/domain/usecases/get_ability_detail.dart` (สร้างใหม่)
- `lib/features/pokemon_detail/domain/repositories/pokemon_detail_repository.dart`
- `lib/features/pokemon_detail/data/repositories/pokemon_detail_repository_impl.dart`
- `lib/features/pokemon_detail/data/datasources/pokemon_remote_data_source.dart`

**Hints:**
1. สร้าง entity `AbilityDetail` มี properties: name, description, generation
2. ใน remote data source ให้เพิ่ม method `getAbilityDetail(String abilityName)`
3. UseCase ควรรับ `String abilityName` และ return `Future<AbilityDetail>`
4. ใช้ fallback data source chain (Remote → Hive Cache) เพื่อ cache ability details

---

## Exercise 4: Pagination ⭐⭐ Medium

**เป้าหมาย:** เพิ่ม infinite scroll / load more functionality เพื่อให้ load Pokemon ทีละ batch

**คำอธิบาย (Thai):**
ปัจจุบันแอปพิเคชันโหลด Pokemon ทั้งหมด ซึ่งอาจทำให้ช้า ให้เพิ่ม pagination pattern เพื่อให้ load Pokemon ทีละ 20 ตัว (หรือมากขึ้น) เมื่อผู้ใช้ scroll ลงถึงด้านล่าง ให้ load batch ถัดไปอัตโนมัติ

**ไฟล์ที่ต้องแก้:**
- `lib/features/pokemon_list/domain/usecases/get_pokemon_list.dart`
- `lib/features/pokemon_list/presentation/bloc/pokemon_list_event.dart`
- `lib/features/pokemon_list/presentation/bloc/pokemon_list_state.dart`
- `lib/features/pokemon_list/presentation/bloc/pokemon_list_bloc.dart`
- `lib/features/pokemon_list/presentation/pages/pokemon_list_page.dart`

**Hints:**
1. เพิ่ม event `LoadMorePokemon` ใน BLoC
2. ใน state ให้เพิ่ม fields: `currentPage`, `pageSize`, `hasMore`
3. UseCase `GetPokemonList` ควรรับ parameters: `page`, `pageSize`
4. ใน UI ให้ใช้ `NotificationListener<ScrollNotification>` เพื่อตรวจสอบเมื่อ scroll ลงถึงด้านล่าง
5. เมื่อตรวจสอบได้ ให้ emit event `LoadMorePokemon` เพื่อโหลด batch ถัดไป

---

## Exercise 5: Compare Pokémon ⭐⭐ Medium

**เป้าหมาย:** สร้างหน้า compare Pokemon เพื่อเปรียบเทียบสถิติ (stats) และ type advantage ของ 2 ตัว

**คำอธิบาย (Thai):**
สร้างหน้าใหม่ที่ให้ผู้ใช้เลือก Pokemon 2 ตัว จากนั้นแสดงการเปรียบเทียบแบบ side-by-side พร้อมแสดง stats (HP, Attack, Defense, etc.) ในรูปแบบ bar chart mirror และแสดง type advantage (เช่น Fire vs Water) ระบบควรบอกว่า Pokemon ตัวไหนมีความเสียหายมากกว่า

**ไฟล์ที่ต้องแก้:**
- `lib/features/pokemon_compare/presentation/pages/compare_pokemon_page.dart` (สร้างใหม่)
- `lib/features/pokemon_compare/presentation/bloc/compare_bloc.dart` (สร้างใหม่)
- `lib/core/utils/type_effectiveness.dart` (สร้างใหม่ - utility function)

**Hints:**
1. สร้าง `ComparePokemonPage` มี UI สำหรับเลือก Pokemon 2 ตัว
2. สร้าง `CompareBloc` รับ events: `SelectPokemon1`, `SelectPokemon2`, `ClearComparison`
3. สร้าง utility function `getTypeEffectiveness(attackType, defenseType)` return 0.5, 1.0 หรือ 2.0
4. ใน UI ใช้ `Row` + `Expanded` เพื่อแสดง Pokemon side-by-side
5. แสดง stats comparison ด้วย bar charts mirror (ซ้าย vs ขวา)
6. เพิ่ม indicator บอก Pokemon ตัวไหนมีความเสียหายมากกว่า

---

## Exercise 6: Cache Expiry (TTL) ⭐⭐ Medium

**เป้าหมาย:** เพิ่ม Time-To-Live (TTL) ให้ Hive cache เพื่อให้ data หมดอายุหลัง 24 ชั่วโมง

**คำอธิบาย (Thai):**
ปัจจุบัน Hive cache เก็บข้อมูล indefinitely ซึ่งอาจทำให้ข้อมูลเก่า ให้เพิ่ม TTL mechanism เพื่อให้ข้อมูล expire หลัง 24 ชั่วโมง เมื่อ cache expire ระบบจะดึงข้อมูลใหม่จาก API

**ไฟล์ที่ต้องแก้:**
- `lib/core/data/local/hive_cache_manager.dart`
- `lib/features/pokemon_detail/data/datasources/pokemon_local_data_source.dart`
- `lib/features/pokemon_detail/data/datasources/pokemon_remote_data_source.dart`

**Hints:**
1. สร้าง wrapper class สำหรับ cached data: `CachedData<T> { T data, DateTime cachedAt }`
2. เมื่อ save cache ให้บันทึก timestamp ด้วย
3. เมื่อ retrieve cache ให้ตรวจสอบว่า `DateTime.now() - cachedAt < Duration(hours: 24)`
4. ถ้า cache expire ให้ return null เพื่อให้ fallback chain ดึงข้อมูลจาก API
5. ให้ configureable TTL duration (ไม่ hard-code 24 hours)

---

## Exercise 7: Evolution Chain ⭐⭐⭐ Hard

**เป้าหมาย:** สร้าง `GetEvolutionChain` UseCase เพื่อดึงข้อมูล evolution chain จาก PokeAPI แล้วแสดง

**คำอธิบาย (Thai):**
Pokémon บางตัวสามารถวิวัฒนาได้เป็นตัวอื่น เช่น Charmander → Charmeleon → Charizard ให้สร้าง UseCase ที่ดึงข้อมูล evolution chain จาก PokeAPI (endpoint `/pokemon-species/{id}` → `evolution_chain.url` → `/evolution-chain/{id}`) แล้วแสดงเป็น horizontal scroll พร้อมแสดงเงื่อนไขการวิวัฒนา (เช่น level 16, stone ชนิดไหน)

**ไฟล์ที่ต้องแก้:**
- `lib/features/pokemon_detail/domain/entities/evolution_chain.dart` (สร้างใหม่)
- `lib/features/pokemon_detail/domain/usecases/get_evolution_chain.dart` (สร้างใหม่)
- `lib/features/pokemon_detail/data/datasources/pokemon_remote_data_source.dart`
- `lib/features/pokemon_detail/presentation/pages/pokemon_detail_page.dart`
- `lib/features/pokemon_detail/presentation/widgets/evolution_chain_widget.dart` (สร้างใหม่)

**Hints:**
1. สร้าง entity `EvolutionNode`: pokemonId, name, imageUrl, minLevel, trigger (level-up, trade, use-item), evolvesTo (List)
2. PokeAPI evolution-chain endpoint ส่ง recursive JSON structure ให้สร้าง recursive parser
3. UseCase รับ `int pokemonId` และ return `Future<List<EvolutionNode>>`
4. ใน widget ให้สร้าง `ListView.builder(scrollDirection: Axis.horizontal)` แสดง evolution chain
5. แต่ละ node แสดง: รูป, ชื่อ, เงื่อนไขการวิวัฒนา (เช่น "Lv. 16" หรือ "Fire Stone")

---

## Exercise 8: Add Third API Data Source ⭐⭐⭐ Hard

**เป้าหมาย:** เพิ่ม data source ตัวที่ 3 (เช่น local mock data) เข้า fallback chain

**คำอธิบาย (Thai):**
ปัจจุบันระบบมี 2 data sources: Remote (PokeAPI) และ Hive Cache ให้เพิ่ม data source ตัวที่ 3 เช่น local mock data หรือ secondary API เพื่อให้มี fallback option มากขึ้น เมื่อทั้ง Remote และ Cache ล้มเหลว ระบบจะลองใช้ data source ตัวที่ 3 นี้

**ไฟล์ที่ต้องแก้:**
- `lib/core/data/datasources/pokemon_mock_data_source.dart` (สร้างใหม่)
- `lib/features/pokemon_detail/data/repositories/pokemon_detail_repository_impl.dart`
- `lib/features/pokemon_detail/presentation/bloc/pokemon_detail_bloc.dart`

**Hints:**
1. สร้าง `PokemonMockDataSource` interface และ implementation
2. Mock data ควรมี Pokemon ยอดนิยม (เช่น Pikachu, Charizard, Dragonite)
3. ใน repository implement ให้ fallback chain เป็น: Remote → Cache → Mock
4. Mock data source ควร return limited subset ของ Pokemon อย่างรวดเร็ว
5. เพิ่ม error handling สำหรับแต่ละ data source และ log ว่า data มาจาก source ไหน

---

## Exercise Summary

| # | ชื่อ | ระดับ | โครงสร้าง | เรื่องที่เรียนรู้ |
|---|------|-------|---------|-------------|
| 1 | Type Filter | ⭐ | BLoC Event/State | State Management |
| 2 | Error UI | ⭐ | Widget/State | Error Handling |
| 3 | Ability Detail | ⭐⭐ | UseCase/Repository | UseCase Pattern |
| 4 | Pagination | ⭐⭐ | BLoC Event/State | Pagination Pattern |
| 5 | Compare Pokémon | ⭐⭐ | BLoC/Widget | Data Comparison |
| 6 | Cache Expiry | ⭐⭐ | Local Data Source | Cache Management |
| 7 | Evolution Chain | ⭐⭐⭐ | Recursive Parsing | Complex Data Structure |
| 8 | Third Data Source | ⭐⭐⭐ | Fallback Chain | Resilience Pattern |

---

## เคล็ดลับในการทำแบบฝึกหัด

1. **ทำตามลำดับ:** เริ่มจากข้อ 1-2 (ง่าย) แล้วค่อย ๆ ขึ้นไปสู่ข้อที่ยาก
2. **ดูไฟล์ที่มีอยู่แล้ว:** เช่น Exercise 3 อาจดูจาก `get_pokemon_detail.dart` ที่มีอยู่แล้ว
3. **ใช้ dependency injection:** เมื่อสร้าง UseCase ใหม่ให้ inject ผ่าน constructor
4. **Test each step:** สร้าง todo tasks ทีละขั้นตอน แล้ว test ว่าทำงานได้
5. **อ่าน PokeAPI docs:** เมื่อต้อง parse API response ให้ดูที่ https://pokeapi.co/docs/v2

---

*Happy coding! ฟลัตเตอร์เทพ! 🚀*
