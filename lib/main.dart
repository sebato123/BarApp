import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/splash_screen.dart';
import 'pages/tema/theme.dart';
import 'pages/tema/util.dart';
import 'config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Detectar tema del sistema
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    // 2. Crear el textTheme con las fuentes que elegiste en ThemeBuilder
    final TextTheme textTheme =
        createTextTheme(context, "AR One Sans", "Merriweather");

    // 3. Crear el tema generado
    final MaterialTheme materialTheme = MaterialTheme(textTheme);

    // 4. Elegir base según claro/oscuro
    final ThemeData baseTheme =
        brightness == Brightness.light ? materialTheme.light() : materialTheme.dark();

    // 5. Armar el MaterialApp
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      // partimos del tema generado y le metemos tus ajustes
      theme: baseTheme.copyWith(
        useMaterial3: true,
        // si quieres forzar un colorScheme desde un seed, lo haces SOBRE el base
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
          brightness: brightness,
        ),
        // aquí sobreescribes SOLO lo que quieres
        textTheme: baseTheme.textTheme.copyWith(
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
       home: const SplashPage(),
  routes: {
    '/settings': (_) => const SettingsPage(), 
  }
    );
  }
}