import 'package:flutter/material.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';
import 'package:controle_horas/src/data/repositories/atividade_repository.dart';
import 'package:controle_horas/src/data/services/barema_service.dart';

class HomeController extends ChangeNotifier {
  final AtividadeRepository _repo;

  HomeController(this._repo);

  List<AtividadeModel> _atividades = [];
  ResumoBarema _resumo = const ResumoBarema(
    ensino: 0,
    pesquisa: 0,
    extensao: 0,
    total: 0,
  );
  bool _loading = true;

  List<AtividadeModel> get atividades => _atividades;
  ResumoBarema get resumo => _resumo;
  bool get loading => _loading;

  Future<void> carregar() async {
    _loading = true;
    notifyListeners();
    _atividades = await _repo.listarTodas();
    _resumo = BaremaService.calcularResumo(_atividades);
    _loading = false;
    notifyListeners();
  }

  Future<void> deletar(int id) async {
    await _repo.deletar(id);
    await carregar();
  }
}
