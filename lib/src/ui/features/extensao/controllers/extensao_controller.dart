import 'package:flutter/material.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';
import 'package:controle_horas/src/data/repositories/atividade_repository.dart';
import 'package:controle_horas/src/shared/models/tipo_calculo.dart';
export 'package:controle_horas/src/shared/models/tipo_calculo.dart';

// ─── Classificações ───────────────────────────────────────────────────────────

enum ExtensaoClassificacao {
  cursoDeExtensao,
  programaDeExtensao,
  projetoDeExtensao,
  eventoDeExtensao,
  produtoDeExtensao,
  prestacaoDeServico;

  String get label => switch (this) {
        ExtensaoClassificacao.cursoDeExtensao => 'Curso de Extensão',
        ExtensaoClassificacao.programaDeExtensao => 'Programa de Extensão',
        ExtensaoClassificacao.projetoDeExtensao => 'Projeto de Extensão',
        ExtensaoClassificacao.eventoDeExtensao => 'Evento de Extensão',
        ExtensaoClassificacao.produtoDeExtensao => 'Produto de Extensão',
        ExtensaoClassificacao.prestacaoDeServico => 'Prestação de Serviço',
      };
}

// ─── Tipos ────────────────────────────────────────────────────────────────────

enum ExtensaoTipo {
  // Curso de Extensão
  competicoes,
  cursoMinicursoOficina,
  palestra,
  defesaMonografica,
  // Programa / Projeto
  programa,
  projeto,
  // Evento de Extensão
  eventoLocal,
  eventoNacional,
  eventoInternacional,
  // Produto / Prestação de Serviço
  produto,
  prestacaoDeServico,
  participacaoEmEleicao;

  String get label => switch (this) {
        ExtensaoTipo.competicoes => 'Competições',
        ExtensaoTipo.cursoMinicursoOficina => 'Curso/Minicurso/Oficina',
        ExtensaoTipo.palestra => 'Palestra',
        ExtensaoTipo.defesaMonografica => 'Defesa de Trabalho Monográfico',
        ExtensaoTipo.programa => 'Programa de Extensão',
        ExtensaoTipo.projeto => 'Projeto de Extensão',
        ExtensaoTipo.eventoLocal => 'Local / Regional',
        ExtensaoTipo.eventoNacional => 'Nacional',
        ExtensaoTipo.eventoInternacional => 'Internacional',
        ExtensaoTipo.produto => 'Produto de Extensão',
        ExtensaoTipo.prestacaoDeServico => 'Prestação de Serviço',
        ExtensaoTipo.participacaoEmEleicao => 'Participação em Eleição',
      };

  double get horas => switch (this) {
        ExtensaoTipo.eventoLocal => 15.0,
        ExtensaoTipo.eventoNacional => 30.0,
        ExtensaoTipo.eventoInternacional => 45.0,
        _ => 0.0,
      };

  String get horasLabel => switch (this) {
        ExtensaoTipo.eventoLocal => '15h',
        ExtensaoTipo.eventoNacional => '30h',
        ExtensaoTipo.eventoInternacional => '45h',
        _ => '',
      };
}

// ─── Participação em Evento ───────────────────────────────────────────────────

enum EventoParticipacao {
  participante,
  palestrante,
  apresentador,
  ministrante,
  moderador;

  String get label => switch (this) {
        EventoParticipacao.participante => 'Participante',
        EventoParticipacao.palestrante => 'Palestrante / Conferencista',
        EventoParticipacao.apresentador => 'Apresentador de Trabalho',
        EventoParticipacao.ministrante => 'Ministrante de Minicurso',
        EventoParticipacao.moderador => 'Moderador / Debatedor',
      };
}

// ─── Controller ───────────────────────────────────────────────────────────────

class ExtensaoController extends ChangeNotifier {
  final AtividadeRepository _repo;

  ExtensaoController(this._repo) {
    semestresController.addListener(notifyListeners);
    cargaHorariaController.addListener(notifyListeners);
    cargaSimController.addListener(notifyListeners);
    artefatosController.addListener(notifyListeners);
  }

  final formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();

