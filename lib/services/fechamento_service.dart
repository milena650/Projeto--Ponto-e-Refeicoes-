import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fechamento_model.dart';
import '../models/funcionario_model.dart';

class FechamentoService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Salva ou atualiza o fechamento diário da obra
  static Future<void> salvarFechamentoDiario({
    required String obra,
    required String dataFormatada,
    required int totalCafe,
    required int totalAlmoco,
    required int totalTarde,
    required List<Funcionario> funcionarios,
  }) async {
    final String docId = '${obra}_$dataFormatada';

    // Converte a lista de funcionários para um formato JSON seguro
    final List listaFuncionariosMap = funcionarios.map((f) {
      return {
        'idFuncionario': f.idFuncionario,
        'nomeCompleto': f.nomeCompleto,
        'equipe': f.equipe,
        'horarioEntrada': f.horarioEntrada,
        'horarioSaidaIntervalo': f.horarioSaidaIntervalo,
        'horarioRetornoIntervalo': f.horarioRetornoIntervalo,
        'horarioSaida': f.horarioSaida,
        'temDireitoCafeManha': f.temDireitoCafeManha,
        'temDireitoAlmoco': f.temDireitoAlmoco,
        'temDireitoCafeTarde': f.temDireitoCafeTarde,
      };
    }).toList();

    final fechamento = FechamentoDiario(
      id: docId,
      obra: obra,
      data: dataFormatada,
      totalCafeManha: totalCafe,
      totalAlmoco: totalAlmoco,
      totalCafeTarde: totalTarde,
      funcionariosEstado: listaFuncionariosMap,
    );

    await _db.collection('fechamentos_diarios').doc(docId).set(fechamento.toMap());
  }

  /// Busca os fechamentos de um intervalo de datas (para o relatório da quinzena)
  static Future<List<FechamentoDiario>> obterRelatorioQuinzenal({
    required String obra,
    required String dataInicio, // Ex: "2026-06-01"
    required String dataFim,   // Ex: "2026-06-15"
  }) async {
    final querySnapshot = await _db
        .collection('fechamentos_diarios')
        .where('obra', isEqualTo: obra)
        .where('data', isGreaterThanOrEqualTo: dataInicio)
        .where('data', isLessThanOrEqualTo: dataFim)
        .get();

    return querySnapshot.docs.map((doc) {
      return FechamentoDiario.fromMap(doc.id, doc.data());
    }).toList();
  }
}