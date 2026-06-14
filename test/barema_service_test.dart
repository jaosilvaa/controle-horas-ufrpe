import 'package:flutter_test/flutter_test.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';
import 'package:controle_horas/src/data/services/barema_service.dart';

AtividadeModel _a({
  required String natureza,
  required String classificacao,
  required String tipo,
  required double horas,
}) =>
    AtividadeModel(
      natureza: natureza,
      classificacao: classificacao,
      tipo: tipo,
      titulo: 'Teste',
      horasCalculadas: horas,
      dataCriacao: DateTime(2025),
    );

void main() {
  // ── Regra: múltiplo de 15 por classificação ────────────────────────────────
  group('efetivoPorClassificacao', () {
    test('arredonda para baixo para múltiplo de 15', () {
      // 132h → floor(132/15)*15 = 120h (também bate no limite máximo)
      expect(BaremaService.efetivoPorClassificacao([72, 60]), 120);
    });

    test('99h → 90h (floor para múltiplo de 15)', () {
      expect(BaremaService.efetivoPorClassificacao([99]), 90);
    });

    test('24 + 15 + 60 = 99h → 90h', () {
      // Exemplo do usuário: ministrando minicurso 8h×3=24, prática 15h, projeto 60h
      expect(BaremaService.efetivoPorClassificacao([24, 15, 60]), 90);
    });

    test('exatamente 120h → 120h (no limite)', () {
      expect(BaremaService.efetivoPorClassificacao([60, 60]), 120);
    });

    test('140h → 120h (capped)', () {
      // 140 → floor(140/15)*15 = 135 → clamp a 120
      expect(BaremaService.efetivoPorClassificacao([72, 68]), 120);
    });

    test('30h → 30h (múltiplo exato)', () {
      expect(BaremaService.efetivoPorClassificacao([30]), 30);
    });

    test('20h → 15h (arredonda para baixo)', () {
      // Evento local: 20h reais mas só conta 15h.
      // Já é armazenado como 15h; mas testando 20h bruto: floor(20/15)*15=15
      expect(BaremaService.efetivoPorClassificacao([20]), 15);
    });

    test('lista vazia → 0h', () {
      expect(BaremaService.efetivoPorClassificacao([]), 0);
    });
  });

  // ── Regra: limite de 360h por natureza ────────────────────────────────────
  group('efetivoPorNatureza', () {
    test('soma 3 classificações respeitando 120h cada → 360h', () {
      final atividades = [
        _a(natureza: 'ensino', classificacao: 'A', tipo: 't', horas: 120),
        _a(natureza: 'ensino', classificacao: 'B', tipo: 't', horas: 120),
        _a(natureza: 'ensino', classificacao: 'C', tipo: 't', horas: 120),
      ];
      expect(BaremaService.efetivoPorNatureza(atividades), 360);
    });

    test('não ultrapassa 360h mesmo com mais atividades', () {
      final atividades = [
        _a(natureza: 'ensino', classificacao: 'A', tipo: 't', horas: 200),
        _a(natureza: 'ensino', classificacao: 'B', tipo: 't', horas: 200),
        _a(natureza: 'ensino', classificacao: 'C', tipo: 't', horas: 200),
      ];
      expect(BaremaService.efetivoPorNatureza(atividades), 360);
    });

    test('classificação com 99h conta como 90h, soma correta', () {
      // Tópicos Especiais: 24+15+60=99 → 90h
      final atividades = [
        _a(natureza: 'ensino', classificacao: 'Tópicos Especiais', tipo: 'Cursos', horas: 24),
        _a(natureza: 'ensino', classificacao: 'Tópicos Especiais', tipo: 'Prática Integrada', horas: 15),
        _a(natureza: 'ensino', classificacao: 'Tópicos Especiais', tipo: 'Projeto de Ensino', horas: 60),
      ];
      expect(BaremaService.efetivoPorNatureza(atividades), 90);
    });

    test('lista vazia → 0h', () {
      expect(BaremaService.efetivoPorNatureza([]), 0);
    });
  });

  // ── Regra: exemplo do usuário (Extensão - Curso de Extensão) ──────────────
  group('Caso Extensão: Curso de Extensão', () {
    test('PowerBI 72h + Python 60h = 132h → 120h (limite classificação)', () {
      final atividades = [
        _a(natureza: 'extensao', classificacao: 'Curso de Extensão', tipo: 'Curso/Minicurso/Oficina', horas: 72),
        _a(natureza: 'extensao', classificacao: 'Curso de Extensão', tipo: 'Curso/Minicurso/Oficina', horas: 60),
      ];
      expect(BaremaService.efetivoPorNatureza(atividades), 120);
    });
  });

  // ── calcularResumo ─────────────────────────────────────────────────────────
  group('calcularResumo', () {
    test('agrupa por natureza corretamente', () {
      final atividades = [
        _a(natureza: 'ensino', classificacao: 'A', tipo: 't', horas: 60),
        _a(natureza: 'pesquisa', classificacao: 'B', tipo: 't', horas: 30),
        _a(natureza: 'extensao', classificacao: 'C', tipo: 't', horas: 45),
      ];
      final resumo = BaremaService.calcularResumo(atividades);
      expect(resumo.ensino, 60);
      expect(resumo.pesquisa, 30);
      expect(resumo.extensao, 45);
      expect(resumo.total, 135);
    });

    test('progresso total correto (135 / 360 = meta do curso)', () {
      final atividades = [
        _a(natureza: 'ensino', classificacao: 'A', tipo: 't', horas: 60),
        _a(natureza: 'pesquisa', classificacao: 'B', tipo: 't', horas: 30),
        _a(natureza: 'extensao', classificacao: 'C', tipo: 't', horas: 45),
      ];
      final resumo = BaremaService.calcularResumo(atividades);
      expect(resumo.progressTotal, closeTo(135 / 360, 0.001));
    });

    test('banco vazio → tudo zero', () {
      final resumo = BaremaService.calcularResumo([]);
      expect(resumo.ensino, 0);
      expect(resumo.pesquisa, 0);
      expect(resumo.extensao, 0);
      expect(resumo.total, 0);
      expect(resumo.progressTotal, 0);
    });
  });

  // ── AtividadeModel serialização ───────────────────────────────────────────
  group('AtividadeModel serialização', () {
    test('toMap / fromMap round-trip', () {
      final original = AtividadeModel(
        id: 1,
        natureza: 'ensino',
        classificacao: 'Tópicos Especiais',
        tipo: 'Cursos',
        titulo: 'Curso de Python',
        horasCalculadas: 24,
        dataCriacao: DateTime(2025, 6, 7),
        dataInicial: DateTime(2025, 3, 1),
        dataFinal: DateTime(2025, 6, 30),
      );
      final restored = AtividadeModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.natureza, original.natureza);
      expect(restored.classificacao, original.classificacao);
      expect(restored.tipo, original.tipo);
      expect(restored.titulo, original.titulo);
      expect(restored.horasCalculadas, original.horasCalculadas);
      expect(restored.dataCriacao, original.dataCriacao);
      expect(restored.dataInicial, original.dataInicial);
      expect(restored.dataFinal, original.dataFinal);
    });

    test('campos de data opcionais nulos sobrevivem ao round-trip', () {
      final original = AtividadeModel(
        natureza: 'pesquisa',
        classificacao: 'Iniciação à pesquisa',
        tipo: 'Publicação Técnico-Científica',
        titulo: 'Artigo Qualis A',
        horasCalculadas: 120,
        dataCriacao: DateTime(2025, 6, 7),
      );
      final restored = AtividadeModel.fromMap(original.toMap());
      expect(restored.dataInicial, isNull);
      expect(restored.dataFinal, isNull);
    });
  });
}