  // Segmented calc (Programa / Projeto)
  final semestresController = TextEditingController();
  final cargaHorariaController = TextEditingController();

  // Carga simples (Curso)
  final cargaSimController = TextEditingController();

  // Produto / Prestação de Serviço
  final artefatosController = TextEditingController();

  ExtensaoClassificacao? _classificacao;
  ExtensaoTipo? _tipo;
  TipoCalculo _tipoCalculo = TipoCalculo.porSemestre;
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  DateTime? _dataApresentacao;

  // Evento de Extensão
  EventoParticipacao? _participacao;
  bool _participouComissao = false;

  // Participação em Eleição
  bool _treinamento = false;
  bool _primeiroTurno = false;
  bool _segundoTurno = false;

  // ── Erros ────────────────────────────────────────────────────────────────────
  String? classificacaoError;
  String? tipoError;
  String? cargaSimError;
  String? artefatosError;
  String? dataInicialError;
  String? dataFinalError;
  String? dataApresentacaoError;
  String? dateRangeError;
  String? participacaoError;
  String? elecaoTurnoError;

  // ─── Getters ────────────────────────────────────────────────────────────────

  ExtensaoClassificacao? get classificacao => _classificacao;
  ExtensaoTipo? get tipo => _tipo;
  TipoCalculo get tipoCalculo => _tipoCalculo;
  DateTime? get dataInicial => _dataInicial;
  DateTime? get dataFinal => _dataFinal;
  DateTime? get dataApresentacao => _dataApresentacao;
  EventoParticipacao? get participacao => _participacao;
  bool get participouComissao => _participouComissao;
  bool get treinamento => _treinamento;
  bool get primeiroTurno => _primeiroTurno;
  bool get segundoTurno => _segundoTurno;

  /// Exibe dropdown de Tipo para Curso e Prestação de Serviço
  bool get showTipoField =>
      _classificacao == ExtensaoClassificacao.cursoDeExtensao ||
      _classificacao == ExtensaoClassificacao.prestacaoDeServico;

  /// Programa / Projeto → segmented + datas ini/fin
  bool get showCalculoFields =>
      _tipo == ExtensaoTipo.programa || _tipo == ExtensaoTipo.projeto;

  /// Curso de Extensão → carga × 1 + datas ini/fin
  bool get showCargaFields =>
      _tipo == ExtensaoTipo.competicoes ||
      _tipo == ExtensaoTipo.cursoMinicursoOficina ||
      _tipo == ExtensaoTipo.palestra ||
      _tipo == ExtensaoTipo.defesaMonografica;

  /// Evento de Extensão → radio tipo + participação + comissão + datas
  bool get showEventoFields =>
      _classificacao == ExtensaoClassificacao.eventoDeExtensao;

  /// Produto / Prestação de Serviço → artefatos × 15 + data de apresentação
  bool get showProdutoFields =>
      _tipo == ExtensaoTipo.produto ||
      _tipo == ExtensaoTipo.prestacaoDeServico;

  /// Participação em Eleição → checkboxes de turnos + total × 2 + data
  bool get showElecaoFields => _tipo == ExtensaoTipo.participacaoEmEleicao;

  /// Total para segmented: max(semestres×60, carga÷4)
  double get totalHorasCalculo {
    final s = int.tryParse(semestresController.text.trim()) ?? 0;
    final fromSemestres = s * 60.0;
    final h = double.tryParse(cargaHorariaController.text.trim()) ?? 0.0;
    final fromCarga = h / 4.0;
    return fromSemestres > fromCarga ? fromSemestres : fromCarga;
  }

  /// Total para Curso de Extensão: carga × 1 (1h assistida = 1h/a)
  double get totalHorasCurso {
    return double.tryParse(cargaSimController.text.trim()) ?? 0.0;
  }

  /// Total para Evento: tipo.horas + (comissão organizadora ? +15 : 0)
  double get totalHorasEvento {
    if (_tipo == null) return 0;
    return _tipo!.horas + (_participouComissao ? 15.0 : 0.0);
  }

  /// Total para Produto / Prestação: artefatos × 15
  double get totalHorasArtefatos {
    final n = int.tryParse(artefatosController.text.trim()) ?? 0;
    return n * 15.0;
  }

