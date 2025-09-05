import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/PokemonController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

class Team {
  final String name;
  final List<Map<String, String>> pokemons; // name & imageUrl
  Team({required this.name, required this.pokemons});

  // เพิ่มฟังก์ชันสำหรับแปลงเป็น Map และจาก Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pokemons': pokemons,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'],
      pokemons: List<Map<String, String>>.from(
        json['pokemons'].map((pokemon) => Map<String, String>.from(pokemon))
      ),
    );
  }
}

// เพิ่ม TeamDetailScreen ใหม่
class TeamDetailScreen extends StatelessWidget {
  final Team team;
  final int teamIndex;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const TeamDetailScreen({
    Key? key,
    required this.team,
    required this.teamIndex,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  int _generateCP(String pokemonName) {
    final random = math.Random(pokemonName.hashCode);
    return 100 + random.nextInt(2900);
  }

  int _calculateTotalCP() {
    return team.pokemons.fold(0, (sum, pokemon) => sum + _generateCP(pokemon['name']!));
  }

  @override
  Widget build(BuildContext context) {
    _calculateTotalCP();
    
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Text(
          team.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => onEdit(teamIndex),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => onDelete(teamIndex),
          ),
        ],
      ),
      body: Column(
        children: [
          // Team Badge และ CP
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Team Badge
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.catching_pokemon,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
    
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Pokemon Grid
          Expanded(
            child: team.pokemons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'เลือกโปเกมอนของคุณ!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ยังไม่มีโปเกมอนในทีมนี้',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8E6B8), // Light green background
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              team.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GestureDetector(
                                onTap: () => onEdit(teamIndex),
                                child: const Icon(Icons.edit, size: 20, color: Colors.orange),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GestureDetector(
                                onTap: () => onDelete(teamIndex),
                                child: const Icon(Icons.delete, size: 20, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Pokemon Grid (3x2 layout)
                        Expanded(
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: 6, // Always show 6 slots
                            itemBuilder: (context, index) {
                              if (index < team.pokemons.length) {
                                // Show pokemon
                                final pokemon = team.pokemons[index];
                                final cp = _generateCP(pokemon['name']!);
                                
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // CP Display
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'CP $cp',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      
                                      // Pokemon Image
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Image.network(
                                            pokemon['imageUrl']!,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Icon(Icons.catching_pokemon, 
                                                     size: 40, 
                                                     color: Colors.grey[400]),
                                          ),
                                        ),
                                      ),
                                      
                                      // Pokemon Name
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          pokemon['name']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                // Show empty slot
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 30,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'เลือกโปเกมอนของคุณ!',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4CAF50),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text(
              'ปิด',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final controller = Get.put(PokemonController());
  final searchController = TextEditingController();
  final searchText = ''.obs;
  final selectedType = ''.obs;

  // เก็บทีมทั้งหมด
  List<Team> teams = [];
  String? currentTeamName;

  // รายการธาตุโปเกม่อน
  final List<String> pokemonTypes = [
    'normal', 'fighting', 'flying', 'poison', 'ground', 'rock',
    'bug', 'ghost', 'steel', 'fire', 'water', 'grass',
    'electric', 'psychic', 'ice', 'dragon', 'dark', 'fairy'
  ];

  // สีของแต่ละธาตุ
  final Map<String, Color> typeColors = {
    'normal': Colors.brown,
    'fighting': Colors.red,
    'flying': Color(0xFF8FA8DD),
    'poison': Colors.purple,
    'ground': Color(0xFFDCB65C),
    'rock': Color(0xFFB8A058),
    'bug': Color(0xFF8CB230),
    'ghost': Color(0xFF705898),
    'steel': Color(0xFFB8B8D0),
    'fire': Colors.orange,
    'water': Colors.blue,
    'grass': Colors.green,
    'electric': Colors.yellow,
    'psychic': Colors.pink,
    'ice': Color(0xFF98D8D8),
    'dragon': Color(0xFF7038F8),
    'dark': Color(0xFF705848),
    'fairy': Color(0xFFEE99AC),
  };

  @override
  void initState() {
    super.initState();
    _loadTeams();
    ever(controller.isLoading, (bool loading) {
      if (!loading && controller.pokemonList.isNotEmpty) {
        _loadTeams();
      }
    });
  }

  // Generate random CP for demo purposes
  int _generateCP(String pokemonName) {
    final random = math.Random(pokemonName.hashCode);
    return 100 + random.nextInt(2900); // CP between 100-3000
  }

  // ฟังก์ชันช่วยสำหรับตรวจสอบความสัมพันธ์ระหว่างโปเกม่อนกับธาตุ
  bool _isPokemonRelatedToType(String pokemonName, String type) {
    final typeRelations = {
      'fire': ['char', 'growlithe', 'arcanine', 'ponyta', 'rapidash', 'magmar', 'flareon', 'moltres', 'cyndaquil', 'quilava', 'typhlosion'],
      'water': ['squirtle', 'wartortle', 'blastoise', 'psyduck', 'golduck', 'poliwag', 'poliwhirl', 'poliwrath', 'tentacool', 'tentacruel', 'slowpoke', 'slowbro', 'seel', 'dewgong', 'shellder', 'cloyster', 'krabby', 'kingler', 'horsea', 'seadra', 'goldeen', 'seaking', 'staryu', 'starmie', 'magikarp', 'gyarados', 'lapras', 'vaporeon', 'omanyte', 'omastar', 'kabuto', 'kabutops', 'totodile', 'croconaw', 'feraligatr'],
      'grass': ['bulbasaur', 'ivysaur', 'venusaur', 'oddish', 'gloom', 'vileplume', 'paras', 'parasect', 'bellsprout', 'weepinbell', 'victreebel', 'exeggcute', 'exeggutor', 'tangela', 'leafeon', 'chikorita', 'bayleef', 'meganium'],
      'electric': ['pikachu', 'raichu', 'magnemite', 'magneton', 'voltorb', 'electrode', 'electabuzz', 'jolteon', 'zapdos', 'mareep', 'flaaffy', 'ampharos'],
      'psychic': ['abra', 'kadabra', 'alakazam', 'slowpoke', 'slowbro', 'drowzee', 'hypno', 'exeggcute', 'exeggutor', 'starmie', 'jynx', 'mewtwo', 'mew', 'natu', 'xatu', 'espeon'],
      'ice': ['articuno', 'jynx', 'lapras', 'seel', 'dewgong', 'cloyster'],
      'dragon': ['dratini', 'dragonair', 'dragonite'],
      'dark': ['umbreon'],
      'steel': ['magnemite', 'magneton'],
      'fairy': ['clefairy', 'clefable', 'jigglypuff', 'wigglytuff'],
      'fighting': ['machop', 'machoke', 'machamp', 'hitmonlee', 'hitmonchan', 'primeape'],
      'poison': ['bulbasaur', 'ivysaur', 'venusaur', 'weedle', 'kakuna', 'beedrill', 'ekans', 'arbok', 'nidoran', 'nidorina', 'nidoqueen', 'nidorino', 'nidoking', 'oddish', 'gloom', 'vileplume', 'paras', 'parasect', 'venonat', 'venomoth', 'bellsprout', 'weepinbell', 'victreebel', 'tentacool', 'tentacruel', 'grimer', 'muk', 'gastly', 'haunter', 'gengar', 'koffing', 'weezing'],
      'ground': ['sandshrew', 'sandslash', 'nidoqueen', 'nidoking', 'diglett', 'dugtrio', 'geodude', 'graveler', 'golem', 'onix', 'cubone', 'marowak', 'rhyhorn', 'rhydon'],
      'flying': ['charizard', 'butterfree', 'pidgey', 'pidgeotto', 'pidgeot', 'spearow', 'fearow', 'zubat', 'golbat', 'farfetchd', 'doduo', 'dodrio', 'scyther', 'gyarados', 'aerodactyl', 'articuno', 'zapdos', 'moltres', 'dragonite'],
      'bug': ['caterpie', 'metapod', 'butterfree', 'weedle', 'kakuna', 'beedrill', 'paras', 'parasect', 'venonat', 'venomoth', 'scyther', 'pinsir'],
      'rock': ['geodude', 'graveler', 'golem', 'onix', 'rhyhorn', 'rhydon', 'omanyte', 'omastar', 'kabuto', 'kabutops', 'aerodactyl'],
      'ghost': ['gastly', 'haunter', 'gengar'],
      'normal': ['pidgey', 'pidgeotto', 'pidgeot', 'rattata', 'raticate', 'spearow', 'fearow', 'jigglypuff', 'wigglytuff', 'meowth', 'persian', 'psyduck', 'golduck', 'farfetchd', 'doduo', 'dodrio', 'seel', 'dewgong', 'lickitung', 'chansey', 'kangaskhan', 'tauros', 'ditto', 'eevee', 'porygon', 'snorlax'],
    };

    final relatedPokemons = typeRelations[type.toLowerCase()] ?? [];
    return relatedPokemons.any((related) => pokemonName.toLowerCase().contains(related));
  }

  // บันทึกทีมลง SharedPreferences
  Future<void> _saveTeams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teamsJson = teams.map((team) => team.toJson()).toList();
      final success = await prefs.setString('pokemon_teams', jsonEncode(teamsJson));
      print('Save teams result: $success');
      print('Saved teams: ${teamsJson.length}');
    } catch (e) {
      print('Error saving teams: $e');
    }
  }

  // โหลดทีมจาก SharedPreferences
  Future<void> _loadTeams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teamsString = prefs.getString('pokemon_teams');
      print('Loaded teams string: $teamsString');
      
      if (teamsString != null) {
        final List<dynamic> teamsJson = jsonDecode(teamsString);
        print('Parsed teams: ${teamsJson.length}');
        
        setState(() {
          teams = teamsJson.map((teamJson) => Team.fromJson(teamJson)).toList();
        });
        
        print('Teams loaded: ${teams.length}');
      }
    } catch (e) {
      print('Error loading teams: $e');
    }
  }

  void _showCreateTeamDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.group_add, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('ตั้งชื่อทีม', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'ชื่อทีม',
              hintText: 'กรอกชื่อทีมของคุณ',
              prefixIcon: const Icon(Icons.edit),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentTeamName = nameController.text.isEmpty ? "ทีมของฉัน" : nameController.text;
                controller.selectedPokemons.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTeam() async {
    if (currentTeamName != null && controller.selectedPokemons.isNotEmpty) {
      final savedTeamName = currentTeamName!;
      
      setState(() {
        teams.add(Team(
          name: savedTeamName,
          pokemons: controller.selectedPokemons
              .map((e) => {'name': e.name, 'imageUrl': e.imageUrl})
              .toList(),
        ));
        currentTeamName = null;
        controller.selectedPokemons.clear();
      });
      
      await _saveTeams();
      
      Get.snackbar(
        'สำเร็จ!',
        'บันทึกทีม "$savedTeamName" เรียบร้อยแล้ว',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: const Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'ผิดพลาด',
        'กรุณาเลือกโปเกม่อนอย่างน้อย 1 ตัวก่อนบันทึกทีม',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _editTeamName(int index) async {
    final nameController = TextEditingController(text: teams[index].name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('แก้ไขชื่อทีม', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'ชื่อทีมใหม่',
              hintText: 'กรอกชื่อทีมใหม่',
              prefixIcon: const Icon(Icons.edit),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  teams[index] = Team(
                    name: nameController.text,
                    pokemons: teams[index].pokemons,
                  );
                });
                
                await _saveTeams();
                
                Get.snackbar(
                  'สำเร็จ!',
                  'แก้ไขชื่อทีมเป็น "${nameController.text}" เรียบร้อยแล้ว',
                  backgroundColor: Colors.orange[100],
                  colorText: Colors.orange[800],
                  icon: const Icon(Icons.check_circle, color: Colors.orange),
                  duration: const Duration(seconds: 3),
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeam(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบทีม "${teams[index].name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
                          onPressed: () async {
              setState(() {
                teams.removeAt(index);
              });
              
              await _saveTeams();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewTeamDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamDetailScreen(
          team: teams[index],
          teamIndex: index,
          onEdit: _editTeamName,
          onDelete: _deleteTeam,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8), // Pokemon GO green background
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentTeamName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pink[300]!, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.catching_pokemon, color: Colors.pink[600], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      currentTeamName!,
                      style: TextStyle(
                        color: Colors.pink[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          if (currentTeamName != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Reset Pokemon Selection',
              onPressed: () {
                controller.selectedPokemons.clear();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'ค้นหา',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => searchText.value = value.toLowerCase(),
                  ),
                ),
              ],
            ),
          ),

          // Type Filter
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pokemonTypes.length + 1, // +1 สำหรับ "ทั้งหมด"
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Obx(() => Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('ทั้งหมด', style: TextStyle(fontSize: 12)),
                      selected: selectedType.value.isEmpty,
                      onSelected: (selected) {
                        selectedType.value = '';
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.blue[100],
                      checkmarkColor: Colors.blue[600],
                      labelStyle: TextStyle(
                        color: selectedType.value.isEmpty ? Colors.blue[600] : Colors.grey[700],
                        fontWeight: selectedType.value.isEmpty ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ));
                }
                
                final type = pokemonTypes[index - 1];
                final typeColor = typeColors[type] ?? Colors.grey;
                
                return Obx(() => Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type.toUpperCase(), style: const TextStyle(fontSize: 10)),
                    selected: selectedType.value == type,
                    onSelected: (selected) {
                      selectedType.value = selected ? type : '';
                    },
                    backgroundColor: Colors.white,
                    selectedColor: typeColor.withOpacity(0.2),
                    checkmarkColor: typeColor,
                    side: BorderSide(color: typeColor.withOpacity(0.3)),
                    labelStyle: TextStyle(
                      color: selectedType.value == type ? typeColor : Colors.grey[700],
                      fontWeight: selectedType.value == type ? FontWeight.bold : FontWeight.normal,
                      fontSize: 10,
                    ),
                  ),
                ));
              },
            ),
          ),

          const SizedBox(height: 16),

          // Selected Pokemon indicators (if creating team)
          if (currentTeamName != null)
            Obx(() {
              if (controller.selectedPokemons.isEmpty) return const SizedBox.shrink();
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.selectedPokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = controller.selectedPokemons[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.pink[300]!, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          pokemon.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.catching_pokemon, color: Colors.pink[400]),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

          if (currentTeamName != null && controller.selectedPokemons.isNotEmpty)
            const SizedBox(height: 16),

          // Teams section (when not creating team) - Enhanced with tap to view detail
          if (teams.isNotEmpty && currentTeamName == null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ทีมที่สร้างแล้ว (${teams.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        return GestureDetector(
                          onTap: () => _viewTeamDetail(index), // เพิ่ม tap to view detail
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            team.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${team.pokemons.length} โปเกม่อน - แตะเพื่อดูรายละเอียด',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _editTeamName(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[50],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(Icons.edit, 
                                              color: Colors.orange[400], 
                                              size: 16
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => _deleteTeam(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(Icons.delete, 
                                              color: Colors.red[400], 
                                              size: 16
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (team.pokemons.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 80,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: team.pokemons.length,
                                      itemBuilder: (context, pokemonIndex) {
                                        final pokemon = team.pokemons[pokemonIndex];
                                        final cp = _generateCP(pokemon['name']!);
                                        
                                        return Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          width: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Column(
                                            children: [
                                              // CP
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(vertical: 1),
                                                child: Text(
                                                  'CP $cp',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ),
                                              // Pokemon Image
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(2),
                                                  child: Image.network(
                                                    pokemon['imageUrl']!,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        Icon(Icons.catching_pokemon, 
                                                             size: 20, 
                                                             color: Colors.grey[400]),
                                                  ),
                                                ),
                                              ),
                                              // Pokemon Name
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                                child: Text(
                                                  pokemon['name']!,
                                                  style: const TextStyle(
                                                    fontSize: 7,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ] else
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'ไม่มีโปเกม่อนในทีม',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          if (teams.isNotEmpty && currentTeamName == null) 
            const SizedBox(height: 16),

          // Pokemon Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                );
              }
              
              final filteredList = controller.pokemonList.where((p) {
                final matchesSearch = p.name.toLowerCase().contains(searchText.value);
                if (selectedType.value.isEmpty) {
                  return matchesSearch;
                }
                final typeRelated = _isPokemonRelatedToType(p.name, selectedType.value);
                return matchesSearch && typeRelated;
              }).toList();

              if (filteredList.isEmpty) {
                return const Center(
                  child: Text('ไม่พบโปเกม่อนที่ค้นหา'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final pokemon = filteredList[index];
                  final isSelected = controller.selectedPokemons.contains(pokemon);
                  final canSelect = currentTeamName != null;
                  final cp = _generateCP(pokemon.name);

                  return GestureDetector(
                    onTap: canSelect ? () => controller.toggleSelection(pokemon) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isSelected 
                            ? [const Color(0xFFFCE4EC), const Color(0xFFF8BBD9)]
                            : [Colors.white, const Color(0xFFF5F5F5)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.pink[300]! : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              // CP Display
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  'CP $cp',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              
                              // Pokemon Image
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.network(
                                    pokemon.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.catching_pokemon, 
                                             size: 50, 
                                             color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                              
                              // Pokemon Name
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  pokemon.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.grey[800],
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          // Selection indicator
                          if (isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.pink[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          
                          // Disabled overlay
                          if (!canSelect)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
        ),
        child: SafeArea(
          child: currentTeamName == null
              ? ElevatedButton(
                  onPressed: _showCreateTeamDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4CAF50),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    'สร้างทีมใหม่',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              : Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          currentTeamName = null;
                          controller.selectedPokemons.clear();
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 50),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                            onPressed: controller.selectedPokemons.isNotEmpty ? _saveTeam : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: controller.selectedPokemons.isNotEmpty 
                                  ? Colors.white 
                                  : Colors.grey[400],
                              foregroundColor: controller.selectedPokemons.isNotEmpty
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey[600],
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: Text(
                              'เสร็จสิ้น (${controller.selectedPokemons.length})',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}