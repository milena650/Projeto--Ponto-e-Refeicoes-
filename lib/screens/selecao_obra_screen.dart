import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obra_provider.dart';
import 'resumo_refeicoes__screen.dart';

class SelecaoObraScreen extends StatelessWidget {
  const SelecaoObraScreen({super.key});

  final List<String> obras = const [
    'Guaporé ',
    'Presidente Médici ',
    'Serro',
    'Sítio',
    'Vicência ',
    'Ipojuca ',
    'Porto Velho ',
    'Paracambi',
    'Mercúrio',
    'Bagé ',
    'Terceirizados',
    'Rolim de Moura ',
    'Escritório',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solário - Selecionar Obra'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: obras.length,
        itemBuilder: (context, index) {
          final nomeObra = obras[index];
          return Card(
            child: ListTile(
              title: Text(nomeObra, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 1. Atualiza a obra e chama a API
                context.read<ObraProvider>().selecionarObra(nomeObra);

                // 2. Abre a tela de Resumo de Refeições
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResumoRefeicoesScreen()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}