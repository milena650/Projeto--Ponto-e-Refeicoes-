class Funcionario {
  final String idFuncionario;
  final String nomeCompleto;
  final String idObra;
  final String? equipe; // <--- Novo campo para a equipa
  final String? horarioEntrada;
  final String? horarioSaidaIntervalo;
  final String? horarioRetornoIntervalo;
  final String? horarioSaida;

  Funcionario({
    required this.idFuncionario,
    required this.nomeCompleto,
    required this.idObra,
    this.equipe,
    this.horarioEntrada,
    this.horarioSaidaIntervalo,
    this.horarioRetornoIntervalo,
    this.horarioSaida,
  });


  // Regra 1: Café da Manhã (Entrada até 07:15)
  bool get temDireitoCafeManha {
    if (horarioEntrada == null) return false;
    final hora = _converterParaHoras(horarioEntrada!);
    return hora >= 6.0 && hora <= 7.25; 
  }

  // Regra 2: Almoço (Intervalo entre 11:30 e 13:00)
  bool get temDireitoAlmoco {
    return horarioEntrada != null && horarioSaidaIntervalo != null;
  }

  // Regra 3: Café da Tarde (Saída definitiva às 17:18)
  bool get temDireitoCafeTarde {
    if (horarioSaida == null) return false;
    final hora = _converterParaHoras(horarioSaida!);
    return hora >= 17.3;
  }

  double _converterParaHoras(String horario) {
    try {
      final partes = horario.split(':');
      return double.parse(partes[0]) + (double.parse(partes[1]) / 60);
    } catch (_) {
      return 0.0;
    }
  }
}