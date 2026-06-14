class AtividadeModel {
  final int? id;
  final String natureza; // 'ensino' | 'pesquisa' | 'extensao'
  final String classificacao;
  final String tipo;
  final String titulo;
  final double horasCalculadas;
  final DateTime dataCriacao;
  final DateTime? dataInicial;
  final DateTime? dataFinal;

  const AtividadeModel({
    this.id,
    required this.natureza,
    required this.classificacao,
    required this.tipo,
    required this.titulo,
    required this.horasCalculadas,
    required this.dataCriacao,
    this.dataInicial,
    this.dataFinal,
  });

  AtividadeModel copyWith({
    int? id,
    String? titulo,
    double? horasCalculadas,
    DateTime? dataInicial,
    DateTime? dataFinal,
    bool clearDataInicial = false,
    bool clearDataFinal = false,
  }) =>
      AtividadeModel(
        id: id ?? this.id,
        natureza: natureza,
        classificacao: classificacao,
        tipo: tipo,
        titulo: titulo ?? this.titulo,
        horasCalculadas: horasCalculadas ?? this.horasCalculadas,
        dataCriacao: dataCriacao,
        dataInicial: clearDataInicial ? null : (dataInicial ?? this.dataInicial),
        dataFinal: clearDataFinal ? null : (dataFinal ?? this.dataFinal),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'natureza': natureza,
        'classificacao': classificacao,
        'tipo': tipo,
        'titulo': titulo,
        'horas_calculadas': horasCalculadas,
        'data_criacao': dataCriacao.toIso8601String(),
        'data_inicial': dataInicial?.toIso8601String(),
        'data_final': dataFinal?.toIso8601String(),
      };

  factory AtividadeModel.fromMap(Map<String, dynamic> m) => AtividadeModel(
        id: m['id'] as int?,
        natureza: m['natureza'] as String,
        classificacao: m['classificacao'] as String,
        tipo: m['tipo'] as String,
        titulo: m['titulo'] as String,
        horasCalculadas: (m['horas_calculadas'] as num).toDouble(),
        dataCriacao: DateTime.parse(m['data_criacao'] as String),
        dataInicial: m['data_inicial'] != null
            ? DateTime.parse(m['data_inicial'] as String)
            : null,
        dataFinal: m['data_final'] != null
            ? DateTime.parse(m['data_final'] as String)
            : null,
      );
}
