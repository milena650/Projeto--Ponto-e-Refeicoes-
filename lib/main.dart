import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/obra_provider.dart';
import 'screens/selecao_obra_screen.dart';
import 'screens/resumo_refeicoes__screen.dart';
import 'screens/lista_funcionarios_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importa o arquivo gerado pelo flutterfire

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialização correta usando o firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const SolarioApp());
}

class SolarioApp extends StatelessWidget {
  const SolarioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ObraProvider()),
      ],
      child: MaterialApp(
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
          '/funcionarios': (context) => const ListaFuncionariosScreen(),
        },
      ),
    );
  }
}