import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import '../widgets/logo_draw_painter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _drawProgress;
  late final Animation<double> _crossfade;
  late final List<Path> _logoPaths;

  static const _logoSize = 180.0;

  @override
  void initState() {
    super.initState();

    _logoPaths = buildLogoPaths();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // 0 → 65%: a logo vai sendo "traçada" linha por linha.
    _drawProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
    );

    // 65% → 90%: o traçado some e a logo colorida final aparece.
    _crossfade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 0.9, curve: Curves.easeOut),
    );

    // Só inicia o desenho depois do primeiro frame visível, senão a
    // animação avança "escondida" atrás da splash nativa do Android/iOS.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
    _navigateQuandoPronto();
  }

  Future<void> _navigateQuandoPronto() async {
    await Future.delayed(const Duration(milliseconds: 2900));
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkScaffold : AppColors.white;
    final strokeColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SizedBox(
          width: _logoSize,
          height: _logoSize,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 1 - _crossfade.value,
                    child: CustomPaint(
                      size: const Size(_logoSize, _logoSize),
                      painter: LogoDrawPainter(
                        paths: _logoPaths,
                        progress: _drawProgress.value,
                        strokeColor: strokeColor,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: _crossfade.value,
                    child: SvgPicture.asset(
                      isDark
                          ? 'assets/logodarksvg.svg'
                          : 'assets/logosvg.svg',
                      width: _logoSize,
                      height: _logoSize,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
