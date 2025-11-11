import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'navegation/mis_recetas.dart';
import 'navegation/cocteles.dart'; 
import '/api/api_service.dart'; 
import '/models/tragos_data.dart'; 

class Menu extends StatefulWidget {
  const Menu({super.key, required this.title});
  final String title;

  @override
  State<Menu> createState() => _MyMenuPageState();
}

class _MyMenuPageState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    var logger = Logger();
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
                      MaterialPageRoute(builder: (_) => const Cocteles()),
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
                      MaterialPageRoute(builder: (_) => const MisRecetas()),
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
                    "assets/tragos.png", // usa otra imagen si quieres
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
    );
  }
}

/// Pantalla ligera que pide 1 cóctel aleatorio y muestra el DetalleCoctel.
/// (Se deja en el mismo archivo por comodidad.)
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
        body: Center(
          child: Text("Error: $_error"),
        ),
      );
    }

    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Trago aleatorio")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Cuando ya tenemos el item, mostramos directamente la vista de detalle
    final it = _item!;
    return DetalleCoctel(
      nombre: it['nombre'],
      descripcion: it['descripcion'],
      detalle: it['detalle'],
      imagen: it['imagen'],
    );
  }
}
