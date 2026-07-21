import 'package:controle_horas/src/data/models/atividade_model.dart';

/// Aplica as regras do barema AC (BSI):
/// - Por classificação: soma das horas → arredonda para baixo ao múltiplo de 15 → limita a 120h
/// - Por natureza: soma das classificações → limita a 360h (uma natureza pode,
///   sozinha, chegar às 360h; o teto de 120h existe só na classificação)
/// - Total do curso: soma das três naturezas → nunca passa de 360h
class BaremaService {
  static const double maxPorClassificacao = 120;
  static const double maxPorNatureza = 360;
  static const double credito = 15;

  /// Horas efetivas de uma classificação dado uma lista de horas brutas das atividades.
  static double efetivoPorClassificacao(List<double> horas) {
    final soma = horas.fold(0.0, (acc, h) => acc + h);
    final multiplo = (soma / credito).floor() * credito;
    return multiplo.clamp(0, maxPorClassificacao);
  }

  /// Horas efetivas de uma natureza dado todas as atividades daquela natureza.
  static double efetivoPorNatureza(List<AtividadeModel> atividades) {
    final porClassificacao = <String, List<double>>{};
    for (final a in atividades) {
      porClassificacao.putIfAbsent(a.classificacao, () => []);
      porClassificacao[a.classificacao]!.add(a.horasCalculadas);
    }
    double total = 0;
    for (final horas in porClassificacao.values) {
      total += efetivoPorClassificacao(horas);
    }
    return total.clamp(0, maxPorNatureza);
  }

  /// Resumo completo: horas efetivas por natureza e total geral.
  static ResumoBarema calcularResumo(List<AtividadeModel> todasAtividades) {
    final ensino = todasAtividades.where((a) => a.natureza == 'ensino').toList();
    final pesquisa = todasAtividades.where((a) => a.natureza == 'pesquisa').toList();
    final extensao = todasAtividades.where((a) => a.natureza == 'extensao').toList();

    final hEnsino = efetivoPorNatureza(ensino);
    final hPesquisa = efetivoPorNatureza(pesquisa);
    final hExtensao = efetivoPorNatureza(extensao);

    return ResumoBarema(
      ensino: hEnsino,
      pesquisa: hPesquisa,
      extensao: hExtensao,
      total: hEnsino + hPesquisa + hExtensao,
    );
  }

  /// Horas efetivas por classificação dentro de uma natureza (para tela de detalhes).
  static Map<String, double> efetivoPorClassificacaoMap(
      List<AtividadeModel> atividades) {
    final porClassificacao = <String, List<double>>{};
    for (final a in atividades) {
      porClassificacao.putIfAbsent(a.classificacao, () => []);
      porClassificacao[a.classificacao]!.add(a.horasCalculadas);
    }
    return porClassificacao.map(
      (k, v) => MapEntry(k, efetivoPorClassificacao(v)),
    );
  }

  /// Verifica se é possível adicionar uma nova atividade sem violar os limites.
  /// Retorna [VerificacaoLimite] com o resultado e mensagem explicativa.
  static VerificacaoLimite verificarLimite({
    required List<AtividadeModel> existentes,
    required String natureza,
    required String classificacao,
  }) {
    // 1️⃣ Total geral já atingiu a meta do curso (360h)?
    final resumo = calcularResumo(existentes);
    if (resumo.total >= ResumoBarema.maxTotal) {
      return const VerificacaoLimite.bloqueado(
        titulo: 'Curso concluído! 🎉',
        mensagem:
            'Você já completou as 360h de atividades complementares. '
            'Não é necessário cadastrar mais atividades.',
      );
    }

    // 2️⃣ A classificação já atingiu 120h?
    final daNatureza = existentes.where((a) => a.natureza == natureza).toList();
    final nomeNatureza = _labelNatureza(natureza);
    final naturezasAlternativas = _naturezasAlternativas(natureza);
    final daClassificacao = daNatureza
        .where((a) => a.classificacao == classificacao)
        .map((a) => a.horasCalculadas)
        .toList();
    final horasClassificacao = efetivoPorClassificacao(daClassificacao);

    if (horasClassificacao >= maxPorClassificacao) {
      return VerificacaoLimite.bloqueado(
        titulo: 'Limite de "$classificacao" atingido',
        mensagem:
            'A classificação "$classificacao" já atingiu 120h. '
            'Cadastre em outra classificação de $nomeNatureza '
            'ou em $naturezasAlternativas.',
      );
    }

    return const VerificacaoLimite.permitido();
  }

  static String _labelNatureza(String natureza) => switch (natureza) {
        'ensino' => 'Ensino',
        'pesquisa' => 'Pesquisa',
        'extensao' => 'Extensão',
        _ => natureza,
      };

  static String _naturezasAlternativas(String natureza) => switch (natureza) {
        'ensino' => 'Pesquisa ou Extensão',
        'pesquisa' => 'Ensino ou Extensão',
        'extensao' => 'Ensino ou Pesquisa',
        _ => 'outra natureza',
      };
}

class VerificacaoLimite {
  final bool permitido;
  final String? titulo;
  final String? mensagem;

  const VerificacaoLimite.permitido()
      : permitido = true,
        titulo = null,
        mensagem = null;

  const VerificacaoLimite.bloqueado({
    required this.titulo,
    required this.mensagem,
  }) : permitido = false;
}

class ResumoBarema {
  final double ensino;
  final double pesquisa;
  final double extensao;
  final double total;

  const ResumoBarema({
    required this.ensino,
    required this.pesquisa,
    required this.extensao,
    required this.total,
  });

  /// Meta total do curso: 360h de atividades complementares
  static const double maxTotal = 360;

  double get progressEnsino => (ensino / BaremaService.maxPorNatureza).clamp(0, 1);
  double get progressPesquisa => (pesquisa / BaremaService.maxPorNatureza).clamp(0, 1);
  double get progressExtensao => (extensao / BaremaService.maxPorNatureza).clamp(0, 1);
  double get progressTotal => (total / maxTotal).clamp(0, 1);
}
