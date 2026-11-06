class FechamentoDiario {
  final String id;
  final String obra;
  final String data;
  final int totalCafeManha;
  final int totalAlmoco;
  final int totalCafeTarde;
  final List funcionariosEstado; // Tipagem correta da lista

  FechamentoDiario({
    required this.id,
    required this.obra,
    required this.data,
    required this.totalCafeManha,
    required this.totalAlmoco,
    required this.totalCafeTarde,
    required this.funcionariosEstado,
  });

  Map<String, dynamic> toMap() {
    return {
      'obra': obra,
      'data': data,
      'totalCafeManha': totalCafeManha,
      'totalAlmoco': totalAlmoco,
      'totalCafeTarde': totalCafeTarde,
      'funcionariosEstado': funcionariosEstado,
    };
  }

  factory FechamentoDiario.fromMap(String id, Map<String, dynamic> map) {
    return FechamentoDiario(
      id: id,
      obra: map['obra'] ?? '',
      data: map['data'] ?? '',
      totalCafeManha: map['totalCafeManha'] ?? 0,
      totalAlmoco: map['totalAlmoco'] ?? 0,
      totalCafeTarde: map['totalCafeTarde'] ?? 0,
      funcionariosEstado: List.from(map['funcionariosEstado'] ?? []),
    );
  }
}