  /// Total para Eleição: (horas dos turnos selecionados) × 2
  double get totalHorasEleicao {
    double base = 0;
    if (_treinamento) base += 4;
    if (_primeiroTurno) base += 12;
    if (_segundoTurno) base += 12;
    return base * 2;
  }

  String get tituloHint {
    if (_classificacao == null) return 'Ex: Título da atividade';
    if (_tipo == ExtensaoTipo.participacaoEmEleicao) {
      return 'Ex: Mesário - Eleições 2026';
    }
    if (_tipo == ExtensaoTipo.competicoes) {
      return 'Ex: Campeonato Universitário de Programação';
    }
    if (_tipo == ExtensaoTipo.cursoMinicursoOficina) {
      return 'Ex: Minicurso de Python para Iniciantes';
    }
    if (_tipo == ExtensaoTipo.palestra) {
      return 'Ex: Palestra sobre Inteligência Artificial';
    }
    if (_tipo == ExtensaoTipo.defesaMonografica) {
      return 'Ex: Defesa de TCC - Nome do Autor';
    }
    return switch (_classificacao!) {
      ExtensaoClassificacao.cursoDeExtensao =>
        'Ex: Curso de Extensão em Inclusão Digital',
      ExtensaoClassificacao.programaDeExtensao =>
        'Ex: Programa de Extensão em Inclusão Digital',
      ExtensaoClassificacao.projetoDeExtensao =>
        'Ex: Projeto de Extensão em Saúde Comunitária',
      ExtensaoClassificacao.eventoDeExtensao =>
        'Ex: Evento de Tecnologia',
      ExtensaoClassificacao.produtoDeExtensao =>
        'Ex: Aplicativo de Gestão de Resíduos',
      ExtensaoClassificacao.prestacaoDeServico =>
        'Ex: Consultoria em TI para ONG',
    };
  }

  List<ExtensaoTipo> get tiposDisponiveis {
    if (_classificacao == null) return [];
    return switch (_classificacao!) {
      ExtensaoClassificacao.cursoDeExtensao => [
          ExtensaoTipo.competicoes,
          ExtensaoTipo.cursoMinicursoOficina,
          ExtensaoTipo.palestra,
          ExtensaoTipo.defesaMonografica,
        ],
      ExtensaoClassificacao.programaDeExtensao => [ExtensaoTipo.programa],
      ExtensaoClassificacao.projetoDeExtensao => [ExtensaoTipo.projeto],
      ExtensaoClassificacao.eventoDeExtensao => [
          ExtensaoTipo.eventoLocal,
          ExtensaoTipo.eventoNacional,
          ExtensaoTipo.eventoInternacional,
        ],
      ExtensaoClassificacao.produtoDeExtensao => [ExtensaoTipo.produto],
      ExtensaoClassificacao.prestacaoDeServico => [
          ExtensaoTipo.prestacaoDeServico,
          ExtensaoTipo.participacaoEmEleicao,
        ],
    };
  }

  // ─── Setters ────────────────────────────────────────────────────────────────

  void setClassificacao(ExtensaoClassificacao value) {
    _classificacao = value;
    _tipo = null;
    classificacaoError = null;
    tipoError = null;
    _resetCalculoFields();
    // Auto-seleciona quando há apenas um tipo
    final tipos = tiposDisponiveis;
    if (tipos.length == 1) _tipo = tipos.first;
    notifyListeners();
  }

