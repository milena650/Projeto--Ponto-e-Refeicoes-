import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/funcionario_model.dart';
import 'obra_equipe_service.dart';

class PontomaisService {
  // Já não precisamos de _baseUrl nem de _token aqui no Flutter,
  // pois a segurança e o pedido à API são feitos pelo script Node.js no backend.

  /// Busca a lista de todas as equipas ativas armazenadas no Firestore
  static Future<List<String>> obterTodasEquipes() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('funcionarios_ponto').get();
      Set<String> equipes = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final equipe = data['team'] ?? data['equipe'];
        if (equipe != null) {
          if (equipe is Map && equipe['name'] != null) {
            equipes.add(equipe['name'].toString().trim());
          } else if (equipe is String) {
            equipes.add(equipe.toString().trim());
          }
        }
      }

      // Se não encontrar nenhuma equipa específica, retorna um padrão
      if (equipes.isEmpty) {
        equipes.add('Geral');
      }

      List<String> listaOrdenada = equipes.toList()..sort();
      return listaOrdenada;
    } catch (e) {
      debugPrint('[PontomaisService] Erro ao carregar equipes do Firestore: $e');
      return [];
    }
  }

  /// Busca todos os colaboradores da obra diretamente do Firestore
  static Future<List<Funcionario>> buscarMarcacoesPorObra(String idObra, String dataFormatada) async {
    try {
      // 1. Busca as equipas associadas a esta obra no Firestore
      List<String> equipesPermitidas = await ObraEquipeService.obterEquipesDaObra(idObra);

      // 2. Busca todos os funcionários sincronizados na coleção do Firestore
      final snapshot = await FirebaseFirestore.instance.collection('funcionarios_ponto').get();
      
      List<Funcionario> lista = [];

      for (var doc in snapshot.docs) {
        final emp = doc.data();
        String nomeEmp = emp['name']?.toString() ?? emp['nome']?.toString() ?? 'Colaborador';
        String matEmp = emp['registration_number']?.toString() ?? doc.id;

        // Extração da equipa
        String equipeName = 'Geral';
        var rawTeam = emp['team'] ?? emp['equipe'];
        if (rawTeam is Map) {
          equipeName = rawTeam['name']?.toString().trim() ?? 'Geral';
        } else if (rawTeam != null) {
          equipeName = rawTeam.toString().trim();
        }

        // Filtra apenas se a equipa pertence à obra selecionada (ou se não houver restrição rigorosa)
        if (equipesPermitidas.isEmpty || equipesPermitidas.contains(equipeName)) {
          lista.add(Funcionario(
            idFuncionario: matEmp,
            nomeCompleto: nomeEmp,
            idObra: idObra,
            equipe: equipeName,
            horarioEntrada: null, // Preenchido futuramente se houver registo de ponto
            horarioSaidaIntervalo: null,
            horarioRetornoIntervalo: null,
            horarioSaida: null,
          ));
        }
      }

      debugPrint('Total de funcionários mapeados para a obra $idObra via Firestore: ${lista.length}');
      return lista;
    } catch (e) {
      debugPrint('Erro detalhado ao buscar marcações do Firestore: $e');
      rethrow;
    }
  }
}