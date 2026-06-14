import 'package:flutter/material.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';
import 'package:controle_horas/src/data/repositories/atividade_repository.dart';
import 'package:controle_horas/src/data/services/barema_service.dart';

class NaturezaListController extends ChangeNotifier {
  final AtividadeRepository _repo;
  final String natureza;

  NaturezaListController(this._repo, {required this.natureza});

  List<AtividadeModel> _atividades = [];
  bool _loading = true;

  List<AtividadeModel> get atividades => _atividades;
  bool get loading => _loading;

  /// Atividades agrupadas por classificação
  Map<String, List<AtividadeModel>> get porClassificacao {
    final map = <String, List<AtividadeModel>>{};
    for (final a in _atividades) {
      map.putIfAbsent(a.classificacao, () => []).add(a);
    }
    return map;
  }

  /// Classificações em ordem de inserção (primeira atividade de cada)
  List<String> get classificacoesOrdenadas => porClassificacao.keys.toList();

  /// Horas efetivas de uma classificação específica (com caps do barema)
  double horasEfetivasClassificacao(String classificacao) {
    final horas = (porClassificacao[classificacao] ?? [])
        .map((a) => a.horasCalculadas)
        .toList();
    return BaremaService.efetivoPorClassificacao(horas);
  }

  Future<void> carregar() async {
    _loading = true;
    notifyListeners();
    _atividades = await _repo.listarPorNatureza(natureza);
    _loading = false;
    notifyListeners();
  }

  Future<void> atualizar(AtividadeModel atividade) async {
    await _repo.atualizar(atividade);
    await carregar();
  }

  Future<void> deletar(int id) async {
    await _repo.deletar(id);
    await carregar();
  }
}
