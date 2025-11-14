import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';


/// ===============================
/// GUÍA DE VASOS
/// ===============================
class GlassGuidePage extends StatelessWidget {
  const GlassGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    const glasses = [
      {
        'emoji': '🥛',
        'title': 'Vaso chupito / shot',
        'desc':
            'Vasito pequeño para tragos cortos de un solo sorbo, como tequila o shots de licores.',
      },
      {
        'emoji': '🍸',
        'title': 'Copa de cóctel / Martini',
        'desc':
            'Copa en forma de cono invertido. Se usa para cócteles sin hielo servidos “straight up”, como el Martini o Cosmopolitan.',
      },
      {
        'emoji': '🥃',
        'title': 'Vaso old fashioned',
        'desc':
            'Vaso corto y ancho. Ideal para tragos con poco mixer y grandes cubos de hielo, como el Negroni o el Old Fashioned.',
      },
      {
        'emoji': '🥂',
        'title': 'Copa flauta',
        'desc':
            'Copa alta y delgada usada para espumantes y cocktails con champagne.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipos de vasos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: glasses.length,
        itemBuilder: (context, index) {
          final g = glasses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        Colors.brown.shade800.withOpacity(0.15),
                    child: Text(
                      g['emoji']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g['desc']!,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
