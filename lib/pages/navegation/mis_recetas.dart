import 'package:flutter/material.dart';

class MisRecetas extends StatefulWidget {
  const MisRecetas({super.key});

  @override
  State<MisRecetas> createState() => _MisRecetasState();
}

class _MisRecetasState extends State<MisRecetas> {
  List<Map<String, String>> items = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis recetas"),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final nuevaReceta = await Navigator.push<Map<String, String>>(
                context,
                MaterialPageRoute(
                  builder: (_) => const AgregarRecetaPage(),
                ),
              );

              if (nuevaReceta != null) {
                setState(() {
                  items.add(nuevaReceta);
                });
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Agregar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final it = items[i];
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


class AgregarRecetaPage extends StatefulWidget {
  const AgregarRecetaPage({super.key});

  @override
  State<AgregarRecetaPage> createState() => _AgregarRecetaPageState();
}

class _AgregarRecetaPageState extends State<AgregarRecetaPage> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final detalleController = TextEditingController();
  final imagenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar receta")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: "Descripción"),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: detalleController,
                decoration: const InputDecoration(labelText: "Detalle (ingredientes y pasos)"),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: imagenController,
                decoration: const InputDecoration(labelText: "Ruta de imagen (asset)"),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      "nombre": nombreController.text,
                      "descripcion": descripcionController.text,
                      "detalle": detalleController.text,
                      "imagen": imagenController.text,
                    });
                  }
                },
                child: const Text("Guardar receta"),
              )
            ],
          ),
        ),
      ),
    );
  }
}