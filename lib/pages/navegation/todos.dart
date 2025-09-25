import 'package:flutter/material.dart';

class Todos extends StatefulWidget {
  const Todos({super.key});

  @override
  State<Todos> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  final List<Map<String, String>> items = [
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
    },
  ];

  String searchQuery = '';
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) {
      final name = item['nombre']!.toLowerCase();
      final desc = item['descripcion']!.toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || desc.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar cóctel...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              )
            : const Text("Todos los tragos"),
        actions: [
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
      body: ListView.separated(
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
                    nombre: it["nombre"]!,
                    descripcion: it["descripcion"]!,
                    detalle: it["detalle"]!,
                    imagen: it["imagen"]!,
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
                        it["imagen"]!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it["nombre"]!,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 219, 223, 14),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            it["descripcion"]!,
                            style: const TextStyle(color: Colors.white),
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
              border: Border.all(
                width: 8,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
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