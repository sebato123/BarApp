// lib/pages/menu.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
// Alias para evitar conflictos con DetalleCoctel
import 'navegation/cocteles.dart' as coctel;
import 'navegation/mis_recetas.dart' as misrecetas;

import '/api/api_service.dart';

class Menu extends StatefulWidget {
  const Menu({super.key, required this.title});
  final String title;

  @override
  State<Menu> createState() => _MyMenuPageState();
}

class _MyMenuPageState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    logger.d("Logger is working!");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(120, 0, 0, 0),
        title: Text(widget.title),
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

                  // ======================
                  // 1) TRAGOS (catálogo)
                  // ======================
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
                        MaterialPageRoute(builder: (_) => const coctel.Cocteles()),
                      );
                    },
                    icon: const Icon(Icons.local_bar),
                    label: const Text("Tragos"),
                  ),

                  const SizedBox(height: 24),

                  // ======================
                  // 2) MIS RECETAS
                  // ======================
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
                        MaterialPageRoute(builder: (_) => const misrecetas.MisRecetas()),
                      );
                    },
                    icon: const Icon(Icons.menu_book),
                    label: const Text("Mis recetas"),
                  ),

                  const SizedBox(height: 24),

                  // ======================
                  // 3) TRAGO ALEATORIO
                  // ======================
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
                        MaterialPageRoute(builder: (_) => const RandomTragoPage()),
                      );
                    },
                    icon: const Icon(Icons.shuffle),
                    label: const Text("Trago aleatorio"),
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

/// Pantalla que pide 1 cóctel aleatorio y muestra el DetalleCoctel (definido en cocteles.dart).
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
    // Usamos el DetalleCoctel de cocteles.dart con alias para evitar ambigüedad
    return coctel.DetalleCoctel(
      nombre: it['nombre'],
      descripcion: it['descripcion'],
      detalle: it['detalle'],
      imagen: it['imagen'],
    );
  }
}
