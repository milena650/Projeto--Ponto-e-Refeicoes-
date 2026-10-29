import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/funcionario_model.dart';

class PontomaisService {
  static const String _baseUrl = 'https://api.pontomais.com.br/external_api/v1';
  static const String _token = r'$2a$12$StZeJvb79qMce/0Yb6dj4.fG7du7GBgbY4vBoPKOycT3BN9DGbIgK';

  static Future<List<Funcionario>> buscarMarcacoesPorObra(String idObra, String dataFormatada) async {
    try {
      // 1. Busca a lista de colaboradores para garantir as equipes corretas
      final employeesUrl = Uri.parse('$_baseUrl/employees?active=true&attributes=id,name,registration_number,team');
      final empResponse = await http.get(
        employeesUrl,
        headers: {
          'Content-Type': 'application/json',
          'access-token': _token,
        },
      );

      Map<String, String> equipePorMatriculaOrNome = {};
      if (empResponse.statusCode == 200) {
        final empBody = jsonDecode(empResponse.body);
        final List employees = empBody['employees'] ?? empBody['data'] ?? [];
        
        for (var emp in employees) {
          if (emp is! Map) continue;
          String nomeEmp = emp['name']?.toString() ?? '';
          String matEmp = emp['registration_number']?.toString() ?? '';
          
          // Extrai o nome da equipe do objeto team se existir
          String equipeName = 'Geral';
          if (emp['team'] is Map) {
            equipeName = emp['team']['name']?.toString() ?? 'Geral';
          } else if (emp['team'] != null) {
            equipeName = emp['team'].toString();
          }

          if (matEmp.isNotEmpty) equipePorMatriculaOrNome[matEmp] = equipeName;
          if (nomeEmp.isNotEmpty) equipePorMatriculaOrNome[nomeEmp] = equipeName;
        }
      }

      // 2. Busca o relatório de marcações (time_cards) do dia
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

            // Descobre a equipe cruzando com os dados cadastrais obtidos no passo 1
            String nomeEquipe = equipePorMatriculaOrNome[matricula] ?? equipePorMatriculaOrNome[nome] ?? 'Geral';

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

        print('Total de funcionários mapeados com equipe: ${lista.length}');
        return lista;
      } else {
        throw Exception('Erro na API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro capturado detalhado: $e');
      rethrow;
    }
  }
}