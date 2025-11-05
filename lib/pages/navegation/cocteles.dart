import 'package:flutter/material.dart';
import '../../config.dart';
import '../../preferences.dart';

class Cocteles extends StatefulWidget {
  const Cocteles({super.key});

  @override
  State<Cocteles> createState() => _CoctelesState();
}

class _CoctelesState extends State<Cocteles> {
  // ---------- Catálogo (prototipo) ----------
  final List<Map<String, dynamic>> items = [
    {
      "nombre": "Margarita",
      "descripcion": "Cóctel fresco con tequila, triple sec y lima.",
      "detalle": """
• 50 ml tequila blanco
• 25 ml triple sec (Cointreau)
• 25 ml jugo de lima
• Hielos
• Borde de sal (opcional)
Agitar con hielo y colar en copa fría.
""",
      "imagen": "assets/tragos/Margarita.png",
      "tags": ["cítrico", "clásico"],
      "herramientas": ["coctelera", "colador", "medidor"],
      "dificultad": "intermedio",
    },
    {
      "nombre": "Negroni",
      "descripcion": "Clásico italiano con gin, Campari y vermut.",
      "detalle": """
• 30 ml gin
• 30 ml Campari
• 30 ml vermut rosso
• Hielos
Remover en vaso con hielo y decorar con piel de naranja.
""",
      "imagen": "assets/tragos/Negroni.png",
      "tags": ["amargo", "clásico"],
      "herramientas": ["cuchara", "vaso mezclador", "medidor"],
      "dificultad": "fácil",
    },
    {
      "nombre": "Piscola",
      "descripcion": "Coca-Cola con pisco, servido con hielo.",
      "detalle": """
• 50 ml pisco (40° aprox.)
• 150–200 ml Coca-Cola (a gusto)
• Hielo en vaso alto
• Gajo de limón (opcional)
Servir pisco sobre hielo y completar con cola.
""",
      "imagen": "assets/tragos/piscola.png",
      "tags": ["rápido", "refrescante"],
      "herramientas": ["vaso alto"],
      "dificultad": "fácil",
    },
  ];

  // ---------- Estado de filtros (UI local) ----------
  String searchQuery = '';
  bool isSearching = false;
  final Set<String> selectedTags = {};
  final Set<String> selectedTools = {};
  // UI local: 'todas' | 'fácil' | 'intermedio' | 'avanzado'
  String selectedDifficulty = "todas";

