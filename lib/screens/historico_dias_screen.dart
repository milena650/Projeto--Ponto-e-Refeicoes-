import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/fechamento_model.dart';
import 'resumo_refeicoes__screen.dart'; // Ou abrir diretamente a visualização do dia

class HistoricoDiasScreen extends StatelessWidget {
  final String nomeObra;

  const HistoricoDiasScreen({super.key, required this.nomeObra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Fechamentos - $nomeObra'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Busca todos os fechamentos desta obra ordenados por data decrescente
        stream: FirebaseFirestore.instance
            .collection('fechamentos_diarios')
            .where('obra', isEqualTo: nomeObra)
            .orderBy('data', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum histórico diário encontrado para esta obra.'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final dataMap = docs[index].data() as Map<String, dynamic>;
              final String dataFormatada = dataMap['data'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    'Data: $dataFormatada',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Aqui abre a janela/ecrã com a fotografia exata do dia selecionado (Terceira Imagem)
                    // Pode passar o objeto FechamentoDiario.fromMap para a tela de visualização
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}