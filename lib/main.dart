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

    final brightness = View.of(context).platformDispatcher.platformBrightness;

    final TextTheme textTheme =
        createTextTheme(context, "AR One Sans", "Merriweather");

    final MaterialTheme materialTheme = MaterialTheme(textTheme);

    // Elegir base según claro/oscuro
    final ThemeData baseTheme =
        brightness == Brightness.light ? materialTheme.light() : materialTheme.dark();

    return MaterialApp(
      title: 'BarAPP',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
          brightness: brightness,
        ),
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