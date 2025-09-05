import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:myapp/models/PokemonModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonController extends GetxController {
  var pokemonList = <Pokemon>[].obs;
  var selectedPokemons = <Pokemon>[].obs;
  var isLoading = true.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchPokemons();
  }

  Future<void> fetchPokemons() async {
    try {
      isLoading(true);
      List<Pokemon> loadedPokemons = [];
      for (int i = 1; i <= 150; i++) {
        final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$i'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          loadedPokemons.add(Pokemon.fromJson(data));
        }
      }
      pokemonList.value = loadedPokemons;
      loadSelectedPokemons(); // โหลดหลังจาก pokemonList ถูกเซ็ต
    } finally {
      isLoading(false);
    }
  }

  void toggleSelection(Pokemon pokemon) {
    if (selectedPokemons.contains(pokemon)) {
      selectedPokemons.remove(pokemon);
    } else {
      selectedPokemons.add(pokemon);
    }
    saveSelectedPokemons();
  }

  void saveSelectedPokemons() {
    final selectedNames = selectedPokemons.map((e) => e.name).toList();
    box.write('selectedPokemons', selectedNames);
  }

  void loadSelectedPokemons() {
    final selectedNames = box.read<List>('selectedPokemons') ?? [];
    selectedPokemons.value = pokemonList.where((pokemon) => selectedNames.contains(pokemon.name)).toList();
  }

  void resetTeam() {
    selectedPokemons.clear();
    box.remove('selectedPokemons');
  }
}