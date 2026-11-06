import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/funcionario_model.dart';
import 'obra_equipe_service.dart';

class PontomaisService {
  static const String _baseUrl = 'https://api.pontomais.com.br/external_api/v1';
  static const String _token = r'$2a$12$StZeJvb79qMce/0Yb6dj4.fG7du7GBgbY4vBoPKOycT3BN9DGbIgK';

  /// Busca a lista de todas as equipas ativas no Pontomais
  static Future<List<String>> obterTodasEquipes() async {
    try {
      final url = Uri.parse('$_baseUrl/teams?active=true');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': _token,
        },
      );

     

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List teamsData = body['teams'] ?? body['data'] ?? [];

        Set<String> equipes = {};
        for (var t in teamsData) {
          if (t is Map && t['name'] != null) {
            equipes.add(t['name'].toString().trim());
          }
        }

        // Fallback caso o endpoint /teams venha vazio
        if (equipes.isEmpty) {
          final empUrl = Uri.parse('$_baseUrl/employees?active=true&attributes=team');
          final empResponse = await http.get(
            empUrl,
            headers: {
              'Content-Type': 'application/json',
              'access-token': _token,
            },
          );

          if (empResponse.statusCode == 200) {
            final empBody = jsonDecode(empResponse.body);
            final List employees = empBody['employees'] ?? empBody['data'] ?? [];

            for (var emp in employees) {
              if (emp is Map && emp['team'] != null) {

                if (emp['team'] is Map && emp['team']['name'] != null) {
                  equipes.add(emp['team']['name'].toString().trim());

                } else if (emp['team'] is String) {

                  equipes.add(emp['team'].toString().trim());
                }
              }
            }
          }
        }

        List<String> listaOrdenada = equipes.toList()..sort();
        return listaOrdenada;
      } else {
        debugPrint('[PontomaisService] Erro ao buscar equipes: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('[PontomaisService] Erro ao carregar equipes do Pontomais: $e');
      return [];
    }
    
          
  }

  

  /// Busca todos os colaboradores da obra e identifica quem bateu ponto ou faltou
  static Future<List<Funcionario>> buscarMarcacoesPorObra(String idObra, String dataFormatada) async {
    try {
      // 1. Busca as equipas associadas a esta obra no Firestore
      List<String> equipesPermitidas = await ObraEquipeService.obterEquipesDaObra(idObra);

      // 2. Busca todos os colaboradores ativos e suas equipas
      final employeesUrl = Uri.parse('$_baseUrl/employees?active=true&attributes=id,name,registration_number,team');
      final empResponse = await http.get(
        employeesUrl,
        headers: {
          'Content-Type': 'application/json',
          'access-token': _token,
        },
      );
      
      Map<String, Map<String, dynamic>> funcionariosMap = {};

      if (empResponse.statusCode == 200) {
        final empBody = jsonDecode(empResponse.body);
        final List employees = empBody['employees'] ?? empBody['data'] ?? [];

        for (var emp in employees) {
          if (emp is! Map) continue;
          String nomeEmp = emp['name']?.toString() ?? 'Colaborador';
          String matEmp = emp['registration_number']?.toString() ?? nomeEmp;

          // Extração correta da equipe (tratando o objeto Map ou String)
          String equipeName = 'Geral';
          if (emp['team'] is Map) {
            equipeName = emp['team']['name']?.toString().trim() ?? 'Geral';
          } else if (emp['team'] != null) {
            equipeName = emp['team'].toString().trim();
          }

          // Filtra apenas se a equipe pertence à obra selecionada
          if (equipesPermitidas.contains(equipeName)) {
            funcionariosMap[matEmp] = {
              'nome': nomeEmp,
              'equipe': equipeName,
              'horarios': <String>[],
            };
          }
        }
      }

      // 3. Busca o relatório de marcações (time cards) do dia para preencher quem bateu ponto
      final url = Uri.parse('$_baseUrl/reports/time_cards');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': _token,
        },
        body: jsonEncode({
          "report": {
            "start_date": dataFormatada,
            "end_date": dataFormatada,
            "group_by": "team",
            "row_filters": "",
            "columns": "employee_name, registration_number, date, time",
            "format": "json"
          }
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final outerData = body['data'];
        List grupos = [];
        if (outerData is List) {
          for (var item in outerData) {
            if (item is List) {
              grupos.addAll(item);
            } else if (item is Map) {
              grupos.add(item);
            }
          }
        }

        for (var grupo in grupos) {
          if (grupo is! Map) continue;
          final List registros = (grupo['data'] is List) ? grupo['data'] : [];
          for (var reg in registros) {
            if (reg is! Map) continue;
            String matricula = reg['registration_number']?.toString() ?? '';
            String hora = reg['time']?.toString() ?? '';

            // Se o funcionário está no mapa da obra, adiciona os horários dele
            if (funcionariosMap.containsKey(matricula) && hora.isNotEmpty) {
              List<String> hList = funcionariosMap[matricula]!['horarios'] as List<String>;
              if (!hList.contains(hora)) {
                hList.add(hora);
              }
            }
          }
        }
      }

      // 4. Constrói a lista final de funcionários (incluindo quem tem 0 horários / faltou)
      List<Funcionario> lista = [];
      funcionariosMap.forEach((matricula, dados) {
        List<String> horarios = dados['horarios'] as List<String>;
        lista.add(Funcionario(
          idFuncionario: matricula,
          nomeCompleto: dados['nome'],
          idObra: idObra,
          equipe: dados['equipe'],
          horarioEntrada: horarios.isNotEmpty ? horarios[0] : null,
          horarioSaidaIntervalo: horarios.length > 1 ? horarios[1] : null,
          horarioRetornoIntervalo: horarios.length > 2 ? horarios[2] : null,
          horarioSaida: horarios.length > 3 ? horarios[3] : null,
        ));
      });

      debugPrint('Total de funcionários mapeados para a obra $idObra (com e sem ponto): ${lista.length}');
      return lista;
    } catch (e) {
      debugPrint('Erro detalhado ao buscar marcações: $e');
      rethrow;
    }
  }
}