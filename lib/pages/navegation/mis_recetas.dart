import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MisRecetas extends StatefulWidget {
  const MisRecetas({super.key});

  @override
  State<MisRecetas> createState() => _MisRecetasState();
}

class _MisRecetasState extends State<MisRecetas> {
  List<Map<String, String>> items = [];

  @override
  void initState() {
    super.initState();
    _loadRecetas();
  }

  Future<void> _loadRecetas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('mis_recetas');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      setState(() {
        items = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
    }
  }

  Future<void> _saveRecetas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mis_recetas', jsonEncode(items));
  }

  Future<void> _agregar() async {
    final nueva = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const EditarRecetaPage()),
    );
    if (nueva != null) {
      setState(() {
        items.add(nueva);
      });
      await _saveRecetas();
    }
  }

  Future<void> _editar(int index) async {
    final receta = items[index];
    final editada = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarRecetaPage(
          initial: receta,
          title: 'Editar receta',
        ),
      ),
    );
    if (editada != null) {
      setState(() {
        items[index] = editada;
      });
      await _saveRecetas();
    }
  }

  Future<void> _eliminar(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar receta'),
        content: Text('¿Seguro quieres eliminar "${items[index]['nombre']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        items.removeAt(index);
      });
      await _saveRecetas();
    }
  }

  Widget _thumb(String path) {
    if (path.startsWith('/')) {
      return Image.file(File(path), width: 64, height: 64, fit: BoxFit.cover);
    }
    return const Icon(Icons.photo, size: 40, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis recetas"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregar,
        icon: const Icon(Icons.add),
        label: const Text('Agregar receta'),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                "Aún no tienes recetas.\nToca el botón + para agregar una.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final it = items[i];
                return Dismissible(
                  key: ValueKey('${it['nombre']}_${it['imagen']}_$i'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    await _eliminar(i);
                    return false;
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetalleCoctelLocal(
                              nombre: it["nombre"]!,
                              descripcion: it["descripcion"]!,
                              detalle: it["detalle"]!,
                              imagen: it["imagen"]!,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _thumb(it["imagen"]!),
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
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _editar(i);
                                if (value == 'delete') _eliminar(i);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Editar')),
                                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                              ],
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class DetalleCoctelLocal extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String detalle;
  final String imagen;

  const DetalleCoctelLocal({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.detalle,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(imagen);
    return Scaffold(
      appBar: AppBar(
        title: Text(nombre, style: const TextStyle(color: Color.fromARGB(255, 219, 223, 14))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 8, color: Colors.black),
              ),
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover)
                  : const Icon(Icons.broken_image, size: 100),
            ),
          ),
          const SizedBox(height: 16),
          Text(descripcion, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          const Text(
            "Preparación",
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

class EditarRecetaPage extends StatefulWidget {
  const EditarRecetaPage({super.key, this.initial, this.title = 'Agregar receta'});

  final Map<String, String>? initial;
  final String title;

  @override
  State<EditarRecetaPage> createState() => _EditarRecetaPageState();
}

class _EditarRecetaPageState extends State<EditarRecetaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nombreController;
  late final TextEditingController descripcionController;
  late final TextEditingController detalleController;
  String? imagenPath;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.initial?['nombre'] ?? '');
    descripcionController = TextEditingController(text: widget.initial?['descripcion'] ?? '');
    detalleController = TextEditingController(text: widget.initial?['detalle'] ?? '');
    imagenPath = widget.initial?['imagen'];
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => imagenPath = picked.path);
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate() && imagenPath != null) {
      Navigator.pop(context, {
        "nombre": nombreController.text.trim(),
        "descripcion": descripcionController.text.trim(),
        "detalle": detalleController.text.trim(),
        "imagen": imagenPath!,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor selecciona una imagen.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imagenPath != null && File(imagenPath!).existsSync();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: "Descripción"),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: detalleController,
                decoration: const InputDecoration(
                  labelText: "Detalle (ingredientes y pasos)",
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    if (hasImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(imagenPath!), width: 160, height: 160, fit: BoxFit.cover),
                      )
                    else
                      Container(
                        width: 160,
                        height: 160,
                        color: Colors.black26,
                        child: const Icon(Icons.photo_camera, size: 60, color: Colors.white70),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Cámara"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image),
                          label: const Text("Galería"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
