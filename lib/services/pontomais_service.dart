import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/funcionario_model.dart';
import 'obra_equipe_service.dart';

class PontomaisService {
  static const String _baseUrl = 'https://api.pontomais.com.br/external_api/v1';
  static const String _token = r'$2a$12$StZeJvb79qMce/0Yb6dj4.fG7du7GBgbY4vBoPKOycT3BN9DGbIgK';

  static Future<List<Funcionario>> buscarMarcacoesPorObra(String idObra, String dataFormatada) async {
    try {
      // 1. Busca as equipes associadas manualmente a esta obra através do SharedPreferences
      List<String> equipesPermitidas = await ObraEquipeService.obterEquipesDaObra(idObra);

      // 2. Busca a lista de colaboradores para garantir as equipes corretas
      final employeesUrl = Uri.parse('$_baseUrl/employees?active=true&attributes=id,name,registration_number,team');
      final empResponse = await http.get(
        employeesUrl,
        headers: {
          'Content-Type': 'application/json',
          'access-token': _token,
        },
      );

      Map<String, Map<String, String>> dadosColaborador = {};
      if (empResponse.statusCode == 200) {
        final empBody = jsonDecode(empResponse.body);
        final List employees = empBody['employees'] ?? empBody['data'] ?? [];
        
        for (var emp in employees) {
          if (emp is! Map) continue;
          String nomeEmp = emp['name']?.toString() ?? '';
          String matEmp = emp['registration_number']?.toString() ?? '';
          
          String equipeName = 'Geral';
          if (emp['team'] is Map) {
            equipeName = emp['team']['name']?.toString() ?? 'Geral';
          } else if (emp['team'] != null) {
            equipeName = emp['team'].toString();
          }

          var info = {'equipe': equipeName};
          if (matEmp.isNotEmpty) dadosColaborador[matEmp] = info;
          if (nomeEmp.isNotEmpty) dadosColaborador[nomeEmp] = info;
        }
      }

      // 3. Busca o relatório de marcações (time_cards) do dia
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
            "columns": "employee_name,registration_number,date,time",
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

        Map<String, Map<String, dynamic>> funcionariosMap = {};

        for (var grupo in grupos) {
          if (grupo is! Map) continue;
          
          final List registros = (grupo['data'] is List) ? grupo['data'] : [];

          for (var reg in registros) {
            if (reg is! Map) continue;
            
            String nome = reg['employee_name']?.toString() ?? 'Colaborador';
            String matricula = reg['registration_number']?.toString() ?? nome;
            String hora = reg['time']?.toString() ?? '';

            // Recupera a equipe oficial do colaborador
            String nomeEquipe = dadosColaborador[matricula]?['equipe'] ?? 
                                dadosColaborador[nome]?['equipe'] ?? 'Geral';

            // --- FILTRAGEM 100% MANUAL E LIMPA ---
            // Se houver equipes selecionadas para esta obra, valida se a equipe faz parte da lista.
            // Se nenhuma equipe foi configurada ainda para esta obra, traz vazio ou tudo (aqui definimos que se a lista estiver vazia, não traz ou traz tudo - pode ajustar conforme preferir).
            bool pertenceAQui = equipesPermitidas.contains(nomeEquipe);

            // Apenas adiciona se pertencer à obra selecionada
            if (pertenceAQui) {
              if (!funcionariosMap.containsKey(matricula)) {
                funcionariosMap[matricula] = {
                  'nome': nome,
                  'equipe': nomeEquipe,
                  'horarios': <String>[]
                };
              }
              if (hora.isNotEmpty) {
                List<String> hList = funcionariosMap[matricula]!['horarios'] as List<String>;
                if (!hList.contains(hora)) {
                  hList.add(hora);
                }
              }
            }
          }
        }

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

        print('Total de funcionários filtrados para a obra $idObra: ${lista.length}');
        return lista;
      } else {
        throw Exception('Erro na API: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Erro capturado detalhado: $e');
      rethrow;
    }
  }
}