import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/funcionario_model.dart';

class PontomaisService {
  static const String _baseUrl = 'https://api.pontomais.com.br/external_api/v1';
  
  // Insira aqui o seu Token da API do Pontomais
  static const String _token = '\$2a\$12\$StZeJvb79qMce/0Yb6dj4.fG7du7GBgbY4vBoPKOycT3BN9DGbIgK';

  static Future<List<Funcionario>> buscarMarcacoesPorObra(String idObra, String dataFormatada) async {
    // Exemplo de endpoint: busca os registros de ponto do dia filtrando por obra
    final url = Uri.parse('$_baseUrl/marmita_summary?date=$dataFormatada&work_site=$idObra');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'access-token': _token,
      },

    );
    print('STATUS CODE: ${response.statusCode}');
    print('RESPOSTA: ${response.body}');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List dados = body['data'] ?? [];

      return dados.map((item) {
        return Funcionario(
          idFuncionario: item['employee']['id'].toString(),
          nomeCompleto: item['employee']['name'],
          idObra: idObra,
          horarioEntrada: item['first_input'],
          horarioSaidaIntervalo: item['first_output'],
          horarioRetornoIntervalo: item['second_input'],
          horarioSaida: item['second_output'],
        );
      }).toList();
    } else {
      throw Exception('Erro ao conectar na API do Pontomais: ${response.statusCode}');
    }
  }
}