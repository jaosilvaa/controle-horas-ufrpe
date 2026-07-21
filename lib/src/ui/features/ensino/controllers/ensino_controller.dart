import 'package:flutter/material.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';
import 'package:controle_horas/src/data/repositories/atividade_repository.dart';
import 'package:controle_horas/src/shared/models/tipo_calculo.dart';
export 'package:controle_horas/src/shared/models/tipo_calculo.dart';

// ─── Classificações ───────────────────────────────────────────────────────────

enum EnsinoClassificacao {
  iniciacaoDocencia,
  discussoesTematicas,
  topicosEspeciais;

  String get label => switch (this) {
        EnsinoClassificacao.iniciacaoDocencia => 'Iniciação à Docência',
        EnsinoClassificacao.discussoesTematicas => 'Discussões Temáticas',
        EnsinoClassificacao.topicosEspeciais => 'Tópicos Especiais',
      };
}

// ─── Tipos ────────────────────────────────────────────────────────────────────

enum EnsinoTipo {
  monitoria,
  pet,
  pibid,
  bia,
  discussoesTematicas,
  cursos,
  praticaIntegrada,
  projetoEnsino;

  String get label => switch (this) {
        EnsinoTipo.monitoria => 'Monitoria',
        EnsinoTipo.pet => 'PET',
        EnsinoTipo.pibid => 'PIBID',
        EnsinoTipo.bia => 'BIA',
        EnsinoTipo.discussoesTematicas => 'Discussões Temáticas',
        EnsinoTipo.cursos => 'Cursos',
        EnsinoTipo.praticaIntegrada => 'Prática Integrada',
        EnsinoTipo.projetoEnsino => 'Projeto de Ensino',
      };
}

// ─── Controller ───────────────────────────────────────────────────────────────

class EnsinoController extends ChangeNotifier {
  final AtividadeRepository _repo;

  EnsinoController(this._repo) {
    semestresController.addListener(notifyListeners);
    cargaHorariaController.addListener(notifyListeners);
    cargaSimController.addListener(notifyListeners);
    artefatosController.addListener(notifyListeners);
  }

  final formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();

  // Segmented calc (Monitoria / PET / PIBID / BIA / Projeto de Ensino)
  final semestresController = TextEditingController();
  final cargaHorariaController = TextEditingController();

  // Simple calc
  final cargaSimController = TextEditingController(); // carga × 3
  final artefatosController = TextEditingController(); // artefatos × 15

  EnsinoClassificacao? _classificacao;
  EnsinoTipo? _tipo;
  TipoCalculo _tipoCalculo = TipoCalculo.porSemestre;
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  DateTime? _dataApresentacao;

  // ── Erros para campos fora do Form ──────────────────────────────────────────
  String? classificacaoError;
  String? tipoError;
  String? dataInicialError;
  String? dataFinalError;
  String? dateRangeError;
  String? cargaSimError;
  String? artefatosError;
  String? dataApresentacaoError;

  // ─── Getters ────────────────────────────────────────────────────────────────

  EnsinoClassificacao? get classificacao => _classificacao;
  EnsinoTipo? get tipo => _tipo;
  TipoCalculo get tipoCalculo => _tipoCalculo;
  DateTime? get dataInicial => _dataInicial;
  DateTime? get dataFinal => _dataFinal;
  DateTime? get dataApresentacao => _dataApresentacao;

  /// Monitoria, PET, PIBID, BIA, Projeto de Ensino → segmented + data ini/fin
  bool get showCalculoFields =>
      _tipo == EnsinoTipo.monitoria ||
      _tipo == EnsinoTipo.pet ||
      _tipo == EnsinoTipo.pibid ||
      _tipo == EnsinoTipo.bia ||
      _tipo == EnsinoTipo.projetoEnsino;

  /// Discussões Temáticas, Cursos → carga × 3 + data de apresentação
  bool get showCargaX3Fields =>
      _tipo == EnsinoTipo.discussoesTematicas ||
      _tipo == EnsinoTipo.cursos;

  /// Prática Integrada → artefatos × 15 + data de apresentação
  bool get showArtefatosFields => _tipo == EnsinoTipo.praticaIntegrada;

  /// Tipos com data única (apresentação)
  bool get showDataUnica => showCargaX3Fields || showArtefatosFields;

