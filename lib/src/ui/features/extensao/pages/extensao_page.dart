import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/core/di/injection_container.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/data/services/barema_service.dart';
import 'package:controle_horas/src/shared/utils/context_extensions.dart';
import 'package:controle_horas/src/ui/features/extensao/controllers/extensao_controller.dart';
import 'package:controle_horas/src/ui/features/home/controllers/home_controller.dart';

// Funções de cor tema-aware
Color _kScaffold(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
Color _kFieldBg(bool isDark) =>
    isDark ? const Color(0xFF18191B) : AppColors.cardLight;
Color _kText(bool isDark) =>
    isDark ? Colors.white : AppColors.neutralGrey900;
Color _kHint(bool isDark) =>
    isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.neutralBaseGrey;
Color _kLabel(bool isDark) =>
    isDark ? Colors.white.withValues(alpha: 0.65) : AppColors.neutralDarkGrey;
Color _kIcon(bool isDark) =>
    isDark ? Colors.white.withValues(alpha: 0.45) : AppColors.neutralDarkGrey;

class ExtensaoPage extends StatelessWidget {
  const ExtensaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ExtensaoController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? theme.scaffoldBackgroundColor : AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _kText(isDark)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Novo Cadastro',
          style: TextStyle(
            color: _kText(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: ctrl.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── TÍTULO ──────────────────────────────────────────────
              const _Label('Título'),
              const SizedBox(height: 8),
              _DarkTextField(
                controller: ctrl.tituloController,
                hint: ctrl.tituloHint,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 20),

              // ── CLASSIFICAÇÃO ────────────────────────────────────────
              const _Label('Classificação'),
              const SizedBox(height: 8),
              _DropdownField(
                value: ctrl.classificacao?.label,
                placeholder: 'Selecione a classificação',
                errorText: ctrl.classificacaoError,
                onTap: () => _showClassificacaoSheet(context, ctrl),
              ),
              const SizedBox(height: 20),

              // ── TIPO (apenas para Curso de Extensão) ─────────────────
              if (ctrl.showTipoField) ...[
                const _Label('Tipo'),
                const SizedBox(height: 8),
                _DropdownField(
                  value: ctrl.tipo?.label,
                  placeholder: 'Selecione o tipo',
                  errorText: ctrl.tipoError,
                  onTap: () => _showTipoSheet(context, ctrl),
                ),
                const SizedBox(height: 20),
              ],

              // ── CAMPOS SEGMENTED (Programa / Projeto) ────────────────
              if (ctrl.showCalculoFields) ...[
                const _Label('Tipo de Cálculo'),
                const SizedBox(height: 8),
                _TipoCalculoToggle(
                  selected: ctrl.tipoCalculo,
                  onChanged:
                      context.read<ExtensaoController>().setTipoCalculo,
                ),
                const SizedBox(height: 20),

                if (ctrl.tipoCalculo == TipoCalculo.porSemestre) ...[
                  const _Label('Quantidade de semestres'),
                  const SizedBox(height: 8),
                  _DarkTextField(
                    controller: ctrl.semestresController,
                    hint: 'Ex: 2',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (v) {
                      if (!ctrl.showCalculoFields) return null;
                      if (ctrl.tipoCalculo != TipoCalculo.porSemestre) {
                        return null;
                      }
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obrigatório';
                      }
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Informe um valor válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),
                  const _HelperText('Cada semestre equivale a 60h/a'),
                ] else ...[
                  const _Label('Carga horária'),
                  const SizedBox(height: 8),
                  _DarkTextField(
                    controller: ctrl.cargaHorariaController,
                    hint: 'Ex: 80',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d*'),
                      ),
                    ],
                    validator: (v) {
                      if (!ctrl.showCalculoFields) return null;
                      if (ctrl.tipoCalculo != TipoCalculo.porCargaHoraria) {
                        return null;
                      }
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obrigatório';
                      }
                      final n = double.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Informe um valor válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),
                  const _HelperText(
                      'A cada 4h de dedicação, contabiliza-se 1 h/a'),
                ],
                const SizedBox(height: 20),
                const _Label('Total de horas'),
                const SizedBox(height: 8),
                _TotalHorasDisplay(horas: ctrl.totalHorasCalculo),
                if (ctrl.atingiuLimite) ...[
                  const SizedBox(height: 6),
                  const _HelperText(
                    'Apenas 120h/a são contabilizadas nesta classificação, mesmo que o cálculo dê um valor maior.',
                    isWarning: true,
                  ),
                ],
                const SizedBox(height: 20),
              ],

              // ── CAMPOS CARGA × 3 (Curso de Extensão) ────────────────
              if (ctrl.showCargaFields) ...[
                const _Label('Carga horária'),
                const SizedBox(height: 8),
                _DarkTextField(
                  controller: ctrl.cargaSimController,
                  hint: 'Ex: 4',
                  prefixIcon: Builder(builder: (ctx) {
                    final d = Theme.of(ctx).brightness == Brightness.dark;
                    return Icon(
                      Iconsax.timer_1,
                      color: _kIcon(d),
                      size: 18,
                    );
                  }),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  validator: (v) {
                    if (!ctrl.showCargaFields) return null;
                    if (v == null || v.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Informe um valor válido';
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                const _HelperText(
                    'Para cada 1h assistida, contabiliza-se 1h/a'),
                const SizedBox(height: 20),
                const _Label('Total de horas'),
                const SizedBox(height: 8),
                _TotalHorasDisplay(horas: ctrl.totalHorasCurso),
                if (ctrl.atingiuLimite) ...[
                  const SizedBox(height: 6),
                  const _HelperText(
                    'Apenas 120h/a são contabilizadas nesta classificação, mesmo que o cálculo dê um valor maior.',
                    isWarning: true,
                  ),
                ],
                const SizedBox(height: 20),
              ],

              // ── CAMPOS PARTICIPAÇÃO EM ELEIÇÃO ───────────────────────
              if (ctrl.showElecaoFields) ...[
                const _Label('Turnos realizados'),
                const SizedBox(height: 8),
                _CheckboxTile(
                  value: ctrl.treinamento,
                  label: 'Treinamento - 4h',
                  onChanged: (v) => context
                      .read<ExtensaoController>()
                      .setTreinamento(v),
                ),
                const SizedBox(height: 8),
                _CheckboxTile(
                  value: ctrl.primeiroTurno,
                  label: '1º Turno - 12h',
                  onChanged: (v) => context
                      .read<ExtensaoController>()
                      .setPrimeiroTurno(v),
                ),
                const SizedBox(height: 8),
                _CheckboxTile(
                  value: ctrl.segundoTurno,
                  label: '2º Turno - 12h',
                  onChanged: (v) => context
                      .read<ExtensaoController>()
                      .setSegundoTurno(v),
                ),
                const SizedBox(height: 6),
                const _HelperText(
                    'Obs.: para cada 1h, contabilizam-se 2h'),
                if (ctrl.elecaoTurnoError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    ctrl.elecaoTurnoError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                const _Label('Total de horas'),
                const SizedBox(height: 8),
                _TotalHorasDisplay(horas: ctrl.totalHorasEleicao),
                const SizedBox(height: 20),
                _DateField(
                  label: 'Data de Apresentação',
                  value: ctrl.dataApresentacao,
                  errorText: ctrl.dataApresentacaoError,
                  onTap: () => _pickDataApresentacao(context, ctrl),
                ),
              ],

              // ── CAMPOS PRODUTO DE EXTENSÃO ───────────────────────────
              if (ctrl.showProdutoFields) ...[
                const _Label('Quantidade de Artefatos'),
                const SizedBox(height: 8),
                _DarkTextField(
                  controller: ctrl.artefatosController,
                  hint: 'Ex: 1',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (v) {
                    if (!ctrl.showProdutoFields) return null;
                    if (v == null || v.trim().isEmpty) {
                      return 'Campo obrigatório';
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Informe um valor válido';
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                const _HelperText('Cada artefato equivale a 15h/a'),
                if (ctrl.atingiuLimite) ...[
                  const SizedBox(height: 6),
                  const _HelperText(
                    'Apenas 120h/a são contabilizadas nesta classificação, mesmo que o cálculo dê um valor maior.',
                    isWarning: true,
                  ),
                ],
                const SizedBox(height: 20),
                _DateField(
                  label: 'Data de Apresentação',
                  value: ctrl.dataApresentacao,
                  errorText: ctrl.dataApresentacaoError,
                  onTap: () => _pickDataApresentacao(context, ctrl),
                ),
              ],

              // ── CAMPOS EVENTO DE EXTENSÃO ─────────────────────────────
              if (ctrl.showEventoFields) ...[
                const _Label('Tipo de evento'),
                const SizedBox(height: 8),
                ...ctrl.tiposDisponiveis.map(
                  (tipo) {
                    final isSelected = ctrl.tipo == tipo;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => context
                            .read<ExtensaoController>()
                            .setTipo(tipo),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: _kFieldBg(isDark),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.black,
                                    width: 1.5)
                                : null,
                          ),
                          child: Row(
                            children: [
                              _RadioDot(selected: isSelected),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tipo.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? _kText(isDark)
                                        : isDark
                                            ? Colors.white.withValues(alpha: 0.7)
                                            : AppColors.neutralDarkGrey,
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              Text(
                                tipo.horasLabel,
                                style: TextStyle(
                                  color: isSelected
                                      ? _kText(isDark)
                                      : _kIcon(isDark),
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (ctrl.tipoError != null) ...[
                  Text(
                    ctrl.tipoError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                ] else
                  const SizedBox(height: 12),
                const _Label('Participação no Evento'),
                const SizedBox(height: 8),
                _DropdownField(
                  value: ctrl.participacao?.label,
                  placeholder: 'Selecione',
                  errorText: ctrl.participacaoError,
                  onTap: () => _showParticipacaoSheet(context, ctrl),
                ),
                const SizedBox(height: 6),
                const _HelperText('A função deve constar no certificado'),
                const SizedBox(height: 20),
                const _Label('Participação no Evento'),
                const SizedBox(height: 8),
                _ComissaoToggle(
                  value: ctrl.participouComissao,
                  onChanged: (v) => context
                      .read<ExtensaoController>()
                      .setParticipouComissao(v),
                ),
                if (ctrl.participouComissao) ...[
                  const SizedBox(height: 6),
                  const _HelperText('Acréscimo de +15h aplicado'),
                ],
                const SizedBox(height: 20),
                const _Label('Total de horas'),
                const SizedBox(height: 8),
                _TotalHorasDisplay(horas: ctrl.totalHorasEvento),
                const SizedBox(height: 20),
              ],

              // ── DATAS ini + fin (Curso / Programa / Projeto / Evento) ─
              if (ctrl.showCalculoFields ||
                  ctrl.showCargaFields ||
                  ctrl.showEventoFields) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'Data inicial',
                        value: ctrl.dataInicial,
                        errorText: ctrl.dataInicialError,
                        onTap: () =>
                            _pickDate(context, ctrl, isInicial: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(
                        label: 'Data final',
                        value: ctrl.dataFinal,
                        errorText: ctrl.dataFinalError,
                        onTap: () =>
                            _pickDate(context, ctrl, isInicial: false),
                      ),
                    ),
                  ],
                ),
                if (ctrl.dateRangeError != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Colors.red, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ctrl.dateRangeError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 32),

              // ── BOTÃO CADASTRAR ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _cadastrar(context, ctrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.white : AppColors.neutralGrey900,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Funções de página ────────────────────────────────────────────────────────

void _showClassificacaoSheet(
    BuildContext context, ExtensaoController ctrl) {
  final options = ExtensaoClassificacao.values;
  _showOptionsSheet(
    context,
    title: 'Classificação',
    options: options.map((e) => e.label).toList(),
    selectedIndex: ctrl.classificacao == null
        ? null
        : options.indexOf(ctrl.classificacao!),
    onSelect: (i) => ctrl.setClassificacao(options[i]),
  );
}

void _showTipoSheet(BuildContext context, ExtensaoController ctrl) {
  final options = ctrl.tiposDisponiveis;
  _showOptionsSheet(
    context,
    title: 'Tipo',
    options: options.map((e) => e.label).toList(),
    selectedIndex:
        ctrl.tipo == null ? null : options.indexOf(ctrl.tipo!),
    onSelect: (i) => ctrl.setTipo(options[i]),
  );
}

void _showParticipacaoSheet(
    BuildContext context, ExtensaoController ctrl) {
  final options = EventoParticipacao.values;
  _showOptionsSheet(
    context,
    title: 'Participação no Evento',
    options: options.map((e) => e.label).toList(),
    selectedIndex: ctrl.participacao == null
        ? null
        : options.indexOf(ctrl.participacao!),
    onSelect: (i) => ctrl.setParticipacao(options[i]),
  );
}

void _showOptionsSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required int? selectedIndex,
  required ValueChanged<int> onSelect,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final sheetBg = isDark ? const Color(0xFF18191B) : Colors.white;
  final handleColor = isDark
      ? Colors.white.withValues(alpha: 0.25)
      : AppColors.neutralMidLightGrey;
  final titleColor = isDark ? Colors.white : AppColors.neutralGrey900;
  final itemColor = isDark ? Colors.white : AppColors.neutralGrey900;
  final dividerColor = isDark
      ? Colors.white.withValues(alpha: 0.08)
      : AppColors.neutralMidLightGrey;

  final screenHeight = MediaQuery.of(context).size.height;
  showModalBottomSheet(
    context: context,
    backgroundColor: sheetBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 28),
              itemCount: options.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: dividerColor,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (ctx, i) {
                final isSelected = i == selectedIndex;
                return ListTile(
                  title: Text(
                    options[i],
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(ctx).colorScheme.primary
                          : itemColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded,
                          color: Theme.of(ctx).colorScheme.primary, size: 20)
                      : null,
                  onTap: () {
                    onSelect(i);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _pickDate(
  BuildContext context,
  ExtensaoController ctrl, {
  required bool isInicial,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final fieldBg = isDark ? const Color(0xFF18191B) : AppColors.cardLight;

  final initial = isInicial
      ? (ctrl.dataInicial ?? DateTime.now())
      : (ctrl.dataFinal ?? ctrl.dataInicial ?? DateTime.now());

  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2020),
    lastDate: DateTime(2035),
    builder: (ctx, child) => Theme(
      data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
        colorScheme: isDark
            ? ColorScheme.dark(
                primary: AppColors.white,
                surface: fieldBg,
                onSurface: Colors.white,
              )
            : ColorScheme.light(
                primary: AppColors.neutralGrey900,
                surface: fieldBg,
                onSurface: AppColors.neutralGrey900,
              ),
        dialogTheme: DialogThemeData(backgroundColor: fieldBg),
      ),
      child: child!,
    ),
  );
  if (picked != null) {
    isInicial ? ctrl.setDataInicial(picked) : ctrl.setDataFinal(picked);
  }
}

Future<void> _pickDataApresentacao(
    BuildContext context, ExtensaoController ctrl) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final fieldBg = isDark ? const Color(0xFF18191B) : AppColors.cardLight;

  final picked = await showDatePicker(
    context: context,
    initialDate: ctrl.dataApresentacao ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2035),
    builder: (ctx, child) => Theme(
      data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
        colorScheme: isDark
            ? ColorScheme.dark(
                primary: AppColors.white,
                surface: fieldBg,
                onSurface: Colors.white,
              )
            : ColorScheme.light(
                primary: AppColors.neutralGrey900,
                surface: fieldBg,
                onSurface: AppColors.neutralGrey900,
              ),
        dialogTheme: DialogThemeData(backgroundColor: fieldBg),
      ),
      child: child!,
    ),
  );
  if (picked != null) ctrl.setDataApresentacao(picked);
}

Future<void> _cadastrar(BuildContext context, ExtensaoController ctrl) async {
  FocusScope.of(context).unfocus();
  if (!ctrl.validate()) return;

  final homeCtrl = sl<HomeController>();
  final verificacao = BaremaService.verificarLimite(
    existentes: homeCtrl.atividades,
    natureza: 'extensao',
    classificacao: ctrl.classificacao!.label,
  );

  if (!verificacao.permitido) {
    if (!context.mounted) return;
    context.showFeedback(
      '${verificacao.titulo}\n${verificacao.mensagem}',
      type: FeedbackType.error,
    );
    return;
  }

  await ctrl.salvar();
  await homeCtrl.carregar();
  if (!context.mounted) return;
  context.showFeedback('Atividade cadastrada com sucesso!');
  context.pop();
}

// ─── Widgets privados ─────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        color: _kLabel(isDark),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _HelperText extends StatelessWidget {
  final String text;
  final bool isWarning;
  const _HelperText(this.text, {this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        color: isWarning
            ? Colors.orange
            : isDark
                ? Colors.white.withValues(alpha: 0.4)
                : AppColors.neutralBaseGrey,
        fontSize: 12,
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;

  const _DarkTextField({
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      style: TextStyle(color: _kText(isDark), fontSize: 15),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: AutovalidateMode.disabled,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: prefixIcon != null
            ? const BoxConstraints(minWidth: 0, minHeight: 0)
            : null,
        filled: true,
        fillColor: _kFieldBg(isDark),
        hintText: hint,
        hintStyle: TextStyle(
          color: _kHint(isDark),
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(
                  color: isDark ? AppColors.white : AppColors.black,
                  width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String placeholder;
  final String? errorText;
  final VoidCallback? onTap;

  const _DropdownField({
    required this.placeholder,
    this.value,
    this.errorText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _kFieldBg(isDark),
                borderRadius: BorderRadius.circular(12),
                border: errorText != null
                    ? Border.all(color: Colors.red, width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? placeholder,
                      style: TextStyle(
                        color: value != null
                            ? _kText(isDark)
                            : _kHint(isDark),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _kIcon(isDark),
                    size: 22,
                  ),
                ],
              ),
            ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _TipoCalculoToggle extends StatelessWidget {
  final TipoCalculo selected;
  final ValueChanged<TipoCalculo> onChanged;

  const _TipoCalculoToggle({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _kFieldBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: TipoCalculo.values.map((tc) {
          final isSelected = selected == tc;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(tc),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.neutralGrey900)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  tc.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : _kHint(isDark),
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TotalHorasDisplay extends StatelessWidget {
  final double horas;
  const _TotalHorasDisplay({required this.horas});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kFieldBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            horas > 0 ? '${horas.toStringAsFixed(0)} h/a' : '—',
            style: TextStyle(
              color: horas > 0 ? _kText(isDark) : _kHint(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(
            Iconsax.timer_1,
            color: _kIcon(isDark),
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? errorText;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    this.errorText,
    required this.onTap,
  });

  String get _display {
    if (value == null) return 'DD/MM/AAAA';
    return '${value!.day.toString().padLeft(2, '0')}/'
        '${value!.month.toString().padLeft(2, '0')}/'
        '${value!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: _kFieldBg(isDark),
              borderRadius: BorderRadius.circular(12),
              border: errorText != null
                  ? Border.all(color: Colors.red, width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.calendar_1,
                  color: _kIcon(isDark),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _display,
                    style: TextStyle(
                      color: value != null ? _kText(isDark) : _kIcon(isDark),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  const _CheckboxTile({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _kFieldBg(isDark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: isDark ? AppColors.white : AppColors.black,
                checkColor: isDark ? AppColors.black : Colors.white,
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.neutralBaseGrey,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: value ? _kText(isDark) : _kLabel(isDark),
                fontSize: 15,
                fontWeight:
                    value ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? (isDark ? AppColors.white : AppColors.black)
              : isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppColors.neutralBaseGrey,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),
            )
          : null,
    );
  }
}

class _ComissaoToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ComissaoToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: _kFieldBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Participou da comissão organizadora',
              style: TextStyle(
                color: _kText(isDark),
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return isDark ? AppColors.black : Colors.white;
              }
              return isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.neutralBaseGrey;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return isDark ? AppColors.white : AppColors.black;
              }
              return isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : AppColors.neutralMidLightGrey;
            }),
            trackOutlineColor:
                WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
