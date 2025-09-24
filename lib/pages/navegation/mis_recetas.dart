import 'package:flutter/material.dart';

class MisRecetas extends StatelessWidget {
  const MisRecetas({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        "nombre": "Margarita",
        "descripcion": "Cóctel fresco con tequila, triple sec y lima.",
      },
      {
        "nombre": "Negroni",
        "descripcion": "Clásico italiano con gin, Campari y vermut.",
      },
      {
        "nombre": "Piscola",
        "descripcion": "Coca-Cola con pisco, servido con hielo.",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis recetas"),
        actions: [
          TextButton.icon(
            onPressed: () {
              null;
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Agregar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      // Lista
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final it = items[i];
          return InkWell(
            onTap: () {
              null;
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Lugar para imagen 
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      /*
                      child: Container(
                        width: 64,
                        height: 64,
                        color: const Color.fromARGB(31, 248, 248, 248),
                        alignment: Alignment.center,
                        child: const Icon(Icons.local_drink, color: Color.fromARGB(255, 247, 247, 247)),
                      ),
                      */
                    ),
                    const SizedBox(width: 12),
                    // Texto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it["nombre"]!,
                            style: const TextStyle(color: Color.fromARGB(255, 219, 223, 14), fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            it["descripcion"]!,
                            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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