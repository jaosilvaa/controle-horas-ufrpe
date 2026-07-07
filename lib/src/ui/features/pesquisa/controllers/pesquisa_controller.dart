import 'package:flutter/material.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';
import 'package:controle_horas/src/data/repositories/atividade_repository.dart';
import 'package:controle_horas/src/shared/models/tipo_calculo.dart';
export 'package:controle_horas/src/shared/models/tipo_calculo.dart';

enum PesquisaClassificacao {
  iniciacaoPesquisa,
  vivenciaProfissional;

  String get label => switch (this) {
        PesquisaClassificacao.iniciacaoPesquisa => 'Iniciação à pesquisa',
        PesquisaClassificacao.vivenciaProfissional =>
          'Vivência Profissional Complementar',
      };
}

enum PesquisaTipo {
  projetoPesquisa,
  grupoPesquisa,
  publicacaoTecnico,
  estagio,
  atividadeProfissional;

  String get label => switch (this) {
        PesquisaTipo.projetoPesquisa => 'Projeto de pesquisa',
        PesquisaTipo.grupoPesquisa => 'Grupo de pesquisa',
        PesquisaTipo.publicacaoTecnico => 'Publicação Técnico-Científica',
        PesquisaTipo.estagio => 'Estágio',
        PesquisaTipo.atividadeProfissional => 'Atividade Profissional',
      };
}

enum PublicacaoTipo {
  qualisA,
  qualisB,
  qualisC,
  qualisD,
  resumoSimples,
  resumoExpandido,
  capituloLivro;

  String get label => switch (this) {
        PublicacaoTipo.qualisA => 'Qualis A',
        PublicacaoTipo.qualisB => 'Qualis B',
        PublicacaoTipo.qualisC => 'Qualis C',
        PublicacaoTipo.qualisD => 'Qualis D',
        PublicacaoTipo.resumoSimples => 'Resumo Simples (não-indexado)',
        PublicacaoTipo.resumoExpandido => 'Resumo Expandido (não-indexado)',
        PublicacaoTipo.capituloLivro => 'Capítulo de Livro na área',
      };

  double get horas => switch (this) {
        PublicacaoTipo.qualisA => 120,
        PublicacaoTipo.qualisB => 90,
        PublicacaoTipo.qualisC => 60,
        PublicacaoTipo.qualisD => 30,
        PublicacaoTipo.resumoSimples => 15,
        PublicacaoTipo.resumoExpandido => 30,
        PublicacaoTipo.capituloLivro => 60,
      };
}

class PesquisaController extends ChangeNotifier {
  final AtividadeRepository _repo;

  PesquisaController(this._repo) {
    semestresController.addListener(notifyListeners);
    cargaHorariaController.addListener(notifyListeners);
  }

  final formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final semestresController = TextEditingController();
  final cargaHorariaController = TextEditingController();

  PesquisaClassificacao? _classificacao;
  PesquisaTipo? _tipo;
  TipoCalculo _tipoCalculo = TipoCalculo.porSemestre;
  DateTime? _dataInicial;
  DateTime? _dataFinal;

  // Publicação Técnico-Científica
  PublicacaoTipo? _tipoPublicacao;
  DateTime? _dataPublicacao;

  // Erros para campos fora do Form
  String? classificacaoError;
  String? tipoError;
  String? dataInicialError;
  String? dataFinalError;
  String? dateRangeError;
  String? tipoPublicacaoError;
  String? dataPublicacaoError;

  // ─── Getters ──────────────────────────────────────────────────────────────

  PesquisaClassificacao? get classificacao => _classificacao;
  PesquisaTipo? get tipo => _tipo;
  TipoCalculo get tipoCalculo => _tipoCalculo;
  DateTime? get dataInicial => _dataInicial;
  DateTime? get dataFinal => _dataFinal;
  PublicacaoTipo? get tipoPublicacao => _tipoPublicacao;
  DateTime? get dataPublicacao => _dataPublicacao;

