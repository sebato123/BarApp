import 'package:flutter/material.dart';
import '../../config.dart';
import '../../preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../api/api_service.dart';

class Cocteles extends StatefulWidget {
  const Cocteles({super.key});
  @override
  State<Cocteles> createState() => _CoctelesState();
}

class _CoctelesState extends State<Cocteles> {
  final _api = CocktailApi();

  // Catálogo solo API
  final List<Map<String, dynamic>> _catalog = [];

  // Estado filtros
  String searchQuery = '';
  // Usaremos este set para guardar los licores base seleccionados (chips)
  final Set<String> selectedBaseLiquors = {};

  // Preferencias globales
  bool _prefsLoaded = false;
  bool hasBarKit = false;
  String difficultyFilter = 'difícil';

  bool _loading = true;

  // Chips fijos de licor base (en español)
  static const List<String> _licorBaseChips = [
    'vodka',
    'ginebra',
    'ron',
    'tequila',
    'mezcal',
    'whisky',
    'bourbon',
    'pisco',
    'brandy',
    'coñac',
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final kit = await AppPrefs.getHasBarKit();
    final dif = await AppPrefs.getDifficultyFilter();
    // Catálogo grande inicial (ajusta letras si quieres más/menos)
    final data = await _api.searchByLettersBatch(['a','e','m','p','s','n','r']);
    setState(() {
      hasBarKit = kit;
      difficultyFilter = dif;
      _prefsLoaded = true;
      _catalog
        ..clear()
        ..addAll(data);
      _loading = false;
    });
  }

  // -------- Helpers búsqueda --------
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

  // -------- Filtros --------
  bool _passesFilters(Map<String, dynamic> it) {
    // 1) Texto
    final qTokens = _tokens(searchQuery);
    if (qTokens.isNotEmpty) {
      final blob = _normalize([
        it['nombre'] ?? '',
        it['descripcion'] ?? '',
        (it['tags'] ?? const []).join(' '),
        (it['ingredientes'] ?? const []).join(' '),
      ].join(' '));
      for (final tok in qTokens) {
        if (!_containsFuzzy(blob, tok)) return false;
      }
    }

    // 2) Chips de licor base (OR: basta con que tenga al menos uno)
    if (selectedBaseLiquors.isNotEmpty) {
      final tags = (it['tags'] as List? ?? const []).map((e) => e.toString().toLowerCase()).toSet();
      final want = selectedBaseLiquors.map((e) => e.toLowerCase()).toSet();
      if (tags.intersection(want).isEmpty) return false;
    }

    // 3) Dificultad tope desde preferencias (fácil/intermedio/difícil)
    if (difficultyFilter != 'difícil') {
      const niveles = {'fácil': 1, 'intermedio': 2, 'avanzado': 3, 'difícil': 3};
      final maxLevel = niveles[difficultyFilter] ?? 3;
      final itemLevel = niveles[(it['dificultad'] ?? 'fácil')] ?? 1;
      if (itemLevel > maxLevel) return false;
    }

    return true;
  }

  // -------- UI --------
  Widget _thumb(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: 64, height: 64, fit: BoxFit.cover,
        placeholder: (_, __) => const SizedBox(
          width: 64, height: 64, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
      );
    }
    return Image.asset(path, width: 64, height: 64, fit: BoxFit.cover);
  }

  void _openFilterSheet() {
    final tempBases = {...selectedBaseLiquors};
    String tempQuery = searchQuery;
    final controller = TextEditingController(text: tempQuery);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModal) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Buscar y filtrar',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // Buscador por texto
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o palabra clave',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setModal(() => tempQuery = v),
                    ),

                    const SizedBox(height: 20),
                    const Text('Licor base'),
                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final licor in _licorBaseChips)
                          FilterChip(
                            label: Text(licor),
                            selected: tempBases.contains(licor),
                            onSelected: (sel) {
                              setModal(() {
                                if (sel) tempBases.add(licor);
                                else tempBases.remove(licor);
                              });
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedBaseLiquors.clear();
                              searchQuery = '';
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Limpiar'),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedBaseLiquors
                                ..clear()
                                ..addAll(tempBases);
                              searchQuery = tempQuery;
                            });
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Aplicar'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _randomOne() async {
    setState(() => _loading = true);
    try {
      final rnd = await _api.random();
      setState(() {
        _catalog
          ..clear()
          ..add(rnd);
        selectedBaseLiquors.clear();
        searchQuery = '';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded || _loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cócteles')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _catalog.where(_passesFilters).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cócteles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Buscar y filtrar',
            onPressed: _openFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              final kit = await AppPrefs.getHasBarKit();
              final dif = await AppPrefs.getDifficultyFilter();
              if (!mounted) return;
              setState(() {
                hasBarKit = kit;
                difficultyFilter = dif;
              });
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _randomOne,
        icon: const Icon(Icons.shuffle),
        label: const Text('Trago aleatorio'),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final it = filtered[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () async {
                var full = it;
                final id = (it['id'] ?? '').toString();
                if (id.isNotEmpty) {
                  showDialog(context: context, barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()));
                  try {
                    final det = await _api.lookupById(id);
                    if (det != null) full = det;
                  } finally {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  }
                }
                if (!context.mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => DetalleCoctel(
                    nombre: full['nombre'],
                    descripcion: full['descripcion'],
                    detalle: full['detalle'],
                    imagen: full['imagen'],
                  ),
                ));
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _thumb(it['imagen'] as String),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it['nombre'] as String,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(it['descripcion'] as String),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: -8,
                            children: [
                              if (it['dificultad'] != null)
                                Chip(label: Text("${it['dificultad']}"),
                                    visualDensity: VisualDensity.compact),
                              for (final t in (it['tags'] as List? ?? const []))
                                Chip(label: Text("$t"), visualDensity: VisualDensity.compact),
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

  Widget _hero(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (_, __) => const AspectRatio(
          aspectRatio: 16/9,
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 64),
      );
    }
    return Image.asset(path, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _hero(imagen),
          ),
          const SizedBox(height: 16),
          Text(descripcion),
          const SizedBox(height: 12),
          const Text('Receta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(detalle, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}
