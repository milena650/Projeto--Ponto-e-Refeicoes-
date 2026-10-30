import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Definimos um atalho de tipo para evitar colapsos com caracteres complexos
typedef MapaObrasEquipes = Map<String, List<String>>;

class ObraEquipeService {
  static const String _storageKey = 'mapeamento_obras_equipes';

  // Salva as equipes selecionadas para uma determinada obra
  static Future<void> salvarEquipesDaObra(String nomeObra, List<String> equipesSelecionadas) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final MapaObrasEquipes mapaAtual = await obterTodosVinculos();
      
      mapaAtual[nomeObra] = equipesSelecionadas;
      
      final jsonString = jsonEncode(mapaAtual);
      await prefs.setString(_storageKey, jsonString);
      debugPrint('[ObraEquipeService] Sucesso ao salvar equipas para a obra: $nomeObra');
    } catch (e, stackTrace) {
      debugPrint('[ObraEquipeService] ERRO ao salvar equipas: $e');
      debugPrint('[ObraEquipeService] StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Retorna o mapa completo usando o typedef limpo
  static Future<MapaObrasEquipes> obterTodosVinculos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? dadosJson = prefs.getString(_storageKey);
      
      if (dadosJson == null || dadosJson.isEmpty) {
        return {};
      }
      
      final decoded = jsonDecode(dadosJson);
      if (decoded is! Map) {
        debugPrint('[ObraEquipeService] AVISO: Dados salvos não são um Map válido.');
        return {};
      }

      MapaObrasEquipes mapaResultado = {};
      decoded.forEach((key, value) {
        if (value is List) {
          mapaResultado[key.toString()] = value.map((e) => e.toString()).toList();
        }
      });

      return mapaResultado;
    } catch (e, stackTrace) {
      debugPrint('[ObraEquipeService] ERRO ao obter vínculos: $e');
      debugPrint('[ObraEquipeService] StackTrace: $stackTrace');
      return {};
    }
  }

  // Retorna apenas as equipes vinculadas a uma obra específica
  static Future<List<String>> obterEquipesDaObra(String nomeObra) async {
    try {
      final MapaObrasEquipes vinculos = await obterTodosVinculos();
      return vinculos[nomeObra] ?? [];
    } catch (e) {
      debugPrint('[ObraEquipeService] ERRO ao obter equipas da obra $nomeObra: $e');
      return [];
    }
  }
}