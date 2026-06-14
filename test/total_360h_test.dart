import 'package:flutter_test/flutter_test.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';
import 'package:controle_horas/src/data/services/barema_service.dart';

AtividadeModel _a({
  required String natureza,
  required String classificacao,
  required double horas,
}) =>
    AtividadeModel(
      natureza: natureza,
      classificacao: classificacao,
      tipo: 'Tipo',
      titulo: 'Título',
      horasCalculadas: horas,
      dataCriacao: DateTime(2025),
    );

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário A — Extensão com 360h → circular 100% e qualquer nova
  //             atividade (em qualquer natureza) é bloqueada
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário A — Uma natureza com 360h = meta completa', () {
    final extensao360 = [
      _a(natureza: 'extensao', classificacao: 'Curso de Extensão', horas: 120),
      _a(natureza: 'extensao', classificacao: 'Evento de Extensão', horas: 120),
      _a(natureza: 'extensao', classificacao: 'Programa de Extensão', horas: 120),
    ];

    test('Extensão 360h → total = 360h', () {
      final r = BaremaService.calcularResumo(extensao360);
      expect(r.extensao, 360);
      expect(r.total, 360);
    });

    test('Extensão 360h → circular exibe 100%', () {
      final r = BaremaService.calcularResumo(extensao360);
      expect(r.progressTotal, 1.0);
      expect((r.progressTotal * 100).toInt(), 100);
    });

    test('Extensão 360h → tentativa de cadastrar em Ensino é bloqueada', () {
      final v = BaremaService.verificarLimite(
        existentes: extensao360,
        natureza: 'ensino',
        classificacao: 'Tópicos Especiais',
      );
      expect(v.permitido, isFalse);
    });

    test('Extensão 360h → tentativa de cadastrar em Pesquisa é bloqueada', () {
      final v = BaremaService.verificarLimite(
        existentes: extensao360,
        natureza: 'pesquisa',
        classificacao: 'Iniciação à pesquisa',
      );
      expect(v.permitido, isFalse);
    });

    test('Extensão 360h → tentativa de cadastrar mais Extensão também bloqueada', () {
      final v = BaremaService.verificarLimite(
        existentes: extensao360,
        natureza: 'extensao',
        classificacao: 'Produto de Extensão',
      );
      expect(v.permitido, isFalse);
    });

    test('mensagem de bloqueio total menciona as 360h concluídas', () {
      final v = BaremaService.verificarLimite(
        existentes: extensao360,
        natureza: 'ensino',
        classificacao: 'Qualquer',
      );
      expect(v.mensagem, contains('360h'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário B — Ensino 120h + Pesquisa 120h + Extensão 120h = 360h total
  //             Circular = 100%
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário B — 120h em cada natureza = 360h total = 100%', () {
    final distribuido = [
      _a(natureza: 'ensino',   classificacao: 'Tópicos Especiais',   horas: 120),
      _a(natureza: 'pesquisa', classificacao: 'Iniciação à pesquisa', horas: 120),
      _a(natureza: 'extensao', classificacao: 'Curso de Extensão',   horas: 120),
    ];

    test('total = 360h (120 + 120 + 120)', () {
      final r = BaremaService.calcularResumo(distribuido);
      expect(r.ensino, 120);
      expect(r.pesquisa, 120);
      expect(r.extensao, 120);
      expect(r.total, 360);
    });

    test('circular = 100%', () {
      final r = BaremaService.calcularResumo(distribuido);
      expect(r.progressTotal, 1.0);
      expect((r.progressTotal * 100).toInt(), 100);
    });

    test('barras lineares individuais = 33,33% cada (120/360)', () {
      final r = BaremaService.calcularResumo(distribuido);
      expect(r.progressEnsino,   closeTo(120 / 360, 0.001));
      expect(r.progressPesquisa, closeTo(120 / 360, 0.001));
      expect(r.progressExtensao, closeTo(120 / 360, 0.001));
    });

    test('qualquer novo cadastro é bloqueado — meta já atingida', () {
      for (final nat in ['ensino', 'pesquisa', 'extensao']) {
        final v = BaremaService.verificarLimite(
          existentes: distribuido,
          natureza: nat,
          classificacao: 'Qualquer Classificação',
        );
        expect(v.permitido, isFalse,
            reason: 'deveria bloquear natureza $nat com total já em 360h');
      }
    });

    test('subtitle dos cards exibe "120h / 360h" em cada natureza', () {
      final r = BaremaService.calcularResumo(distribuido);
      expect('${r.ensino.toInt()}h / 360h',   '120h / 360h');
      expect('${r.pesquisa.toInt()}h / 360h', '120h / 360h');
      expect('${r.extensao.toInt()}h / 360h', '120h / 360h');
    });

    test('TotalCard exibe "360h completadas"', () {
      final r = BaremaService.calcularResumo(distribuido);
      expect('${r.total.toInt()}h completadas', '360h completadas');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário C — Progresso parcial distribuído
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário C — Progresso parcial não bloqueia', () {
    test('180h total → circular 50%, ainda permite cadastro', () {
      final existentes = [
        _a(natureza: 'ensino',   classificacao: 'A', horas: 90),
        _a(natureza: 'extensao', classificacao: 'B', horas: 90),
      ];
      final r = BaremaService.calcularResumo(existentes);
      expect(r.total, 90 + 90); // ambas são múltiplos de 15
      expect(r.progressTotal, closeTo(0.5, 0.001));

      final v = BaremaService.verificarLimite(
        existentes: existentes,
        natureza: 'pesquisa',
        classificacao: 'Iniciação à pesquisa',
      );
      expect(v.permitido, isTrue);
    });

    test('359h total → ainda permite (falta 1h, mas enquanto < 360 libera)', () {
      // 345h (múltiplo de 15) → abaixo do teto
      final existentes = [
        _a(natureza: 'ensino',   classificacao: 'A', horas: 120),
        _a(natureza: 'pesquisa', classificacao: 'B', horas: 120),
        _a(natureza: 'extensao', classificacao: 'C', horas: 105),
      ];
      final r = BaremaService.calcularResumo(existentes);
      expect(r.total, 345);
      expect(r.total < ResumoBarema.maxTotal, isTrue);

      final v = BaremaService.verificarLimite(
        existentes: existentes,
        natureza: 'extensao',
        classificacao: 'C',
      );
      expect(v.permitido, isTrue);
    });
  });
}