  /// Total para segmented: max(semestres×60, carga÷4)
  double get totalHorasCalculo {
    final s = int.tryParse(semestresController.text.trim()) ?? 0;
    final fromSemestres = s * 60.0;
    final h = double.tryParse(cargaHorariaController.text.trim()) ?? 0.0;
    final fromCarga = h / 4.0;
    return fromSemestres > fromCarga ? fromSemestres : fromCarga;
  }

  /// Total para carga × 3
  double get totalHorasCargaX3 {
    final h = double.tryParse(cargaSimController.text.trim()) ?? 0.0;
    return h * 3.0;
  }

  /// Total para artefatos × 15
  double get totalHorasArtefatos {
    final n = int.tryParse(artefatosController.text.trim()) ?? 0;
    return n * 15.0;
  }

  /// True quando o valor calculado do fluxo ativo ultrapassa o teto de 120h
  /// da classificação (apenas 120h/a são contabilizadas, mesmo que a conta
  /// dê um valor maior).
  bool get atingiuLimite {
    if (showCalculoFields) return totalHorasCalculo >= 120;
    if (showCargaX3Fields) return totalHorasCargaX3 >= 120;
    if (showArtefatosFields) return totalHorasArtefatos >= 120;
    return false;
  }

  /// Hint do Título varia conforme o tipo selecionado
  String get tituloHint {
    if (_tipo == null) return 'Ex: Título da atividade';
    return switch (_tipo!) {
      EnsinoTipo.monitoria => 'Ex: Monitoria de Cálculo',
      EnsinoTipo.pet => 'Ex: Atividade no PET',
      EnsinoTipo.pibid => 'Ex: Atividade no PIBID',
      EnsinoTipo.bia => 'Ex: Atividade no BIA',
      EnsinoTipo.discussoesTematicas => 'Ex: Palestra sobre Segurança da Informação',
      EnsinoTipo.cursos => 'Ex: Curso de Introdução ao Python',
      EnsinoTipo.praticaIntegrada => 'Ex: Relatório de Prática Integrada',
      EnsinoTipo.projetoEnsino => 'Ex: Projeto de Ensino em Algoritmos',
    };
  }

  List<EnsinoTipo> get tiposDisponiveis {
    if (_classificacao == null) return [];
    return switch (_classificacao!) {
      EnsinoClassificacao.iniciacaoDocencia => [
          EnsinoTipo.monitoria,
          EnsinoTipo.pet,
          EnsinoTipo.pibid,
          EnsinoTipo.bia,
        ],
      EnsinoClassificacao.discussoesTematicas => [
          EnsinoTipo.discussoesTematicas,
        ],
      EnsinoClassificacao.topicosEspeciais => [
          EnsinoTipo.cursos,
          EnsinoTipo.praticaIntegrada,
          EnsinoTipo.projetoEnsino,
        ],
    };
  }

  // ─── Setters ────────────────────────────────────────────────────────────────

  void setClassificacao(EnsinoClassificacao value) {
    _classificacao = value;
    _tipo = null;
    classificacaoError = null;
    tipoError = null;
    _resetCalculoFields();
    // Auto-seleciona se só há um tipo disponível
    final tipos = tiposDisponiveis;
    if (tipos.length == 1) _tipo = tipos.first;
    notifyListeners();
  }

  void setTipo(EnsinoTipo value) {
    _tipo = value;
    tipoError = null;
    _resetCalculoFields();
    notifyListeners();
  }

