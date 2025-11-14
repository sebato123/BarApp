import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';


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
