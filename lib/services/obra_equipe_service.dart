import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Definimos um atalho de tipo para manter a compatibilidade com o resto do projeto
typedef MapaObrasEquipes = Map<String, List<String>>;

class ObraEquipeService {
  // Referência para a coleção no Firestore
  static final CollectionReference _colecaoObras =
      FirebaseFirestore.instance.collection('obras_equipes');

  // Salva as equipes selecionadas para uma determinada obra no Firestore
  static Future<void> salvarEquipesDaObra(String nomeObra, List<String> equipesSelecionadas) async {
    try {
      // Usamos o nome da obra como ID do documento (ou tratamos caracteres especiais se necessário)
      // Para segurança com IDs de documentos, podemos usar o nome diretamente ou normalizado.
      await _colecaoObras.doc(nomeObra).set({
        'equipes': equipesSelecionadas,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      
      debugPrint('[ObraEquipeService] Sucesso ao salvar equipas no Firestore para a obra: $nomeObra');
    } catch (e, stackTrace) {
      debugPrint('[ObraEquipeService] ERRO ao salvar equipas no Firestore: $e');
      debugPrint('[ObraEquipeService] StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Retorna o mapa completo de todas as obras e equipas a partir do Firestore
  static Future<MapaObrasEquipes> obterTodosVinculos() async {
    try {
      final QuerySnapshot snapshot = await _colecaoObras.get();
      MapaObrasEquipes mapaResultado = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['equipes'] is List) {
          final nomeObra = doc.id;
          final equipes = (data['equipes'] as List).map((e) => e.toString()).toList();
          mapaResultado[nomeObra] = equipes;
        }
      }

      return mapaResultado;
    } catch (e, stackTrace) {
      debugPrint('[ObraEquipeService] ERRO ao obter vínculos do Firestore: $e');
      debugPrint('[ObraEquipeService] StackTrace: $stackTrace');
      return {};
    }
  }

  // Retorna apenas as equipes vinculadas a uma obra específica diretamente do documento
  static Future<List<String>> obterEquipesDaObra(String nomeObra) async {
    try {
      final DocumentSnapshot doc = await _colecaoObras.doc(nomeObra).get();
      
      if (!doc.exists) {
        return [];
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data['equipes'] is List) {
        return (data['equipes'] as List).map((e) => e.toString()).toList();
      }

      return [];
    } catch (e) {
      debugPrint('[ObraEquipeService] ERRO ao obter equipas da obra $nomeObra do Firestore: $e');
      return [];
    }
  }
}