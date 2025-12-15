import 'package:flutter/material.dart';

import 'viagens/relatorio_viagens_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

    return MaterialApp(
      title: 'Relatório de viagens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: baseScheme.copyWith(tertiary: Colors.amber)),
      home: const RelatorioViagensPage(),
    );
  }
}
