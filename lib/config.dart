import 'package:flutter/material.dart';
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
          title: const Text('Configuración', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
            
          ],
        ),
      ),
    );
  }
}
