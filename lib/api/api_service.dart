// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// ---------- Diccionarios básicos ES ----------
const _alcoholFlagEs = {
  'Alcoholic': 'con alcohol',
  'Non alcoholic': 'sin alcohol',
  'Optional alcohol': 'alcohol opcional',
};

const _glassEs = {
  'Cocktail glass': 'copa de cóctel',
  'Old-fashioned glass': 'vaso corto (old fashioned)',
  'Highball glass': 'vaso alto (highball)',
  'Collins glass': 'vaso collins',
  'Champagne flute': 'copa flauta',
  'Martini Glass': 'copa martini',
  'Margarita/Coupette glass': 'copa margarita',
  'Hurricane glass': 'vaso huracán',
  'Whiskey sour glass': 'vaso whiskey sour',
  'Shot glass': 'vaso de shot',
  'Wine Glass': 'copa de vino',
};

/// Traducción simple de ingredientes (clave minúscula, sin tildes ni plural)
String _toSpanishIng(String raw) {
  final key = raw.trim().toLowerCase();
  const dict = {
    // licores base
    'vodka': 'vodka',
    'gin': 'ginebra',
    'genever': 'ginebra',
    'rum': 'ron',
    'light rum': 'ron blanco',
    'dark rum': 'ron oscuro',
    'white rum': 'ron blanco',
    'gold rum': 'ron dorado',
    'spiced rum': 'ron especiado',
    'tequila': 'tequila',
    'mezcal': 'mezcal',
    'whiskey': 'whisky',
    'whisky': 'whisky',
    'bourbon': 'bourbon',
    'scotch': 'whisky escocés',
    'rye whiskey': 'whisky de centeno',
    'brandy': 'brandy',
    'cognac': 'coñac',
    'pisco': 'pisco',

    // licores / vermuts / aperitivos
    'triple sec': 'triple sec',
    'cointreau': 'cointreau',
    'campari': 'campari',
    'aperol': 'aperol',
    'sweet vermouth': 'vermut rojo',
    'dry vermouth': 'vermut seco',
    'vermouth': 'vermut',
    'orange liqueur': 'licor de naranja',
    'coffee liqueur': 'licor de café',
    'amaretto': 'amaretto',
    'blue curacao': 'curaçao azul',
    'creme de cacao': 'crema de cacao',
    'creme de menthe': 'crema de menta',
    'midori melon liqueur': 'licor de melón (Midori)',

    // jugos / mixers
    'lime juice': 'jugo de lima',
    'lemon juice': 'jugo de limón',
    'orange juice': 'jugo de naranja',
    'pineapple juice': 'jugo de piña',
    'cranberry juice': 'jugo de arándano',
    'grapefruit juice': 'jugo de pomelo',
    'apple juice': 'jugo de manzana',
    'tomato juice': 'jugo de tomate',

    'sugar': 'azúcar',
    'sugar syrup': 'jarabe de azúcar',
    'simple syrup': 'jarabe simple',
    'agave syrup': 'jarabe de agave',
    'honey syrup': 'jarabe de miel',
    'grenadine': 'granadina',
    'bitters': 'amargos',
    'angostura bitters': 'amargos de Angostura',
    'orange bitters': 'amargos de naranja',
    'salt': 'sal',
    'salt rim': 'sal para el borde',
    'pepper': 'pimienta',

    // gaseosas
    'soda water': 'agua con gas',
    'club soda': 'soda',
    'tonic water': 'agua tónica',
    'coca-cola': 'coca-cola',
    'cola': 'bebida cola',
    'ginger ale': 'ginger ale',
    'ginger beer': 'ginger beer',

    // otros
    'egg white': 'clara de huevo',
    'mint': 'menta',
    'mint leaves': 'hojas de menta',
    'basil': 'albahaca',
    'cucumber': 'pepino',
    'strawberries': 'frutillas',
    'strawberry': 'frutilla',
    'cherry': 'cereza',
    'maraschino cherry': 'cereza marrasquino',
    'olive': 'aceituna',
    'orange peel': 'piel de naranja',
    'orange zest': 'ralladura de naranja',
    'lemon peel': 'piel de limón',
    'lemon zest': 'ralladura de limón',
    'lime': 'lima',
    'lemon': 'limón',
    'orange': 'naranja',
    'pineapple': 'piña',
    'ice': 'hielo',
    'crushed ice': 'hielo picado',
    'kahlua': 'kahlúa',
    'baileys irish cream': 'baileys',
    'irish cream': 'crema irlandesa',
  };

  // si hay coincidencia directa
  if (dict.containsKey(key)) return dict[key]!;
  // normalizaciones rápidas
  if (key.contains('rum')) return 'ron';
  if (key.contains('whisk')) return 'whisky';
  if (key.contains('vermouth')) return 'vermut';
  if (key.contains('curacao')) return 'curaçao';
  if (key.contains('juice')) return raw.replaceAll('juice', 'jugo');
  // por defecto, devuelve tal cual (capitalizando)
  return raw;
}

