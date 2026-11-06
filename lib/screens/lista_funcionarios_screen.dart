import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaFuncionariosScreen extends StatelessWidget {
  const ListaFuncionariosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionários - PontoMais'),
        backgroundColor: Colors.blueAccent,
      ),
      // O StreamBuilder escuta em tempo real a coleção 'funcionarios_ponto' no Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('funcionarios_ponto').snapshots(),
        builder: (context, snapshot) {
          // Se houver um erro na ligação
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os dados.'));
          }

          // Enquanto os dados estão a ser descarregados
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se a coleção estiver vazia
          final documentos = snapshot.data?.docs ?? [];
          if (documentos.isEmpty) {
            return const Center(child: Text('Nenhum funcionário encontrado.'));
          }

          // Exibe a lista de funcionários num ListView
          return ListView.builder(
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              final dadosFuncionario = documentos[index].data() as Map<String, dynamic>;
              
              // Ajuste os campos conforme as propriedades retornadas pela API do PontoMais
              // (Exemplo: name, first_name, email, registration_number, etc.)
              final nome = dadosFuncionario['name'] ?? dadosFuncionario['first_name'] ?? 'Nome não disponível';
              final matricula = dadosFuncionario['registration_number'] ?? 'Sem matrícula';
              final email = dadosFuncionario['email'] ?? 'Sem e-mail';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(nome.isNotEmpty ? nome[0].toUpperCase() : '?'),
                  ),
                  title: Text(
                    nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Matrícula: $matricula\nE-mail: $email'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}