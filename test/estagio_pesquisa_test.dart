import 'package:flutter_test/flutter_test.dart';
import 'package:controle_horas/src/data/database/database_service.dart';
import 'package:controle_horas/src/data/repositories/atividade_repository.dart';
import 'package:controle_horas/src/ui/features/pesquisa/controllers/pesquisa_controller.dart';

/// Regra oficial (Novo Barema AC, Quadro 5 — Pesquisa > Vivência
/// Profissional Complementar > Estágio):
/// "Por 6 meses com dedicação mínima de 20h semanais, contabilizam-se 60 h/a."
/// Limite máximo por classificação: 120h (BaremaService.maxPorClassificacao).
void main() {
  PesquisaController build() =>
      PesquisaController(AtividadeRepository(DatabaseService()));

  test('Estágio de 01/01/2026 até 01/01/2027 (12 meses) → 120h', () {
    final ctrl = build()
      ..setTipo(PesquisaTipo.estagio)
      ..setDataInicial(DateTime(2026, 1, 1))
      ..setDataFinal(DateTime(2027, 1, 1));

    expect(ctrl.totalHorasEstagio, 120);
    expect(ctrl.estagioAtingiuLimite, true);
  });

  test('Estágio de exatamente 6 meses (180 dias) → 60h', () {
    final ctrl = build()
      ..setTipo(PesquisaTipo.estagio)
      ..setDataInicial(DateTime(2026, 1, 1))
      ..setDataFinal(DateTime(2026, 1, 1).add(const Duration(days: 180)));

    expect(ctrl.totalHorasEstagio, 60);
  });

  test('Estágio com 8 meses (241 dias) → ainda 60h (só conta bloco cheio de 6 meses)', () {
    final ctrl = build()
      ..setTipo(PesquisaTipo.estagio)
      ..setDataInicial(DateTime(2026, 2, 1))
      ..setDataFinal(DateTime(2026, 9, 30));

    expect(ctrl.totalHorasEstagio, 60);
  });

  test('Estágio com 18 meses → clampa em 120h (limite máximo), não 180h', () {
    final ctrl = build()
      ..setTipo(PesquisaTipo.estagio)
      ..setDataInicial(DateTime(2026, 1, 1))
      ..setDataFinal(DateTime(2027, 7, 1)); // ~547 dias = 3 blocos de 180

    expect(ctrl.totalHorasEstagio, 120);
  });
}
