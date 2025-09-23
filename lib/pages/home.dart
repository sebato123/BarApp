import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'menu.dart';



class Home extends StatefulWidget {
  const Home({super.key, required this.title});
  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    logger.d("Home cargado");

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
                // Imagen
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "assets/home.png",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                // Texto
                const Text(
                  "Bienvenido a BarApp\nExplora cócteles, destilados y crea tus propias recetas.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Botón: Ir al menú
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Menu(title: "Menú"),
                        ),
                      );
                    },
                    label: const Text("Ir al menú"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

