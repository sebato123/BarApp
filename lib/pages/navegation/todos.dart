import 'package:flutter/material.dart';

class Todos extends StatelessWidget {
  const Todos({super.key});

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
        "descripcion": "Cocacola con pisco, servido con hielo.",
        
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Lista de tragos")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final it = items[i];
          return InkWell(
            onTap: () {
              // Acción al clickear (para maqueta solo mostramos un snackbar)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Abriste ${it["nombre"]}")),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Imagen cuadrada
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      /*
                      child: Image.asset(
                        it["imagen"]!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                      */
                    ),
                    const SizedBox(width: 12),
                    // Texto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it["nombre"]!,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            it["descripcion"]!,
                            style: const TextStyle(color: Colors.black54),
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