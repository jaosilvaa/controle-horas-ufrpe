import 'package:controle_horas/src/data/database/database_service.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';

class AtividadeRepository {
  final DatabaseService _db;

  AtividadeRepository(this._db);

  Future<AtividadeModel> salvar(AtividadeModel atividade) =>
      _db.inserir(atividade);

  Future<List<AtividadeModel>> listarTodas() => _db.listarTodas();

  Future<List<AtividadeModel>> listarPorNatureza(String natureza) =>
      _db.listarPorNatureza(natureza);

  Future<AtividadeModel> atualizar(AtividadeModel atividade) =>
      _db.atualizar(atividade);

  Future<void> deletar(int id) => _db.deletar(id);
}