  void setTipo(ExtensaoTipo value) {
    _tipo = value;
    tipoError = null;
    // Não reseta campos ao trocar tipo de evento (apenas muda a seleção do radio)
    if (!showEventoFields) _resetCalculoFields();
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

  void setParticipacao(EventoParticipacao value) {
    _participacao = value;
    participacaoError = null;
    notifyListeners();
  }

  void setParticipouComissao(bool value) {
    _participouComissao = value;
    notifyListeners();
  }

  void setTreinamento(bool value) {
    _treinamento = value;
    elecaoTurnoError = null;
    notifyListeners();
  }

  void setPrimeiroTurno(bool value) {
    _primeiroTurno = value;
    elecaoTurnoError = null;
    notifyListeners();
  }

  void setSegundoTurno(bool value) {
    _segundoTurno = value;
    elecaoTurnoError = null;
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
    _participacao = null;
    _participouComissao = false;
    _treinamento = false;
    _primeiroTurno = false;
    _segundoTurno = false;
    cargaSimError = null;
    artefatosError = null;
    dataInicialError = null;
    dataFinalError = null;
    dataApresentacaoError = null;
    dateRangeError = null;
    participacaoError = null;
    elecaoTurnoError = null;
  }

  // ─── Persistência ───────────────────────────────────────────────────────────

  Future<AtividadeModel> salvar() {
    double horas;
    if (showCalculoFields) {
      horas = totalHorasCalculo;
    } else if (showCargaFields) {
      horas = totalHorasCurso;
    } else if (showEventoFields) {
      horas = totalHorasEvento;
    } else if (showProdutoFields) {
      horas = totalHorasArtefatos;
    } else {
      horas = totalHorasEleicao;
    }

    final atividade = AtividadeModel(
      natureza: 'extensao',
      classificacao: _classificacao!.label,
      tipo: _tipo?.label ?? _classificacao!.label,
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
    dateRangeError = null;

    if (showElecaoFields) {
      tipoError = null;
      participacaoError = null;
      cargaSimError = null;
      artefatosError = null;
      dataInicialError = null;
      dataFinalError = null;
      elecaoTurnoError = (!_treinamento && !_primeiroTurno && !_segundoTurno)
          ? 'Selecione pelo menos um turno'
          : null;
      dataApresentacaoError = _dataApresentacao == null
          ? 'Selecione a data de apresentação'
          : null;
    } else if (showProdutoFields) {
      tipoError = null;
      participacaoError = null;
      cargaSimError = null;
      elecaoTurnoError = null;
      dataInicialError = null;
      dataFinalError = null;
      final n = int.tryParse(artefatosController.text.trim());
      artefatosError =
          (n == null || n <= 0) ? 'Informe a quantidade de artefatos' : null;
      dataApresentacaoError = _dataApresentacao == null
          ? 'Selecione a data de apresentação'
          : null;
    } else if (showEventoFields) {
      tipoError = _tipo == null ? 'Selecione o tipo de evento' : null;
      participacaoError =
          _participacao == null ? 'Selecione a participação' : null;
      cargaSimError = null;
      artefatosError = null;
      elecaoTurnoError = null;
      dataApresentacaoError = null;
      dataInicialError =
          _dataInicial == null ? 'Selecione a data inicial' : null;
      dataFinalError = _dataFinal == null ? 'Selecione a data final' : null;
      if (_dataInicial != null && _dataFinal != null) {
        if (!_dataFinal!.isAfter(_dataInicial!)) {
          dataFinalError = 'Data final deve ser após a data inicial';
        }
      }
    } else {
      tipoError =
          (showTipoField && _tipo == null) ? 'Selecione um tipo' : null;
      participacaoError = null;
      artefatosError = null;
      elecaoTurnoError = null;
      dataApresentacaoError = null;
      dataInicialError =
          _dataInicial == null ? 'Selecione a data inicial' : null;
      dataFinalError = _dataFinal == null ? 'Selecione a data final' : null;

      if (showCargaFields) {
        final carga = double.tryParse(cargaSimController.text.trim());
        cargaSimError =
            (carga == null || carga <= 0) ? 'Informe a carga horária' : null;
      } else {
        cargaSimError = null;
      }

      if (_dataInicial != null && _dataFinal != null) {
        if (!_dataFinal!.isAfter(_dataInicial!)) {
          dataFinalError = 'Data final deve ser após a data inicial';
        } else if (showCalculoFields &&
            _tipoCalculo == TipoCalculo.porSemestre) {
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
    }

    final customValid = classificacaoError == null &&
        tipoError == null &&
        cargaSimError == null &&
        artefatosError == null &&
        elecaoTurnoError == null &&
        dataInicialError == null &&
        dataFinalError == null &&
        dataApresentacaoError == null &&
        dateRangeError == null &&
        participacaoError == null;

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