  void setTipoCalculo(TipoCalculo value) {
    _tipoCalculo = value;
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

  void setDataApresentacao(DateTime value) {
    _dataApresentacao = value;
    dataApresentacaoError = null;
    notifyListeners();
  }

  void _resetCalculoFields() {
    semestresController.removeListener(notifyListeners);
    cargaHorariaController.removeListener(notifyListeners);
    cargaSimController.removeListener(notifyListeners);
    artefatosController.removeListener(notifyListeners);

    semestresController.clear();
    cargaHorariaController.clear();
    cargaSimController.clear();
    artefatosController.clear();

    semestresController.addListener(notifyListeners);
    cargaHorariaController.addListener(notifyListeners);
    cargaSimController.addListener(notifyListeners);
    artefatosController.addListener(notifyListeners);

    _dataInicial = null;
    _dataFinal = null;
    _dataApresentacao = null;
    _tipoCalculo = TipoCalculo.porSemestre;
    dataInicialError = null;
    dataFinalError = null;
    dateRangeError = null;
    cargaSimError = null;
    artefatosError = null;
    dataApresentacaoError = null;
  }

  // ─── Persistência ───────────────────────────────────────────────────────────

  Future<AtividadeModel> salvar() {
    double horas;
    if (showCalculoFields) {
      horas = totalHorasCalculo;
    } else if (showCargaX3Fields) {
      horas = totalHorasCargaX3;
    } else {
      horas = totalHorasArtefatos;
    }

    final atividade = AtividadeModel(
      natureza: 'ensino',
      classificacao: _classificacao!.label,
      tipo: _tipo!.label,
      titulo: tituloController.text.trim(),
      horasCalculadas: horas,
      dataCriacao: DateTime.now(),
      dataInicial: _dataInicial,
      dataFinal: _dataFinal ?? _dataApresentacao,
    );
    return _repo.salvar(atividade);
  }

  // ─── Validação ──────────────────────────────────────────────────────────────

  bool validate() {
    final formValid = formKey.currentState?.validate() ?? false;

    classificacaoError =
        _classificacao == null ? 'Selecione uma classificação' : null;
    tipoError = _tipo == null ? 'Selecione um tipo' : null;

    if (showCalculoFields) {
      cargaSimError = null;
      artefatosError = null;
      dataApresentacaoError = null;
      dataInicialError =
          _dataInicial == null ? 'Selecione a data inicial' : null;
      dataFinalError = _dataFinal == null ? 'Selecione a data final' : null;
      dateRangeError = null;

      if (_dataFinal != null && _dataFinal!.isAfter(DateTime.now())) {
        dataFinalError = 'Data final não pode ser no futuro';
      } else if (_dataInicial != null && _dataFinal != null) {
        if (!_dataFinal!.isAfter(_dataInicial!)) {
          dataFinalError = 'Data final deve ser após a data inicial';
        } else if (_tipoCalculo == TipoCalculo.porSemestre) {
          final semestres =
              int.tryParse(semestresController.text.trim()) ?? 0;
          if (semestres > 0) {
            final minDias = semestres * 180;
            final diasReais =
                _dataFinal!.difference(_dataInicial!).inDays;
            if (diasReais < minDias) {
              dateRangeError = 'O período informado é menor que $semestres '
                  'semestre(s). São necessários pelo menos '
                  '${semestres * 6} meses (≈ ${semestres * 180} dias).';
            }
          }
        }
      }
    } else if (showCargaX3Fields) {
      dataInicialError = null;
      dataFinalError = null;
      dateRangeError = null;
      artefatosError = null;
      final carga = double.tryParse(cargaSimController.text.trim());
      cargaSimError =
          (carga == null || carga <= 0) ? 'Informe a carga horária' : null;
      if (_dataApresentacao == null) {
        dataApresentacaoError = 'Selecione a data de apresentação';
      } else if (_dataApresentacao!.isAfter(DateTime.now())) {
        dataApresentacaoError = 'Data de apresentação não pode ser no futuro';
      } else {
        dataApresentacaoError = null;
      }
    } else if (showArtefatosFields) {
      dataInicialError = null;
      dataFinalError = null;
      dateRangeError = null;
      cargaSimError = null;
      final n = int.tryParse(artefatosController.text.trim());
      artefatosError =
          (n == null || n <= 0) ? 'Informe a quantidade de artefatos' : null;
      if (_dataApresentacao == null) {
        dataApresentacaoError = 'Selecione a data de apresentação';
      } else if (_dataApresentacao!.isAfter(DateTime.now())) {
        dataApresentacaoError = 'Data de apresentação não pode ser no futuro';
      } else {
        dataApresentacaoError = null;
      }
    } else {
      cargaSimError = null;
      artefatosError = null;
      dataApresentacaoError = null;
      dataInicialError = null;
      dataFinalError = null;
      dateRangeError = null;
    }

    final customValid = classificacaoError == null &&
        tipoError == null &&
        dataInicialError == null &&
        dataFinalError == null &&
        dateRangeError == null &&
        cargaSimError == null &&
        artefatosError == null &&
        dataApresentacaoError == null;

    notifyListeners();
    return formValid && customValid;
  }

  @override
  void dispose() {
    tituloController.dispose();
    semestresController.dispose();
    cargaHorariaController.dispose();
    cargaSimController.dispose();
    artefatosController.dispose();
    super.dispose();
  }
}
