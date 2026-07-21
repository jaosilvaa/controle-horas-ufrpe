import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/data/models/atividade_model.dart';
import 'package:controle_horas/src/data/repositories/atividade_repository.dart';
import 'package:controle_horas/src/shared/utils/context_extensions.dart';

// Funções de cor tema-aware
Color _kScaffold(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
Color _kFieldBg(bool isDark) =>
    isDark ? const Color(0xFF18191B) : AppColors.cardLight;
Color _kText(bool isDark) =>
    isDark ? Colors.white : AppColors.neutralGrey900;
Color _kHint(bool isDark) =>
    isDark ? Colors.white.withValues(alpha: 0.35) : AppColors.neutralBaseGrey;
Color _kLabel(bool isDark) =>
    isDark ? Colors.white.withValues(alpha: 0.65) : AppColors.neutralDarkGrey;
Color _kIcon(bool isDark) =>
    isDark ? Colors.white.withValues(alpha: 0.45) : AppColors.neutralDarkGrey;

class EditarAtividadePage extends StatefulWidget {
  final AtividadeModel atividade;
  final AtividadeRepository repo;

  const EditarAtividadePage({
    super.key,
    required this.atividade,
    required this.repo,
  });

  @override
  State<EditarAtividadePage> createState() => _EditarAtividadePageState();
}

class _EditarAtividadePageState extends State<EditarAtividadePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _horasCtrl;

  DateTime? _dataInicial;
  DateTime? _dataFinal;
  bool _saving = false;

  String? _horasError;
  String? _dataFinalError;

  @override
  void initState() {
    super.initState();
    final a = widget.atividade;
    _tituloCtrl = TextEditingController(text: a.titulo);
    _horasCtrl = TextEditingController(
      text: a.horasCalculadas == a.horasCalculadas.truncateToDouble()
          ? a.horasCalculadas.toInt().toString()
          : a.horasCalculadas.toString(),
    );
    _dataInicial = a.dataInicial;
    _dataFinal = a.dataFinal;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _horasCtrl.dispose();
    super.dispose();
  }

  String get _naturezaLabel => switch (widget.atividade.natureza) {
        'ensino' => 'Ensino',
        'pesquisa' => 'Pesquisa',
        'extensao' => 'Extensão',
        _ => widget.atividade.natureza,
      };

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  bool _validate() {
    final formOk = _formKey.currentState?.validate() ?? false;
    final horas = double.tryParse(_horasCtrl.text.trim());
    setState(() {
      _horasError =
          (horas == null || horas <= 0) ? 'Informe um valor válido' : null;
      if (_dataFinal != null && _dataFinal!.isAfter(DateTime.now())) {
        _dataFinalError = 'Data final não pode ser no futuro';
      } else if (_dataInicial != null && _dataFinal != null) {
        _dataFinalError = !_dataFinal!.isAfter(_dataInicial!)
            ? 'Data final deve ser após a inicial'
            : null;
      } else {
        _dataFinalError = null;
      }
    });
    return formOk && _horasError == null && _dataFinalError == null;
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    setState(() => _saving = true);

    final atualizada = widget.atividade.copyWith(
      titulo: _tituloCtrl.text.trim(),
      horasCalculadas: double.parse(_horasCtrl.text.trim()),
      dataInicial: _dataInicial,
      dataFinal: _dataFinal,
      clearDataInicial: _dataInicial == null,
      clearDataFinal: _dataFinal == null,
    );

    await widget.repo.atualizar(atualizada);
    if (!mounted) return;
    setState(() => _saving = false);
    context.showFeedback('Atividade atualizada com sucesso!');
    context.pop(true);
  }

  Future<void> _pickDate({required bool isInicial}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isInicial ? (_dataInicial ?? now) : (_dataFinal ?? now),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isInicial) {
        _dataInicial = picked;
      } else {
        _dataFinal = picked;
        _dataFinalError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _kText(isDark)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Editar Atividade',
          style: TextStyle(
            color: _kText(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Informações', isDark: isDark),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(_naturezaLabel, isDark: isDark),
                  _InfoChip(widget.atividade.classificacao, isDark: isDark),
                  _InfoChip(widget.atividade.tipo, isDark: isDark),
                ],
              ),
              const SizedBox(height: 24),

              _Label('Título', isDark: isDark),
              const SizedBox(height: 8),
              _DarkTextField(
                controller: _tituloCtrl,
                hint: 'Ex: Curso de Power BI',
                isDark: isDark,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),

              _Label('Horas calculadas', isDark: isDark),
              const SizedBox(height: 8),
              _DarkTextField(
                controller: _horasCtrl,
                hint: 'Ex: 72',
                isDark: isDark,
                suffixText: 'h',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                errorText: _horasError,
                onChanged: (_) => setState(() => _horasError = null),
              ),
              const SizedBox(height: 20),

              _Label('Datas (opcionais)', isDark: isDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Data inicial',
                      value: _dataInicial != null
                          ? _formatDate(_dataInicial!)
                          : null,
                      isDark: isDark,
                      onTap: () => _pickDate(isInicial: true),
                      onClear: _dataInicial != null
                          ? () => setState(() => _dataInicial = null)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Data final',
                      value:
                          _dataFinal != null ? _formatDate(_dataFinal!) : null,
                      isDark: isDark,
                      errorText: _dataFinalError,
                      onTap: () => _pickDate(isInicial: false),
                      onClear: _dataFinal != null
                          ? () => setState(() {
                                _dataFinal = null;
                                _dataFinalError = null;
                              })
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _salvar,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.white : AppColors.neutralGrey900,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    disabledBackgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : AppColors.neutralGrey900.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        )
                      : const Text(
                          'Salvar alterações',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Label(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _kLabel(isDark),
        ),
      );
}

class _InfoChip extends StatelessWidget {
  final String label;
  final bool isDark;
  const _InfoChip(this.label, {required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _kFieldBg(isDark),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: _kText(isDark),
          ),
        ),
      );
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final String? suffixText;
  final String? errorText;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const _DarkTextField({
    required this.controller,
    required this.hint,
    required this.isDark,
    this.suffixText,
    this.errorText,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        textCapitalization: textCapitalization,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        validator: validator,
        style: TextStyle(color: _kText(isDark), fontSize: 15),
        decoration: InputDecoration(
          filled: true,
          fillColor: _kFieldBg(isDark),
          hintText: hint,
          hintStyle: TextStyle(
            color: _kHint(isDark),
            fontSize: 15,
          ),
          suffixText: suffixText,
          suffixStyle: TextStyle(
            color: _kIcon(isDark),
            fontSize: 15,
          ),
          errorText: errorText,
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

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final bool isDark;
  final String? errorText;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.onTap,
    required this.isDark,
    this.value,
    this.errorText,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _kFieldBg(isDark),
              borderRadius: BorderRadius.circular(12),
              border: hasError
                  ? Border.all(color: Colors.red, width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: hasValue ? _kIcon(isDark) : _kHint(isDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value ?? label,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasValue ? _kText(isDark) : _kHint(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: _kIcon(isDark),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