/// Detecta licores base en español a partir de la lista de ingredientes ya traducidos
Iterable<String> _detectBaseLiquorsEs(List<String> ingredientesEs) {
  const base = {
    'vodka','ginebra','ron','tequila','mezcal','whisky','bourbon','pisco','brandy','coñac'
  };
  final low = ingredientesEs.map((s) => s.toLowerCase()).toList();
  final out = <String>{};
  for (final b in base) {
    if (low.any((x) => x.contains(b))) out.add(b);
  }
  // normaliza 'whisky escocés', 'whisky de centeno' a 'whisky'
  if (out.contains('whisky')) out.add('whisky');
  return out;
}

/// ---------- Mapper principal ----------
Map<String, dynamic> mapCocktailFromApi(Map<String, dynamic> raw) {
  final name      = (raw['strDrink'] ?? '').toString();
  final thumb     = (raw['strDrinkThumb'] ?? '').toString();
  final category  = (raw['strCategory'] ?? '').toString();
  final alcoholic = (raw['strAlcoholic'] ?? '').toString();
  final glass     = (raw['strGlass'] ?? '').toString();

  // usa español si existe
  final instr = (raw['strInstructionsES'] ?? raw['strInstructions'] ?? '').toString();

  // Ingredientes + medidas (1..15), traduciendo ingrediente a ES
  final ingredientesLineas = <String>[];
  final ingredientesNombresEs = <String>[];
  for (int i = 1; i <= 15; i++) {
    final ing = raw['strIngredient$i'];
    final mea = raw['strMeasure$i'];
    if (ing != null && ing.toString().trim().isNotEmpty) {
      final ingEn = ing.toString().trim();
      final ingEs = _toSpanishIng(ingEn);
      ingredientesNombresEs.add(ingEs);
      final linea = (mea != null && mea.toString().trim().isNotEmpty)
          ? '${mea.toString().trim()} $ingEs'
          : ingEs;
      ingredientesLineas.add('• $linea');
    }
  }

  // Dificultad por cantidad de ingredientes
  String dificultad;
  if (ingredientesNombresEs.length <= 3)      dificultad = 'fácil';
  else if (ingredientesNombresEs.length <= 6) dificultad = 'intermedio';
  else                                        dificultad = 'avanzado';

  // Herramientas inferidas por texto
  final lowInstr = instr.toLowerCase();
  final herramientas = <String>[
    if (lowInstr.contains('shake') || lowInstr.contains('shaker') || lowInstr.contains('agitar')) 'coctelera',
    if (lowInstr.contains('strain') || lowInstr.contains('colar')) 'colador',
    if (lowInstr.contains('stir')   || lowInstr.contains('remover')) 'cuchara',
    'medidor',
  ].toSet().toList();

  // Etiquetas básicas + licor base (ES)
  final alcoholEs = _alcoholFlagEs[alcoholic] ?? alcoholic.toLowerCase();
  final glassEs = _glassEs[glass] ?? glass.toLowerCase();
  final baseMatchesEs = _detectBaseLiquorsEs(ingredientesNombresEs);

  final tags = <String>[
    if (category.isNotEmpty) category.toLowerCase(),
    if (alcoholEs.isNotEmpty) alcoholEs,
    if (glassEs.isNotEmpty) glassEs,
    ...baseMatchesEs,
  ].toSet().toList();

  // Descripción corta en ES
  final descripcionEs = [
    if (category.isNotEmpty) category,
    if (alcoholEs.isNotEmpty) alcoholEs,
    if (glassEs.isNotEmpty) glassEs,
  ].join(' • ');

  final detalle = StringBuffer()
    ..writeln('Ingredientes:')
    ..writelnAll(ingredientesLineas)
    ..writeln('\nPreparación:')
    ..writeln(instr.isEmpty ? '—' : instr);

  return {
    'id': (raw['idDrink'] ?? name).toString(),
    'nombre': name,
    'descripcion': descripcionEs,
    'detalle': detalle.toString().trim(),
    'imagen': thumb,                      // URL
    'tags': tags,                         // incluye licor base en ES
    'ingredientes': ingredientesNombresEs, // <-- AHORA EN ESPAÑOL
    'herramientas': herramientas,
    'dificultad': dificultad,
    '_source': 'api',
  };
}

