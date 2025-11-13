// lib/settings_page.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool hasBarKit = false;
  String selectedDifficulty = 'difícil'; // valor por defecto
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await AppPrefs.getHasBarKit();
    final dif = await AppPrefs.getDifficultyFilter();
    setState(() {
      hasBarKit = v;
      selectedDifficulty = dif;
      loading = false;
    });
  }

  Future<void> _toggleBarKit(bool v) async {
    setState(() => hasBarKit = v);
    await AppPrefs.setHasBarKit(v);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            v
                ? 'Preferencia guardada: tienes kit de bartender'
                : 'Preferencia guardada: sin kit de bartender',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _changeDifficulty(String? value) async {
    if (value == null) return;
    setState(() => selectedDifficulty = value);
    await AppPrefs.setDifficultyFilter(value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dificultad preferida: $value guardada'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración',
              style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preferencia kit de bar
            SwitchListTile(
              title: const Text(
                'Tengo kit de bartender',
                style: TextStyle(color: Colors.black87),
              ),
              subtitle: const Text(
                'Coctelera, colador, vaso mezclador, jigger/medidor, etc.',
                style: TextStyle(color: Colors.black54),
              ),
              value: hasBarKit,
              activeColor: Colors.black,
              onChanged: _toggleBarKit,
            ),
            const SizedBox(height: 16),
            const Text(
              'Si no tienes kit, verás primero tragos simples que no requieren herramientas.',
              style: TextStyle(
                height: 1.3,
                color: Colors.black87,
              ),
            ),
            const Divider(),

            // Dificultad
            const Text(
              'Nivel de dificultad máximo a mostrar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedDifficulty,
              isExpanded: true,
              dropdownColor: Colors.white,
              iconEnabledColor: Colors.black87,
              style: const TextStyle(color: Colors.black87),
              items: const [
                DropdownMenuItem(
                  value: 'fácil',
                  child: Text('Fácil — solo tragos sencillos'),
                ),
                DropdownMenuItem(
                  value: 'intermedio',
                  child: Text('Intermedio — intermedios y fáciles'),
                ),
                DropdownMenuItem(
                  value: 'difícil',
                  child: Text('Difícil — ver todos los tragos'),
                ),
              ],
              onChanged: _changeDifficulty,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),

            const Text(
              'Extras',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Botón a modo entrenamiento
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.black87),
              title: const Text('Modo entrenamiento (shaker)'),
              subtitle: const Text(
                'Usa el teléfono como si fuera una coctelera para practicar el movimiento.',
                style: TextStyle(color: Colors.black54),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TrainingModePage(),
                  ),
                );
              },
            ),

            // Botón a guía de vasos
            ListTile(
              leading: const Icon(Icons.local_drink, color: Colors.black87),
              title: const Text('Guía de vasos'),
              subtitle: const Text(
                'Aprende qué es un vaso highball, chupito, copa de cóctel, etc.',
                style: TextStyle(color: Colors.black54),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GlassGuidePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// MODO ENTRENAMIENTO (SHAKER)
/// ===============================
class TrainingModePage extends StatefulWidget {
  const TrainingModePage({super.key});

  @override
  State<TrainingModePage> createState() => _TrainingModePageState();
}

class _TrainingModePageState extends State<TrainingModePage> {
  StreamSubscription<AccelerometerEvent>? _sub;
  bool _entrenando = false;
  int _shakes = 0;
  int _metaShakes = 20; // ~10–15 segundos de agite
  double _ultimaFuerza = 0;
  DateTime _ultimoShakeTime = DateTime.now();
  double _fuerzaActual = 0;

  void _startEntrenamiento() {
    if (_entrenando) return;

    setState(() {
      _entrenando = true;
      _shakes = 0;
      _fuerzaActual = 0;
    });

    _sub?.cancel();
    _sub = accelerometerEvents.listen(_onAccel);
  }

  void _stopEntrenamiento() {
    _sub?.cancel();
    _sub = null;
    setState(() {
      _entrenando = false;
    });
  }

  void _onAccel(AccelerometerEvent event) {
    final fuerza =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    const umbralShake = 15.0;
    final ahora = DateTime.now();

    setState(() {
      _fuerzaActual = fuerza;
    });

    if (fuerza > umbralShake) {
      if (ahora.difference(_ultimoShakeTime).inMilliseconds > 200) {
        _ultimoShakeTime = ahora;
        setState(() {
          _shakes++;
        });

        if (_shakes >= _metaShakes) {
          _stopEntrenamiento();
          _mostrarDialogoExito();
        }
      }
    }

    _ultimaFuerza = fuerza;
  }

  void _mostrarDialogoExito() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('¡Buen trabajo!'),
          content: const Text(
            'Completaste el entrenamiento del shaker.\n\n'
            'Ya tienes una buena idea de cómo agitar vigorosamente '
            'durante 10 a 15 segundos para enfriar y mezclar el cóctel.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progreso = _metaShakes == 0 ? 0.0 : _shakes / _metaShakes;
    final porcentaje = (progreso * 100).clamp(0, 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo entrenamiento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Entrenamiento con coctelera (shaker)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Sujeta el teléfono como si fuera una coctelera y agita '
              'con movimientos rápidos y cortos.\n\n'
              'Objetivo: alcanzar la cantidad de “shakes” necesaria para '
              'simular 10–15 segundos de agitado.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 160,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: progreso,
                        strokeWidth: 10,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$porcentaje%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Shakes: $_shakes / $_metaShakes'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Fuerza actual: ${_fuerzaActual.toStringAsFixed(1)} m/s²',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _entrenando ? null : _startEntrenamiento,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _entrenando ? _stopEntrenamiento : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Detener'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Tip:\nNo llenes la coctelera hasta el tope, deja espacio para que '
              'el hielo se mueva. Practica primero con agua para no desperdiciar licor.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// GUÍA DE VASOS
/// ===============================
class GlassGuidePage extends StatelessWidget {
  const GlassGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    const glasses = [
      {
        'emoji': '🥛',
        'title': 'Vaso chupito / shot',
        'desc':
            'Vasito pequeño para tragos cortos de un solo sorbo, como tequila o shots de licores.',
      },
      {
        'emoji': '🍸',
        'title': 'Copa de cóctel / Martini',
        'desc':
            'Copa en forma de cono invertido. Se usa para cócteles sin hielo servidos “straight up”, como el Martini o Cosmopolitan.',
      },
      {
        'emoji': '🥃',
        'title': 'Vaso old fashioned',
        'desc':
            'Vaso corto y ancho. Ideal para tragos con poco mixer y grandes cubos de hielo, como el Negroni o el Old Fashioned.',
      },
      {
        'emoji': '🥂',
        'title': 'Copa flauta',
        'desc':
            'Copa alta y delgada usada para espumantes y cocktails con champagne.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipos de vasos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: glasses.length,
        itemBuilder: (context, index) {
          final g = glasses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        Colors.brown.shade800.withOpacity(0.15),
                    child: Text(
                      g['emoji']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g['desc']!,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
