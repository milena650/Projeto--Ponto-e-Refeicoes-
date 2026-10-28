import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/obra_provider.dart';
import 'screens/selecao_obra_screen.dart';
import 'screens/resumo_refeicoes__screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ObraProvider()),
      ],
      child: const SolarioApp(),
    ),
  );
}

class SolarioApp extends StatelessWidget {
  const SolarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solário - Automação de Refeições',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SelecaoObraScreen(),
        '/resumo_refeicoes': (context) => const ResumoRefeicoesScreen(),
      },
    );
  }
}