  // ---------- Preferencias globales ----------
  bool _prefsLoaded = false;
  bool hasBarKit = false;                 // switch en ajustes
  String difficultyFilter = 'difícil';    // dropdown en ajustes: 'fácil' | 'intermedio' | 'difícil'

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final kit = await AppPrefs.getHasBarKit();
    final dif = await AppPrefs.getDifficultyFilter();
    setState(() {
      hasBarKit = kit;
      difficultyFilter = dif;
      _prefsLoaded = true;
    });
  }

  // ---------- Helpers de búsqueda ----------
  String _normalize(String s) {
    const mapa = {
      'á': 'a','é': 'e','í': 'i','ó': 'o','ú': 'u','ü': 'u',
      'Á': 'a','É': 'e','Í': 'i','Ó': 'o','Ú': 'u','Ü': 'u',
      'ñ': 'n','Ñ': 'n',
    };
    final sb = StringBuffer();
    for (final ch in s.trim().toLowerCase().runes) {
      final c = String.fromCharCode(ch);
      sb.write(mapa[c] ?? c);
    }
    return sb.toString();
  }

  List<String> _tokens(String s) =>
      _normalize(s).split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  int _lev(String a, String b) {
    final m = a.length, n = b.length;
    if (m == 0) return n;
    if (n == 0) return m;
    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (int i = 0; i <= m; i++) dp[i][0] = i;
    for (int j = 0; j <= n; j++) dp[0][j] = j;
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
    }
    return dp[m][n];
  }

  bool _containsFuzzy(String haystack, String needle) {
    if (haystack.contains(needle)) return true;
    if (needle.length >= 4) {
      final words = haystack.split(RegExp(r'[^a-z0-9]+')).where((w) => w.isNotEmpty);
      for (final w in words) {
        if (_lev(w, needle) <= 1) return true;
      }
    }
    return false;
  }

  // ---------- Lógica combinada de filtros ----------
  bool _passesFilters(Map<String, dynamic> it) {
    // 0) Preferencia global: kit bartender
    if (!hasBarKit) {
      final tools = Set<String>.from(it['herramientas'] ?? const [])
          .map((e) => e.toString().toLowerCase())
          .toSet();
      const proTools = {
        'coctelera','colador','vaso mezclador','medidor','jigger','strainer','mixing glass',
      };
      if (tools.intersection(proTools).isNotEmpty) return false;
    }

    // 1) Búsqueda avanzada
    final qTokens = _tokens(searchQuery);
    if (qTokens.isNotEmpty) {
      final blob = _normalize([
        it['nombre'] ?? '',
        it['descripcion'] ?? '',
        (it['tags'] ?? const []).join(' '),
      ].join(' '));
      for (final tok in qTokens) {
        if (!_containsFuzzy(blob, tok)) return false;
      }
    }

    // 2) Etiquetas (AND)
    if (selectedTags.isNotEmpty) {
      final tags = Set<String>.from(it['tags'] ?? const []);
      for (final t in selectedTags) {
        if (!tags.contains(t)) return false;
      }
    }

    // 3) Herramientas seleccionadas (subset)
    if (selectedTools.isNotEmpty) {
      final tools = Set<String>.from(it['herramientas'] ?? const []);
      if (!tools.containsAll(selectedTools)) return false;
    }

    // 4a) Preferencia global de dificultad (tope máximo)
    if (difficultyFilter != 'difícil') {
      const niveles = {'fácil': 1, 'intermedio': 2, 'difícil': 3};
      final maxLevel = niveles[difficultyFilter] ?? 3;
      final itemLevel = niveles[(it['dificultad'] ?? 'fácil')] ?? 1;
      if (itemLevel > maxLevel) return false;
    }

    // 4b) Filtro UI local (si el usuario elige uno específico en la pantalla)
    if (selectedDifficulty != "todas") {
      final dif = (it['dificultad'] ?? '').toString().toLowerCase();
      if (dif != selectedDifficulty) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text('Cócteles')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Catálogos dinámicos para chips
    final allTags = {
      for (final it in items) ...List<String>.from(it['tags'] ?? const [])
    }.toList()
      ..sort();

    final allTools = {
      for (final it in items) ...List<String>.from(it['herramientas'] ?? const [])
    }.toList()
      ..sort();

    final filteredItems = items.where((it) => _passesFilters(it)).toList();

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar cóctel…',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                onChanged: (value) => setState(() => searchQuery = value),
              )
            : const Text("Cócteles"),
        actions: [
          // Botón ajustes
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
              // recargar preferencias al volver
              final kit = await AppPrefs.getHasBarKit();
              final dif = await AppPrefs.getDifficultyFilter();
              if (mounted) {
                setState(() {
                  hasBarKit = kit;
                  difficultyFilter = dif;
                });
              }
            },
          ),
          // Búsqueda
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) searchQuery = '';
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ---------- FILTROS (UI local) ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dificultad (UI local)
                Row(
                  children: [
                    const Text('Dificultad:'),
                    const SizedBox(width: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'todas', label: Text('Todas')),
                        ButtonSegment(value: 'fácil', label: Text('Fácil')),
                        ButtonSegment(value: 'intermedio', label: Text('Intermedio')),
                        ButtonSegment(value: 'avanzado', label: Text('Avanzado')),
                      ],
                      selected: {selectedDifficulty},
                      onSelectionChanged: (set) {
                        setState(() => selectedDifficulty = set.first);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Etiquetas
                const Text('Etiquetas:'),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final tag in allTags)
                      FilterChip(
                        label: Text(tag),
                        selected: selectedTags.contains(tag),
                        onSelected: (sel) => setState(() {
                          if (sel) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Herramientas (usuario)
                const Text('Herramientas disponibles (propias):'),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final tool in allTools)
                      FilterChip(
                        label: Text(tool),
                        selected: selectedTools.contains(tool),
                        onSelected: (sel) => setState(() {
                          if (sel) {
                            selectedTools.add(tool);
                          } else {
                            selectedTools.remove(tool);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      selectedTags.clear();
                      selectedTools.clear();
                      selectedDifficulty = "todas";
                      searchQuery = '';
                      isSearching = false;
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Limpiar filtros'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ---------- LISTA ----------
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final it = filteredItems[i];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalleCoctel(
                          nombre: it["nombre"] as String,
                          descripcion: it["descripcion"] as String,
                          detalle: it["detalle"] as String,
                          imagen: it["imagen"] as String,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              it["imagen"] as String,
                              width: 64, height: 64, fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it["nombre"] as String,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 219, 223, 14),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  it["descripcion"] as String,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: -8,
                                  children: [
                                    if (it['dificultad'] != null)
                                      Chip(
                                        label: Text("${it['dificultad']}"),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    for (final t in (it['tags'] ?? const []))
                                      Chip(
                                        label: Text("$t"),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetalleCoctel extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String detalle;
  final String imagen;

  const DetalleCoctel({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.detalle,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          nombre,
          style: const TextStyle(color: Color.fromARGB(255, 219, 223, 14)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 8, color: const Color.fromARGB(255, 0, 0, 0)),
              ),
              child: Image.asset(imagen),
            ),
          ),
          const SizedBox(height: 16),
          Text(descripcion, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          const Text(
            "Medidas",
            style: TextStyle(
              color: Color.fromARGB(255, 219, 223, 14),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(detalle, style: const TextStyle(fontSize: 16, height: 1.4)),
        ],
      ),
    );
  }
}
