import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';
import 'package:controle_horas/src/shared/utils/context_extensions.dart';
import 'package:controle_horas/src/ui/features/home/controllers/home_controller.dart';
import '../controllers/natureza_list_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class NaturezaListPage extends StatefulWidget {
  final String natureza; // 'ensino' | 'pesquisa' | 'extensao'

  const NaturezaListPage({super.key, required this.natureza});

  @override
  State<NaturezaListPage> createState() => _NaturezaListPageState();
}

class _NaturezaListPageState extends State<NaturezaListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NaturezaListController>().carregar();
    });
  }

  String get _titulo => switch (widget.natureza) {
        'ensino' => 'Ensino',
        'pesquisa' => 'Pesquisa',
        'extensao' => 'Extensão',
        _ => widget.natureza,
      };

  IconData get _icon => switch (widget.natureza) {
        'ensino' => Iconsax.teacher,
        'pesquisa' => Iconsax.microscope,
        'extensao' => Iconsax.global,
        _ => Icons.folder_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NaturezaListController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.white : AppColors.neutralGrey900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        foregroundColor: titleColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: titleColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _titulo,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        elevation: 0,
      ),
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.atividades.isEmpty
              ? _EmptyState(natureza: widget.natureza)
              : _ListBody(ctrl: ctrl, icon: _icon),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String natureza;
  const _EmptyState({required this.natureza});

  String get _rota => switch (natureza) {
        'ensino' => '/ensino/novo',
        'pesquisa' => '/pesquisa/novo',
        'extensao' => '/extensao/novo',
        _ => '/create',
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 64,
              color: (isDark ? AppColors.white : AppColors.neutralGrey900)
                  .withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma atividade cadastrada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkPrimaryText : AppColors.neutralGrey900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione sua primeira atividade para acompanhar seu progresso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkSubtitle : AppColors.neutralDarkGrey,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await context.push(_rota);
                if (context.mounted) {
                  context.read<NaturezaListController>().carregar();
                }
              },
              child: const Text('Cadastrar atividade'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List body
// ─────────────────────────────────────────────────────────────────────────────

class _ListBody extends StatelessWidget {
  final NaturezaListController ctrl;
  final IconData icon;
  const _ListBody({required this.ctrl, required this.icon});

  Future<void> _navegarParaEdicao(
      BuildContext context, AtividadeModel atividade) async {
    final result = await context.push<bool>('/editar', extra: atividade);
    if ((result ?? false) && context.mounted) {
      await ctrl.carregar();
      // Recarrega HomeController para atualizar as progress bars na home
      if (context.mounted) {
        context.read<HomeController>().carregar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final classificacoes = ctrl.classificacoesOrdenadas;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: classificacoes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final classificacao = classificacoes[i];
        final atividades = ctrl.porClassificacao[classificacao]!;
        final horasEfetivas = ctrl.horasEfetivasClassificacao(classificacao);
        return _ClassificacaoCard(
          classificacao: classificacao,
          atividades: atividades,
          horasEfetivas: horasEfetivas,
          icon: icon,
          onDelete: (id) async {
            await ctrl.deletar(id);
            if (context.mounted) {
              context.read<HomeController>().carregar();
            }
          },
          onEdit: (a) => _navegarParaEdicao(context, a),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expansion card por classificação
// ─────────────────────────────────────────────────────────────────────────────

class _ClassificacaoCard extends StatefulWidget {
  final String classificacao;
  final List<AtividadeModel> atividades;
  final double horasEfetivas;
  final IconData icon;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(AtividadeModel) onEdit;

  const _ClassificacaoCard({
    required this.classificacao,
    required this.atividades,
    required this.horasEfetivas,
    required this.icon,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_ClassificacaoCard> createState() => _ClassificacaoCardState();
}

class _ClassificacaoCardState extends State<_ClassificacaoCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _chevronController;

  /// Lista os tipos únicos das atividades da classificação (separados por vírgula)
  String get _tiposSubtitulo {
    final tipos = widget.atividades.map((a) => a.tipo).toSet().toList();
    return tipos.join(', ');
  }

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _chevronController.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _chevronController.forward();
    } else {
      _chevronController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = theme.colorScheme.surface;
    final titleColor = isDark ? AppColors.white : AppColors.neutralGrey900;
    final subtitleColor = isDark ? AppColors.darkSubtitle : AppColors.neutralDarkGrey;
    final iconBg = isDark ? AppColors.darkIconContainer : AppColors.neutralMidLightGrey;
    final chevronColor = isDark ? AppColors.darkSubtitle : AppColors.neutralDarkGrey;
    final badgeBg = isDark ? AppColors.darkProgressBg : AppColors.neutralMidLightGrey;
    final badgeText = isDark ? AppColors.darkPrimaryText : AppColors.neutralGrey900;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(20),
            splashFactory: InkRipple.splashFactory,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: titleColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.classificacao,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tiposSubtitulo,
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Badge + chevron empilhados verticalmente
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.atividades.length} ${widget.atividades.length == 1 ? 'item' : 'itens'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: badgeText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedBuilder(
                        animation: _chevronController,
                        builder: (context, child) => Transform.rotate(
                          angle: _chevronController.value * math.pi,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: chevronColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      children: widget.atividades.map((a) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _SwipeableAtividadeTile(
                            atividade: a,
                            onDelete: widget.onDelete,
                            onEdit: widget.onEdit,
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Swipeable tile
// ─────────────────────────────────────────────────────────────────────────────

class _SwipeableAtividadeTile extends StatefulWidget {
  final AtividadeModel atividade;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(AtividadeModel) onEdit;

  const _SwipeableAtividadeTile({
    required this.atividade,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_SwipeableAtividadeTile> createState() => _SwipeableAtividadeTileState();
}

class _SwipeableAtividadeTileState extends State<_SwipeableAtividadeTile>
    with SingleTickerProviderStateMixin {
  static const double _actionWidth = 75;

  late final AnimationController _swipeController;
  late final Animation<Offset> _slideAnim;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-_actionWidth, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _open() {
    setState(() => _isOpen = true);
    _swipeController.forward();
  }

  void _close() {
    setState(() => _isOpen = false);
    _swipeController.reverse();
  }

  double _dragStart = 0;

  void _onHorizontalDragStart(DragStartDetails d) {
    _dragStart = d.localPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    final delta = d.localPosition.dx - _dragStart;
    if (delta < -10 && !_isOpen) _open();
    if (delta > 10 && _isOpen) _close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tileBg = isDark ? AppColors.darkProgressBg : AppColors.white;
    final tileText = isDark ? AppColors.white : AppColors.neutralGrey900;
    final horasColor = isDark ? AppColors.darkSubtitle : AppColors.neutralDarkGrey;
    final horasBadgeBg = isDark ? const Color(0xFF2B2B2B) : AppColors.neutralMidLightGrey;
    final actionBorder = isDark ? const Color(0xFF252529) : AppColors.neutralBaseGrey;

    return GestureDetector(
      onTap: () {
        if (_isOpen) {
          _close();
          return;
        }
        _showDetalhes(context);
      },
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      child: SizedBox(
        height: 49,
        child: ClipRect(
          child: Stack(
          children: [
            // Action buttons (behind tile)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Actions container
                  Container(
                    width: _actionWidth,
                    height: 49,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: actionBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Edit
                        GestureDetector(
                          onTap: () {
                            _close();
                            _showDetalhes(context, openEdit: true);
                          },
                          child: Icon(
                            Icons.edit_outlined,
                            color: isDark ? AppColors.white : AppColors.neutralGrey900,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Delete
                        GestureDetector(
                          onTap: () => _confirmDelete(context),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFFF4D4D),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sliding tile
            AnimatedBuilder(
              animation: _slideAnim,
              builder: (_, child) => Transform.translate(
                offset: _slideAnim.value,
                child: child,
              ),
              child: Container(
                height: 49,
                decoration: BoxDecoration(
                  color: tileBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.atividade.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: tileText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: horasBadgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.atividade.horasCalculadas.toInt()}h',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: horasColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  void _showDetalhes(BuildContext context, {bool openEdit = false}) {
    if (openEdit) {
      widget.onEdit(widget.atividade);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AtividadeDetalheSheet(
        atividade: widget.atividade,
        onDelete: () => _confirmDelete(context),
        onEdit: () => widget.onEdit(widget.atividade),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    _close();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir atividade'),
        content: Text(
          'Deseja excluir "${widget.atividade.titulo}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (widget.atividade.id != null) {
                await widget.onDelete(widget.atividade.id!);
                if (context.mounted) {
                  context.showFeedback('Atividade excluída.');
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AtividadeDetalheSheet extends StatelessWidget {
  final AtividadeModel atividade;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _AtividadeDetalheSheet({
    required this.atividade,
    required this.onDelete,
    required this.onEdit,
  });

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  String get _naturezaLabel => switch (atividade.natureza) {
        'ensino' => 'Ensino',
        'pesquisa' => 'Pesquisa',
        'extensao' => 'Extensão',
        _ => atividade.natureza,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final handleColor = isDark ? AppColors.darkProgressBg : AppColors.neutralMidLightGrey;
    final titleColor = isDark ? AppColors.white : AppColors.neutralGrey900;
    final labelColor = isDark ? AppColors.darkSubtitle : AppColors.neutralDarkGrey;
    final valueColor = isDark ? AppColors.darkPrimaryText : AppColors.neutralGrey900;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.neutralMidLightGrey;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              atividade.titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Divider(height: 1, color: dividerColor),
          const SizedBox(height: 16),

          // Info rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _InfoRow(
                  label: 'Natureza',
                  value: _naturezaLabel,
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Classificação',
                  value: atividade.classificacao,
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Tipo',
                  value: atividade.tipo,
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Horas',
                  value: '${atividade.horasCalculadas.toInt()}h',
                  labelColor: labelColor,
                  valueColor: valueColor,
                  valueStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
                if (atividade.dataInicial != null || atividade.dataFinal != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Período',
                    value: atividade.dataFinal != null
                        ? '${_formatDate(atividade.dataInicial)} → ${_formatDate(atividade.dataFinal)}'
                        : _formatDate(atividade.dataInicial),
                    labelColor: labelColor,
                    valueColor: valueColor,
                  ),
                ],
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Cadastrado em',
                  value: _formatDate(atividade.dataCriacao),
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Divider(height: 1, color: dividerColor),
          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onEdit();
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Excluir'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D4D),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
          ),
        ),
      ],
    );
  }
}
