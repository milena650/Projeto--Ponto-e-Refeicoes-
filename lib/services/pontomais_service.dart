import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/funcionario_model.dart';
import 'obra_equipe_service.dart';

class PontomaisService {
  // Nota: Os pedidos HTTP diretos à PontoMais foram removidos do frontend
  // para evitar erros de CORS no Netlify. Os dados são lidos do Firestore.

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

        // Se quiser que traga todas as equipas (removendo a restrição), 
        // ou filtrando pelas permitidas da obra:
        if (equipesPermitidas.isEmpty || equipesPermitidas.contains(equipeName)) {
          lista.add(Funcionario(
            idFuncionario: matEmp,
            nomeCompleto: nomeEmp,
            idObra: idObra,
            equipe: equipeName,
            horarioEntrada: emp['horarioEntrada'],
            horarioSaidaIntervalo: emp['horarioSaidaIntervalo'],
            horarioRetornoIntervalo: emp['horarioRetornoIntervalo'],
            horarioSaida: emp['horarioSaida'],
          ));
        }
      }

      debugPrint('Total de funcionários carregados para a obra $idObra via Firestore: ${lista.length}');
      return lista;
    } catch (e) {
      debugPrint('Erro detalhado ao buscar marcações do Firestore: $e');
      rethrow;
    }
  }
}