  /// Projeto de Pesquisa e Grupo de Pesquisa → segmented control + semestres/carga
  bool get showCalculoFields =>
      _tipo == PesquisaTipo.projetoPesquisa ||
      _tipo == PesquisaTipo.grupoPesquisa;

  /// Publicação Técnico-Científica → tipo de publicação fixo + data única
  bool get showPublicacaoFields => _tipo == PesquisaTipo.publicacaoTecnico;

  /// Total fixo baseado no tipo de publicação selecionado
  double get totalHorasPublicacao => _tipoPublicacao?.horas ?? 0;

  /// Estágio e Atividade Profissional → exibe bloco de total de horas
  bool get showEstagioFields =>
      _tipo == PesquisaTipo.estagio ||
      _tipo == PesquisaTipo.atividadeProfissional;

  /// Cada bloco de 6 meses (≈ 180 dias) com ≥ 20h/sem = 60 h/a, máx 120h
  double get totalHorasEstagio {
    if (_dataInicial == null || _dataFinal == null) return 0;
    if (!_dataFinal!.isAfter(_dataInicial!)) return 0;
    final dias = _dataFinal!.difference(_dataInicial!).inDays;
    final blocos = (dias / 180).floor();
    return (blocos * 60.0).clamp(0, 120);
  }

  /// True quando o período informado geraria mais de 120h (limite da classificação)
  bool get estagioAtingiuLimite {
    if (_dataInicial == null || _dataFinal == null) return false;
    if (!_dataFinal!.isAfter(_dataInicial!)) return false;
    final dias = _dataFinal!.difference(_dataInicial!).inDays;
    return (dias / 180).floor() * 60.0 >= 120;
  }

  /// Total para Projeto/Grupo: semestres×60 ou horas÷4 (maior dos dois)
  double get totalHoras {
    final s = int.tryParse(semestresController.text.trim()) ?? 0;
    final fromSemestres = s * 60.0;
    final h = double.tryParse(cargaHorariaController.text.trim()) ?? 0.0;
    final fromCarga = h / 4.0;
    return fromSemestres > fromCarga ? fromSemestres : fromCarga;
  }

  /// Hint do Título varia conforme o tipo selecionado
  String get tituloHint {
    if (_tipo == null) return 'Ex: Título da atividade';
    return switch (_tipo!) {
      PesquisaTipo.projetoPesquisa => 'Ex: Projeto de Pesquisa em IA',
      PesquisaTipo.grupoPesquisa => 'Ex: Grupo de Pesquisa em Redes',
      PesquisaTipo.publicacaoTecnico =>
        'Ex: Artigo sobre Segurança da Informação',
      PesquisaTipo.estagio => 'Ex: Estágio em empresa de tecnologia',
      PesquisaTipo.atividadeProfissional =>
        'Ex: Atividade profissional em TI',
    };
  }

  List<PesquisaTipo> get tiposDisponiveis {
    if (_classificacao == null) return [];
    return switch (_classificacao!) {
      PesquisaClassificacao.iniciacaoPesquisa => [
          PesquisaTipo.projetoPesquisa,
          PesquisaTipo.grupoPesquisa,
          PesquisaTipo.publicacaoTecnico,
        ],
      PesquisaClassificacao.vivenciaProfissional => [
          PesquisaTipo.estagio,
          PesquisaTipo.atividadeProfissional,
        ],
    };
  }

  // ─── Setters ──────────────────────────────────────────────────────────────

  void setClassificacao(PesquisaClassificacao value) {
    _classificacao = value;
    _tipo = null;
    _tipoPublicacao = null;
    _dataPublicacao = null;
    classificacaoError = null;
    tipoError = null;
    notifyListeners();
  }

  void setTipo(PesquisaTipo value) {
    _tipo = value;
    _tipoPublicacao = null;
    _dataPublicacao = null;
    tipoError = null;
    tipoPublicacaoError = null;
    dataPublicacaoError = null;
    notifyListeners();
  }

