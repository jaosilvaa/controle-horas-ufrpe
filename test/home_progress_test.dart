import 'package:flutter_test/flutter_test.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';
import 'package:controle_horas/src/data/services/barema_service.dart';

// ─── Helper ───────────────────────────────────────────────────────────────────

AtividadeModel _at({
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
  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário 1 — Extensão > Curso de Extensão
  // PowerBI 72h + Python 60h = 132h → conta só 120h (limite classificação)
  // Progresso Extensão = 120 / 360 = 33,33 %
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário 1 — Extensão: PowerBI 72h + Python 60h', () {
    final atividades = [
      _at(
        natureza: 'extensao',
        classificacao: 'Curso de Extensão',
        tipo: 'Curso/Minicurso/Oficina',
        horas: 72,
      ),
      _at(
        natureza: 'extensao',
        classificacao: 'Curso de Extensão',
        tipo: 'Curso/Minicurso/Oficina',
        horas: 60,
      ),
    ];

    late ResumoBarema resumo;
    setUp(() => resumo = BaremaService.calcularResumo(atividades));

    test('horas brutas somam 132h mas só contam 120h (limite classificação)', () {
      expect(resumo.extensao, 120);
    });

    test('progresso Extensão = 120/360 ≈ 33,33%', () {
      expect(resumo.progressExtensao, closeTo(1 / 3, 0.001));
    });

    test('barra linear Extensão = 0.333... (valor para CategoryCard)', () {
      expect(resumo.progressExtensao, closeTo(0.333, 0.001));
    });

    test('outras naturezas ficam em zero', () {
      expect(resumo.ensino, 0);
      expect(resumo.pesquisa, 0);
    });

    test('adicionar 3º certificado não muda nada — classificação já estourada', () {
      final com3 = [
        ...atividades,
        _at(
          natureza: 'extensao',
          classificacao: 'Curso de Extensão',
          tipo: 'Curso/Minicurso/Oficina',
          horas: 40,
        ),
      ];
      final r = BaremaService.calcularResumo(com3);
      expect(r.extensao, 120);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário 2 — Ensino > Tópicos Especiais: Projeto de Ensino 300h dedicação
  // Por carga: 300h / 4 = 75h (calculado no controller, armazena 75h)
  // Barema: 75h → floor(75/15)*15 = 75h (múltiplo exato) ✓
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário 2 — Ensino: Projeto de Ensino 300h dedicação → 75h', () {
    // O controller calcula 300/4=75h e armazena 75h como horasCalculadas
    final atividades = [
      _at(
        natureza: 'ensino',
        classificacao: 'Tópicos Especiais',
        tipo: 'Projeto de Ensino',
        horas: 75, // 300h dedicação ÷ 4
      ),
    ];

    late ResumoBarema resumo;
    setUp(() => resumo = BaremaService.calcularResumo(atividades));

    test('75h é múltiplo de 15 → conta 75h inteiras', () {
      expect(resumo.ensino, 75);
    });

    test('progresso Ensino = 75/360 ≈ 20,83%', () {
      expect(resumo.progressEnsino, closeTo(75 / 360, 0.001));
    });

    test('barra linear Ensino exibe valor correto para CategoryCard', () {
      expect(resumo.progressEnsino, closeTo(0.208, 0.001));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário 3 — Ensino > Tópicos Especiais: 24 + 15 + 60 = 99h → 90h
  // Ministrando minicurso 8h × 3 = 24h
  // Prática Integrada = 15h
  // Projeto de Ensino 6 meses = 60h
  // Total bruto = 99h → múltiplo de 15 → 90h
  // Progresso Ensino = 90/360 = 25%
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário 3 — Ensino: minicurso 24h + prática 15h + projeto 60h = 99h → 90h', () {
    final atividades = [
      _at(
        natureza: 'ensino',
        classificacao: 'Tópicos Especiais',
        tipo: 'Cursos',
        horas: 24, // 8h ministradas × 3
      ),
      _at(
        natureza: 'ensino',
        classificacao: 'Tópicos Especiais',
        tipo: 'Prática Integrada',
        horas: 15,
      ),
      _at(
        natureza: 'ensino',
        classificacao: 'Tópicos Especiais',
        tipo: 'Projeto de Ensino',
        horas: 60, // 1 semestre
      ),
    ];

    late ResumoBarema resumo;
    setUp(() => resumo = BaremaService.calcularResumo(atividades));

    test('99h brutas → 90h efetivas (floor múltiplo de 15)', () {
      expect(resumo.ensino, 90);
    });

    test('progresso Ensino = 90/360 = 25%', () {
      expect(resumo.progressEnsino, closeTo(0.25, 0.001));
    });

    test('barra linear Ensino = 0.25', () {
      expect(resumo.progressEnsino, 0.25);
    });

    test('circular geral = 90/360 = 25%', () {
      expect(resumo.progressTotal, closeTo(90 / 360, 0.001));
    });

    test('percentual circular = 25% (toInt)', () {
      expect((resumo.progressTotal * 100).toInt(), 25);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário 4 — Extensão: Evento Local (JATI) 20h reais → 15h
  // Evento local tem teto de 15h por evento (já aplicado no controller)
  // Armazenado como 15h. Barema: 15h múltiplo de 15 → 15h ✓
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário 4 — Extensão: JATI evento local 20h → armazena 15h', () {
    // Controller já armazena 15h (ExtensaoTipo.eventoLocal → 15h fixo)
    final atividades = [
      _at(
        natureza: 'extensao',
        classificacao: 'Evento de Extensão',
        tipo: 'Local / Regional',
        horas: 15, // evento local: fixo 15h
      ),
    ];

    late ResumoBarema resumo;
    setUp(() => resumo = BaremaService.calcularResumo(atividades));

    test('15h armazenadas → 15h efetivas (múltiplo exato)', () {
      expect(resumo.extensao, 15);
    });

    test('progresso Extensão = 15/360 ≈ 4,17%', () {
      expect(resumo.progressExtensao, closeTo(15 / 360, 0.001));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário 5 — Teto máximo: natureza não ultrapassa 360h
  // Barra linear deve ficar em 100% (1.0) quando bate 360h
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário 5 — Teto 360h por natureza', () {
    test('3 classificações com 120h cada = exatamente 360h', () {
      final atividades = [
        _at(natureza: 'ensino', classificacao: 'Iniciação à Docência', tipo: 'Monitoria', horas: 120),
        _at(natureza: 'ensino', classificacao: 'Discussões Temáticas', tipo: 'Discussões Temáticas', horas: 120),
        _at(natureza: 'ensino', classificacao: 'Tópicos Especiais', tipo: 'Cursos', horas: 120),
      ];
      final resumo = BaremaService.calcularResumo(atividades);
      expect(resumo.ensino, 360);
      expect(resumo.progressEnsino, 1.0); // barra 100%
    });

    test('mais de 360h bruto ainda resulta em 360h e barra 100%', () {
      final atividades = [
        _at(natureza: 'ensino', classificacao: 'Iniciação à Docência', tipo: 'Monitoria', horas: 200),
        _at(natureza: 'ensino', classificacao: 'Discussões Temáticas', tipo: 'Discussões Temáticas', horas: 200),
        _at(natureza: 'ensino', classificacao: 'Tópicos Especiais', tipo: 'Cursos', horas: 200),
      ];
      final resumo = BaremaService.calcularResumo(atividades);
      expect(resumo.ensino, 360);
      expect(resumo.progressEnsino, 1.0);
    });

    test('barra não passa de 1.0 mesmo com excesso', () {
      final atividades = List.generate(
        20,
        (i) => _at(natureza: 'extensao', classificacao: 'Classi$i', tipo: 't', horas: 120),
      );
      final resumo = BaremaService.calcularResumo(atividades);
      expect(resumo.progressExtensao, 1.0);
      expect(resumo.extensao, 360);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário 6 — Progresso visual completo (circular + barras lineares juntos)
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário 6 — Progresso visual: circular geral + 3 barras lineares', () {
    // Extensão: PowerBI 72h + Python 60h = 120h (cap classificação)
    // Ensino: minicurso 24h + prática 15h + projeto 60h = 99h → 90h
    // Pesquisa: vazio
    final atividades = [
      // Extensão
      _at(natureza: 'extensao', classificacao: 'Curso de Extensão', tipo: 'Curso/Minicurso/Oficina', horas: 72),
      _at(natureza: 'extensao', classificacao: 'Curso de Extensão', tipo: 'Curso/Minicurso/Oficina', horas: 60),
      // Ensino
      _at(natureza: 'ensino', classificacao: 'Tópicos Especiais', tipo: 'Cursos', horas: 24),
      _at(natureza: 'ensino', classificacao: 'Tópicos Especiais', tipo: 'Prática Integrada', horas: 15),
      _at(natureza: 'ensino', classificacao: 'Tópicos Especiais', tipo: 'Projeto de Ensino', horas: 60),
    ];

    late ResumoBarema resumo;
    setUp(() => resumo = BaremaService.calcularResumo(atividades));

    test('Extensão = 120h, Ensino = 90h, Pesquisa = 0h', () {
      expect(resumo.extensao, 120);
      expect(resumo.ensino, 90);
      expect(resumo.pesquisa, 0);
    });

    test('total = 210h', () {
      expect(resumo.total, 210);
    });

    // Barra linear Ensino (CategoryCard)
    test('barra Ensino = 90/360 = 25%', () {
      expect(resumo.progressEnsino, 0.25);
    });

    // Barra linear Extensão (CategoryCard)
    test('barra Extensão = 120/360 ≈ 33,33%', () {
      expect(resumo.progressExtensao, closeTo(1 / 3, 0.001));
    });

    // Barra linear Pesquisa (CategoryCard)
    test('barra Pesquisa = 0%', () {
      expect(resumo.progressPesquisa, 0.0);
    });

    // Circular geral (TotalCard)
    test('circular geral = 210/360 ≈ 58,33%', () {
      expect(resumo.progressTotal, closeTo(210 / 360, 0.001));
    });

    test('percentual circular exibido = 58%', () {
      expect((resumo.progressTotal * 100).toInt(), 58);
    });

    // Subtitle dos cards
    test('subtitle Ensino exibe "90h / 360h"', () {
      expect('${resumo.ensino.toInt()}h / 360h', '90h / 360h');
    });

    test('subtitle Extensão exibe "120h / 360h"', () {
      expect('${resumo.extensao.toInt()}h / 360h', '120h / 360h');
    });

    test('TotalCard exibe "210h completadas"', () {
      expect('${resumo.total.toInt()}h completadas', '210h completadas');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário 6b — Extensão com 360h → circular = 100%
  // "se extensão atingiu 360h o progresso total deve ser 100%"
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário 6b — Extensão 360h = circular 100%', () {
    test('uma natureza com 360h já bate o limite total do curso', () {
      final atividades = [
        _at(natureza: 'extensao', classificacao: 'Curso de Extensão', tipo: 't', horas: 120),
        _at(natureza: 'extensao', classificacao: 'Evento de Extensão', tipo: 't', horas: 120),
        _at(natureza: 'extensao', classificacao: 'Programa de Extensão', tipo: 't', horas: 120),
      ];
      final resumo = BaremaService.calcularResumo(atividades);
      expect(resumo.extensao, 360);
      expect(resumo.total, 360);
      expect(resumo.progressTotal, 1.0); // circular = 100%
      expect((resumo.progressTotal * 100).toInt(), 100);
    });

    test('progressTotal = total / 360 (meta do curso)', () {
      final r = ResumoBarema(ensino: 180, pesquisa: 0, extensao: 0, total: 180);
      expect(r.progressTotal, closeTo(180 / 360, 0.001)); // 50%
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Cenário 7 — progressEnsino nunca passa de 1.0 (barra não explode)
  // ═══════════════════════════════════════════════════════════════════════════
  group('Cenário 7 — Valores de progress sempre entre 0.0 e 1.0', () {
    test('progressEnsino clampado a 1.0', () {
      final r = ResumoBarema(ensino: 500, pesquisa: 0, extensao: 0, total: 500);
      expect(r.progressEnsino, 1.0);
    });

    test('progressPesquisa clampado a 1.0', () {
      final r = ResumoBarema(ensino: 0, pesquisa: 999, extensao: 0, total: 999);
      expect(r.progressPesquisa, 1.0);
    });

    test('progressExtensao clampado a 1.0', () {
      final r = ResumoBarema(ensino: 0, pesquisa: 0, extensao: 720, total: 720);
      expect(r.progressExtensao, 1.0);
    });

    test('progressTotal clampado a 1.0 quando total >= 360', () {
      final r = ResumoBarema(ensino: 360, pesquisa: 0, extensao: 0, total: 360);
      expect(r.progressTotal, 1.0);
    });

    test('todos zero → todos 0.0', () {
      final r = ResumoBarema(ensino: 0, pesquisa: 0, extensao: 0, total: 0);
      expect(r.progressEnsino, 0.0);
      expect(r.progressPesquisa, 0.0);
      expect(r.progressExtensao, 0.0);
      expect(r.progressTotal, 0.0);
    });
  });
}
