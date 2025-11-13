// lib/pages/menu.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Alias para evitar conflictos con DetalleCoctel
import 'navegation/cocteles.dart' as coctel;
import 'navegation/mis_recetas.dart' as misrecetas;

import '/api/api_service.dart';
import '../preferences.dart'; // AppPrefs
import '../config.dart'; // <- NUEVO: pantalla de configuración

class Menu extends StatefulWidget {
  const Menu({super.key, required this.title});
  final String title;

  @override
  State<Menu> createState() => _MyMenuPageState();
}

class _MyMenuPageState extends State<Menu> {
  bool _onboardingChecked = false;

  @override
  void initState() {
    super.initState();
    _runOnboardingOnce();
  }

  Future<void> _runOnboardingOnce() async {
    if (_onboardingChecked) return;

    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    _onboardingChecked = true;

    if (done || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    bool hasKit = await AppPrefs.getHasBarKit();
    String difficulty = await AppPrefs.getDifficultyFilter();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: const Text('Configurar preferencias'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¿Tienes herramientas básicas de bar?',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Por ejemplo: coctelera, colador, cuchara y medidor.',
                      style: TextStyle(fontSize: 13),
                    ),
                    RadioListTile<bool>(
                      title: const Text('Sí, tengo kit de bar'),
                      value: true,
                      groupValue: hasKit,
                      onChanged: (v) => setLocal(() => hasKit = v ?? false),
                    ),
                    RadioListTile<bool>(
                      title: const Text('No tengo herramientas'),
                      value: false,
                      groupValue: hasKit,
                      onChanged: (v) => setLocal(() => hasKit = v ?? false),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nivel de dificultad de los tragos',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    RadioListTile<String>(
                      title: const Text('Solo fáciles'),
                      value: 'fácil',
                      groupValue: difficulty,
                      onChanged: (v) =>
                          setLocal(() => difficulty = v ?? 'fácil'),
                    ),
                    RadioListTile<String>(
                      title: const Text('Fáciles e intermedios'),
                      value: 'intermedio',
                      groupValue: difficulty,
                      onChanged: (v) =>
                          setLocal(() => difficulty = v ?? 'intermedio'),
                    ),
                    RadioListTile<String>(
                      title: const Text('Todos (incluye avanzados)'),
                      value: 'difícil',
                      groupValue: difficulty,
                      onChanged: (v) =>
                          setLocal(() => difficulty = v ?? 'difícil'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    await AppPrefs.setHasBarKit(hasKit);
                    await AppPrefs.setDifficultyFilter(difficulty);
                    await prefs.setBool('onboarding_done', true);
                    if (!mounted) return;
                    Navigator.pop(ctx);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    logger.d("Logger is working!");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(120, 0, 0, 0),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: "Acerca de",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: const Text('Acerca de BarMaster'),
                    content: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BarMaster v1.0.0",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text("Creado por: Sebastian Oñate\n"),
                          Text(
                            "Aplicación para explorar tragos, aprender recetas "
                            "y guardar tus favoritos.",
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Funciones principales:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "• Buscar y filtrar cócteles por licor base.\n"
                            "• Ver dificultad, ingredientes y preparación.\n"
                            "• Guardar tragos favoritos.\n"
                            "• Crear tus propias recetas con fotos.\n"
                            "• Modo entrenamiento para practicar el uso del shaker.\n"
                            "• Guía visual de vasos de coctelería.",
                          ),
                          SizedBox(height: 12),
                          Text(
                            "API utilizada: TheCocktailDB\n"
                            "Uso recomendado: personal / educativo",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Si estás participando en la validación de la app, "
                            "puedes responder el cuestionario de usabilidad "
                            "para enviar tus respuestas por correo.",
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cerrar'),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ValidacionPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.rate_review),
                        label: const Text('Encuesta de validación'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),

                  // 1) TRAGOS
                  SizedBox(
                    width: 400,
                    height: 100,
                    child: Image.asset(
                      "assets/allDrinks.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const coctel.Cocteles(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_bar),
                    label: const Text("Tragos"),
                  ),

                  const SizedBox(height: 24),

                  // 2) MIS RECETAS
                  SizedBox(
                    width: 400,
                    height: 100,
                    child: Image.asset(
                      "assets/Create.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const misrecetas.MisRecetas(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book),
                    label: const Text("Mis tragos"),
                  ),

                  const SizedBox(height: 24),

                  // 3) TRAGO ALEATORIO
                  SizedBox(
                    width: 400,
                    height: 100,
                    child: Image.asset(
                      "assets/tragos.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RandomTragoPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shuffle),
                    label: const Text("Trago aleatorio"),
                  ),

                  const SizedBox(height: 24),

                  // 4) CONFIGURACIÓN / PREFERENCIAS
                  SizedBox(
                    width: 400,
                    height: 100,
                    child: Icon(
                      Icons.settings,
                      size: 72,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text("Preferencias"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla que pide 1 cóctel aleatorio al API y muestra el DetalleCoctel
/// definido en cocteles.dart
class RandomTragoPage extends StatefulWidget {
  const RandomTragoPage({super.key});

  @override
  State<RandomTragoPage> createState() => _RandomTragoPageState();
}

class _RandomTragoPageState extends State<RandomTragoPage> {
  final _api = CocktailApi();
  Map<String, dynamic>? _item;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRandom();
  }

  Future<void> _loadRandom() async {
    try {
      final rnd = await _api.random();
      if (!mounted) return;
      setState(() => _item = rnd);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Trago aleatorio")),
        body: Center(child: Text("Error: $_error")),
      );
    }

    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Trago aleatorio")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final it = _item!;

    return coctel.DetalleCoctel(
      id: (it['id'] ?? '').toString(),
      nombre: it['nombre'],
      descripcion: it['descripcion'],
      detalle: it['detalle'],
      imagen: it['imagen'],
    );
  }
}

// ===============================
///  PANTALLA DE VALIDACIÓN (JSON + SLIDERS)
/// ===============================
class ValidacionPage extends StatefulWidget {
  const ValidacionPage({super.key});

  @override
  State<ValidacionPage> createState() => _ValidacionPageState();
}

class _ValidacionPageState extends State<ValidacionPage> {
  final String _destinoCorreo = 'seba.onate.morales@gmail.com';

  final _nombreCtrl = TextEditingController();
  final _comentCtrl = TextEditingController();

  List<Map<String, dynamic>> _preguntas = [];
  List<double> _valores = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _loadPreguntasDesdeJson();
  }

  Future<void> _loadPreguntasDesdeJson() async {
    try {
      // Lee el archivo: assets/validacion.json
      final raw = await rootBundle.loadString('assets/validacion.json');
      final jsonData = jsonDecode(raw) as Map<String, dynamic>;

      // Usa la clave "preguntas" tal como tu JSON
      final list = (jsonData['preguntas'] as List?) ?? [];

      final preguntas = list.map<Map<String, dynamic>>((e) {
        final m = e as Map<String, dynamic>;
        return {
          'titulo': m['titulo'] ?? '',
          'min': m['min'] ?? '',
          'max': m['max'] ?? '',
        };
      }).toList();

      setState(() {
        _preguntas = preguntas;
        _valores = List<double>.filled(_preguntas.length, 5);
        _cargando = false;
      });

      // Debug opcional:
      // print('Preguntas cargadas: ${_preguntas.length}');
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando cuestionario: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _comentCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarPorCorreo() async {
    final nombre =
        _nombreCtrl.text.trim().isEmpty ? 'No indica' : _nombreCtrl.text.trim();
    final comentario = _comentCtrl.text.trim().isEmpty
        ? 'Sin comentarios adicionales.'
        : _comentCtrl.text.trim();

    final body = StringBuffer()
      ..writeln('Cuestionario de usabilidad - BarMaster')
      ..writeln('======================================')
      ..writeln('Nombre: $nombre')
      ..writeln();

    for (int i = 0; i < _preguntas.length; i++) {
      final p = _preguntas[i];
      body.writeln(
        '${i + 1}) ${p['titulo']} => ${_valores[i].round()} / 5',
      );
    }

    body
      ..writeln()
      ..writeln('Comentario adicional:')
      ..writeln(comentario)
      ..writeln()
      ..writeln('Gracias por tu tiempo');

    final uri = Uri(
      scheme: 'mailto',
      path: _destinoCorreo,
      query: {
        'subject': 'Cuestionario de usabilidad - BarMaster',
        'body': body.toString(),
      }.entries.map((e) {
        return '${Uri.encodeQueryComponent(e.key)}='
            '${Uri.encodeQueryComponent(e.value)}';
      }).join('&'),
    );

    if (!await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la app de correo.')),
      );
    }
  }

  Widget _sliderPregunta(int index) {
    final p = _preguntas[index];
    final valor = _valores[index].round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${p['titulo']}: $valor'),
        Slider(
          value: _valores[index],
          min: 0,
          max: 5,
          divisions: 5,
          label: '$valor',
          onChanged: (v) {
            setState(() {
              _valores[index] = v;
            });
          },
        ),
        if ((p['min'] as String).isNotEmpty ||
            (p['max'] as String).isNotEmpty) ...[
          Text(
            p['min'] as String,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            p['max'] as String,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cuestionario'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuestionario'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Nombre (opcional)'),
          const SizedBox(height: 4),
          TextField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          for (int i = 0; i < _preguntas.length; i++) _sliderPregunta(i),

          const SizedBox(height: 16),
          const Text('Comentario adicional (opcional)'),
          const SizedBox(height: 4),
          TextField(
            controller: _comentCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText:
                  'Escribe aquí cualquier comentario, sugerencia o problema que encontraste.',
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _enviarPorCorreo,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Guardar y enviar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}