  void setTipoCalculo(TipoCalculo value) {
    _tipoCalculo = value;
    notifyListeners();
  }

  void setTipoPublicacao(PublicacaoTipo value) {
    _tipoPublicacao = value;
    tipoPublicacaoError = null;
    notifyListeners();
  }

  void setDataInicial(DateTime value) {
    _dataInicial = value;
    dataInicialError = null;
    dateRangeError = null;
    notifyListeners();
  }

  void setDataFinal(DateTime value) {
    _dataFinal = value;
    dataFinalError = null;
    dateRangeError = null;
    notifyListeners();
  }

  void setDataPublicacao(DateTime value) {
    _dataPublicacao = value;
    dataPublicacaoError = null;
    notifyListeners();
  }

  // ─── Persistência ─────────────────────────────────────────────────────────

  Future<AtividadeModel> salvar() {
    double horas;
    if (showPublicacaoFields) {
      horas = totalHorasPublicacao;
    } else if (showEstagioFields) {
      horas = totalHorasEstagio;
    } else {
      horas = totalHoras;
    }

    final atividade = AtividadeModel(
      natureza: 'pesquisa',
      classificacao: _classificacao!.label,
      tipo: _tipo!.label,
      titulo: tituloController.text.trim(),
      horasCalculadas: horas,
      dataCriacao: DateTime.now(),
      dataInicial: _dataInicial,
      dataFinal: _dataFinal ?? _dataPublicacao,
    );
    return _repo.salvar(atividade);
  }

  // ─── Validação ────────────────────────────────────────────────────────────

  bool validate() {
    final formValid = formKey.currentState?.validate() ?? false;

    classificacaoError =
        _classificacao == null ? 'Selecione uma classificação' : null;
    tipoError = _tipo == null ? 'Selecione um tipo' : null;

    if (showPublicacaoFields) {
      // Validação específica de Publicação Técnico-Científica
      tipoPublicacaoError = _tipoPublicacao == null
          ? 'Selecione o tipo de publicação'
          : null;
      dataPublicacaoError =
          _dataPublicacao == null ? 'Selecione a data de publicação' : null;
      dataInicialError = null;
      dataFinalError = null;
      dateRangeError = null;
    } else {
      // Validação de datas para Projeto/Grupo de Pesquisa
      tipoPublicacaoError = null;
      dataPublicacaoError = null;
      dataInicialError =
          _dataInicial == null ? 'Selecione a data inicial' : null;
      dataFinalError = _dataFinal == null ? 'Selecione a data final' : null;
      dateRangeError = null;

      if (_dataInicial != null && _dataFinal != null) {
        if (!_dataFinal!.isAfter(_dataInicial!)) {
          dataFinalError = 'Data final deve ser após a data inicial';
        } else if (showCalculoFields &&
            _tipoCalculo == TipoCalculo.porSemestre) {
          final semestres =
              int.tryParse(semestresController.text.trim()) ?? 0;
          if (semestres > 0) {
            final minDias = semestres * 180;
            final diasReais = _dataFinal!.difference(_dataInicial!).inDays;
            if (diasReais < minDias) {
              dateRangeError = 'O período informado é menor que $semestres '
                  'semestre(s). São necessários pelo menos '
                  '${semestres * 6} meses (≈ ${semestres * 180} dias).';
            }
          }
        }
      }
    }

    final customValid = classificacaoError == null &&
        tipoError == null &&
        tipoPublicacaoError == null &&
        dataPublicacaoError == null &&
        dataInicialError == null &&
        dataFinalError == null &&
        dateRangeError == null;

    notifyListeners();
    return formValid && customValid;
  }

  @override
  void dispose() {
    tituloController.dispose();
    semestresController.dispose();
    cargaHorariaController.dispose();
    super.dispose();
  }
}
