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
  // ── Caso base: sem atividades → sempre permitido ──────────────────────────
  group('Banco vazio', () {
    test('qualquer natureza/classificação é permitida', () {
      final v = BaremaService.verificarLimite(
        existentes: [],
        natureza: 'ensino',
        classificacao: 'Tópicos Especiais',
      );
      expect(v.permitido, isTrue);
      expect(v.mensagem, isNull);
    });
  });

  // ── Bloqueio por classificação (>= 120h) ──────────────────────────────────
  group('Bloqueio por classificação cheia', () {
    test('classificação com exatamente 120h → bloqueia', () {
      final existentes = [
        _a(natureza: 'extensao', classificacao: 'Curso de Extensão', horas: 72),
        _a(natureza: 'extensao', classificacao: 'Curso de Extensão', horas: 60),
        // 132h brutas → efetivo = 120h (cap classificação)
      ];
      final v = BaremaService.verificarLimite(
        existentes: existentes,
        natureza: 'extensao',
        classificacao: 'Curso de Extensão',
      );
      expect(v.permitido, isFalse);
    });

    test('mensagem menciona o limite de 120h e o nome da classificação', () {
      final existentes = [
        _a(natureza: 'extensao', classificacao: 'Curso de Extensão', horas: 120),
      ];
      final v = BaremaService.verificarLimite(
        existentes: existentes,
        natureza: 'extensao',
        classificacao: 'Curso de Extensão',
      );
      expect(v.mensagem, contains('120h'));
      expect(v.mensagem, contains('Curso de Extensão'));
    });

    test('mensagem sugere outra classificação ou natureza alternativa', () {
      final existentes = [
        _a(natureza: 'extensao', classificacao: 'Curso de Extensão', horas: 120),
      ];
      final v = BaremaService.verificarLimite(
        existentes: existentes,
        natureza: 'extensao',
        classificacao: 'Curso de Extensão',
      );
      // Deve sugerir Ensino ou Pesquisa como alternativa
      expect(v.mensagem, contains('Ensino'));
      expect(v.mensagem, contains('Pesquisa'));
    });

    test('outra classificação na mesma natureza ainda é permitida', () {
      final existentes = [
        _a(natureza: 'extensao', classificacao: 'Curso de Extensão', horas: 120),
      ];
      final v = BaremaService.verificarLimite(
        existentes: existentes,
        natureza: 'extensao',
        classificacao: 'Evento de Extensão', // classificação diferente
      );
      expect(v.permitido, isTrue);
    });

    test('PowerBI 72h + Python 60h = 120h efetivo → 3º certificado bloqueado', () {
      final existentes = [
        _a(natureza: 'extensao', classificacao: 'Curso de Extensão', horas: 72),
        _a(natureza: 'extensao', classificacao: 'Curso de Extensão', horas: 60),
      ];
      final v = BaremaService.verificarLimite(
        existentes: existentes,
        natureza: 'extensao',
        classificacao: 'Curso de Extensão',
      );
      expect(v.permitido, isFalse);
    });

    test('título do bloqueio por classificação está preenchido', () {
      final existentes = [
        _a(natureza: 'ensino', classificacao: 'Tópicos Especiais', horas: 120),
      ];
      final v = BaremaService.verificarLimite(
        existentes: existentes,
        natureza: 'ensino',
        classificacao: 'Tópicos Especiais',
      );
      expect(v.titulo, isNotNull);
      expect(v.titulo, isNotEmpty);
    });
  });

  // ── Bloqueio por total >= 360h (meta do curso atingida) ──────────────────
  group('Bloqueio total — meta de 360h atingida', () {
    // Uma natureza com 360h = total = 360h → bloqueia TUDO
    final atividades360 = [
      _a(natureza: 'ensino', classificacao: 'A', horas: 120),
      _a(natureza: 'ensino', classificacao: 'B', horas: 120),
      _a(natureza: 'ensino', classificacao: 'C', horas: 120),
    ];

    test('total 360h → qualquer natureza bloqueada', () {
      for (final nat in ['ensino', 'pesquisa', 'extensao']) {
        final v = BaremaService.verificarLimite(
          existentes: atividades360,
          natureza: nat,
          classificacao: 'Qualquer',
        );
        expect(v.permitido, isFalse,
            reason: 'deveria bloquear $nat com total já em 360h');
      }
    });

    test('mensagem menciona 360h concluídas', () {
      final v = BaremaService.verificarLimite(
        existentes: atividades360,
        natureza: 'pesquisa',
        classificacao: 'X',
      );
      expect(v.mensagem, contains('360h'));
    });

    test('120h em cada natureza (3×120=360) → também bloqueia tudo', () {
      final distribuido = [
        _a(natureza: 'ensino',   classificacao: 'A', horas: 120),
        _a(natureza: 'pesquisa', classificacao: 'B', horas: 120),
        _a(natureza: 'extensao', classificacao: 'C', horas: 120),
      ];
      for (final nat in ['ensino', 'pesquisa', 'extensao']) {
        final v = BaremaService.verificarLimite(
          existentes: distribuido,
          natureza: nat,
          classificacao: 'Qualquer',
        );
        expect(v.permitido, isFalse,
            reason: '$nat deveria estar bloqueado — total já é 360h');
      }
    });
  });

  // ── Permitido com horas parciais ──────────────────────────────────────────
  group('Permitido quando ainda há espaço', () {
    test('classificação com 90h → ainda permite (faltam 30h)', () {
      final v = BaremaService.verificarLimite(
        existentes: [
          _a(natureza: 'ensino', classificacao: 'Tópicos Especiais', horas: 90),
        ],
        natureza: 'ensino',
        classificacao: 'Tópicos Especiais',
      );
      expect(v.permitido, isTrue);
    });

    test('natureza com 345h → ainda permite (faltam 15h)', () {
      final v = BaremaService.verificarLimite(
        existentes: [
          _a(natureza: 'extensao', classificacao: 'A', horas: 120),
          _a(natureza: 'extensao', classificacao: 'B', horas: 120),
          _a(natureza: 'extensao', classificacao: 'C', horas: 105),
        ],
        natureza: 'extensao',
        classificacao: 'C',
      );
      expect(v.permitido, isTrue);
    });
  });
}