extension _Buffer on StringBuffer {
  void writelnAll(Iterable<String> lines) {
    for (final l in lines) writeln(l);
  }
}

class CocktailApi {
  static const String _base = 'https://www.thecocktaildb.com/api/json/v1/1';

  Future<List<Map<String, dynamic>>> searchByName(String query) async {
    final q = (query.trim().isEmpty) ? 'a' : query.trim();
    final url = Uri.parse('$_base/search.php?s=$q');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Error HTTP ${res.statusCode}');
    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    final drinks = (jsonBody['drinks'] as List?) ?? [];
    return drinks
        .map<Map<String, dynamic>>((e) => mapCocktailFromApi(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Map<String, dynamic>?> lookupById(String id) async {
    final url = Uri.parse('$_base/lookup.php?i=$id');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Error HTTP ${res.statusCode}');
    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    final drinks = (jsonBody['drinks'] as List?) ?? [];
    if (drinks.isEmpty) return null;
    return mapCocktailFromApi(Map<String, dynamic>.from(drinks.first as Map));
  }

  Future<Map<String, dynamic>> random() async {
    final url = Uri.parse('$_base/random.php');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Error HTTP ${res.statusCode}');
    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    final drinks = (jsonBody['drinks'] as List?) ?? [];
    if (drinks.isEmpty) throw Exception('Sin datos');
    return mapCocktailFromApi(Map<String, dynamic>.from(drinks.first as Map));
  }

  Future<List<Map<String, dynamic>>> searchByFirstLetter(String letter) async {
    final l = letter.isEmpty ? 'a' : letter[0];
    final url = Uri.parse('$_base/search.php?f=$l');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Error HTTP ${res.statusCode}');
    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    final drinks = (jsonBody['drinks'] as List?) ?? [];
    return drinks
        .map<Map<String, dynamic>>((e) => mapCocktailFromApi(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<Map<String, dynamic>>> searchByLettersBatch(List<String> letters) async {
    final results = <Map<String, dynamic>>[];
    for (final l in letters) {
      final chunk = await searchByFirstLetter(l);
      results.addAll(chunk);
    }
    final seen = <String>{};
    final dedup = <Map<String, dynamic>>[];
    for (final it in results) {
      final id = (it['id'] ?? '').toString();
      if (seen.add(id)) dedup.add(it);
    }
    dedup.sort((a, b) => (a['nombre'] as String).compareTo(b['nombre'] as String));
    return dedup;
  }
}
