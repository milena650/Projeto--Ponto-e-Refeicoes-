import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/obra_provider.dart';
import 'screens/selecao_obra_screen.dart';
import 'screens/resumo_refeicoes__screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: r"$2a$12$StZeJvb79qMce/0Yb6dj4.fG7du7GBgbY4vBoPKOycT3BN9DGbIgK",
      authDomain: "ponto-refeicoes-app.firebaseapp.com",
      projectId: "ponto-refeicoes-app",
      storageBucket: "ponto-refeicoes-app.appspot.com",
      messagingSenderId: "75782128441",
      appId: "1:75782128441:web:378fd3f81c4a4483545ee8",
    ),
  );

  runApp(const SolarioApp());
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