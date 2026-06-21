import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ujobs_app/core/theme/app_colors.dart';
import 'package:ujobs_app/core/widgets/ujob_logo.dart';
import 'package:ujobs_app/core/theme/app_text_styles.dart';
import 'package:ujobs_app/core/utils/l10n_extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _loopCtrl;
  late final AnimationController _seqCtrl;

  late final Animation<double> _iconFade;
  late final Animation<double> _iconSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _textSlide;
  late final Animation<double> _dotsFade;
  late final Animation<double> _clusterExit;

  static const double _seqMs = 4500;

  @override
  void initState() {
    super.initState();

    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6600),
    )..repeat();

    _seqCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _seqMs.toInt()),
    );

    CurvedAnimation interval(
      double startMs,
      double endMs, [
      Curve curve = Curves.easeOut,
    ]) => CurvedAnimation(
      parent: _seqCtrl,
      curve: Interval(startMs / _seqMs, endMs / _seqMs, curve: curve),
    );

    _iconFade = Tween(begin: 0.0, end: 1.0).animate(interval(0, 900));
    _iconSlide = Tween(begin: 24.h, end: 0.0).animate(interval(0, 900));
    _textFade = Tween(begin: 0.0, end: 1.0).animate(interval(450, 1350));
    _textSlide = Tween(begin: 12.h, end: 0.0).animate(interval(450, 1350));
    _dotsFade = Tween(begin: 0.0, end: 1.0).animate(interval(450, 1350));
    _clusterExit = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(interval(3200, 4100, Curves.easeIn));

    _seqCtrl.forward();
  }

  @override
  void dispose() {
    _loopCtrl.dispose();
    _seqCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryMid,
      body: Stack(
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _loopCtrl,
              builder: (_, _) => CustomPaint(
                size: size,
                painter: _SplashBgPainter(
                  loopT: _loopCtrl.value,
                  loopMs:
                      _loopCtrl.lastElapsedDuration?.inMilliseconds
                          .toDouble() ??
                      0,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_seqCtrl, _loopCtrl]),
            builder: (_, _) {
              final opacity = math
                  .min(_iconFade.value, _clusterExit.value)
                  .clamp(0.0, 1.0);
              // Logo bobs ±6px on sine wave after entry slide settles
              final floatY =
                  math.sin(_loopCtrl.value * 2 * math.pi * 2.0) * 6.h;

              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, _iconSlide.value + floatY),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _IconBox(loopT: _loopCtrl.value),
                        SizedBox(height: 20.h),
                        Opacity(
                          opacity: _textFade.value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, _textSlide.value),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.l10n.appName,
                                  style: AppText.display.copyWith(
                                    color: AppColors.surface,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.text.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  context.l10n.splashTagline,
                                  style: AppText.label.copyWith(
                                    color: AppColors.surface.withValues(
                                      alpha: 0.78,
                                    ),
                                    letterSpacing: 0.2,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
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
            },
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_seqCtrl, _loopCtrl]),
            builder: (_, _) {
              final fade = (_dotsFade.value * _clusterExit.value).clamp(
                0.0,
                1.0,
              );
              return _BottomDots(fade: fade, loopT: _loopCtrl.value);
            },
          ),
        ],
      ),
    );
  }
}

class _SplashBgPainter extends CustomPainter {
  final double loopT;
  final double loopMs;

  const _SplashBgPainter({required this.loopT, required this.loopMs});

  // Palette A — teal-to-sky
  static const _a0 = AppColors.primaryDark; // deep teal (bottom-right)
  static const _a1 = AppColors.primary; // cyan mid
  static const _a2 = AppColors.primaryAccent; // bright cyan
  static const _a3 = AppColors.primaryMid; // light sky
  static const _a4 = AppColors.primaryLight; // near-white sky (top-left)

  // Palette B — slightly shifted (blue tint breathe)
  static const _b0 = AppColors.primaryDark;
  static const _b1 = AppColors.primaryAccent;
  static const _b2 = AppColors.primarySky;
  static const _b3 = AppColors.primaryMid;
  static const _b4 = AppColors.primaryCloud;

  static final List<_Particle> _particles = List.generate(14, (i) {
    final rng = math.Random(i * 7 + 13);
    return _Particle(
      x: rng.nextDouble(),
      r: 1.0 + rng.nextDouble() * 2.0,
      speed: 0.00012 + rng.nextDouble() * 0.00018,
      op: 0.15 + rng.nextDouble() * 0.30,
      phase: rng.nextDouble(),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ms = loopMs;

    // Gradient breathes between palette A and B
    final pulse = 0.5 + 0.5 * math.sin(ms / 2800);

    Color mixColor(Color a, Color b) => Color.lerp(a, b, pulse)!;

    final gt = ms / 8000;
    final gAngle = gt * math.pi * 2;
    final x0 = w * (0.95 + math.cos(gAngle) * 0.05);
    final y0 = h * (0.95 + math.sin(gAngle * 0.6) * 0.04);
    final x1 = w * (0.02 + math.cos(gAngle + math.pi) * 0.04);
    final y1 = h * (0.02 + math.sin(gAngle * 0.6 + math.pi) * 0.04);

    final gradShader = LinearGradient(
      colors: [
        mixColor(_a0, _b0),
        mixColor(_a1, _b1),
        mixColor(_a2, _b2),
        mixColor(_a3, _b3),
        mixColor(_a4, _b4),
      ],
      stops: const [0.0, 0.28, 0.55, 0.78, 1.0],
      begin: Alignment(_normX(x0, w), _normY(y0, h)),
      end: Alignment(_normX(x1, w), _normY(y1, h)),
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = gradShader);

    // Shimmer sweep — true 45° diagonal via canvas rotation
    final shimmerT = (ms % 2200.0) / 2200.0;
    final sPos = _smoothstep(0, 1, shimmerT);
    final diagonal = math.sqrt(w * w + h * h);
    final bandCx =
        diagonal * (1.0 - sPos * 2.0); // +diagonal→off BR, -diagonal→off TL
    final bandHalf = w * 0.28;
    final shimmerShader = LinearGradient(
      colors: [
        AppColors.surface.withValues(alpha: 0.0),
        AppColors.surface.withValues(alpha: 0.04),
        AppColors.surface.withValues(alpha: 0.16),
        AppColors.surface.withValues(alpha: 0.04),
        AppColors.surface.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
    ).createShader(Rect.fromLTRB(bandCx - bandHalf, 0, bandCx + bandHalf, h));

    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(math.pi / 4);
    canvas.translate(-w / 2, -h / 2);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = shimmerShader);
    canvas.restore();

    // Radial flare behind logo
    final cx = w / 2;
    final cy = h * 0.42;
    final flarePhase = 0.5 + 0.5 * math.sin(ms / 3000 + 0.8);
    final flareR = w * (0.50 + flarePhase * 0.10);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            AppColors.surface.withValues(alpha: 0.28 + flarePhase * 0.10),
            AppColors.primaryLight.withValues(alpha: 0.12 + flarePhase * 0.05),
            AppColors.primaryMid.withValues(alpha: 0.04),
            Colors.transparent,
          ],
          stops: const [0.0, 0.20, 0.50, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: flareR)),
    );

    // Glow rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final minR = 38.0;
    final maxR = math.min(w, h) * 0.44;
    for (int i = 0; i < 3; i++) {
      final phase = ((ms / 3000.0) + i / 3) % 1.0;
      final ep = Curves.easeOut.transform(phase);
      final r = minR + ep * (maxR - minR);
      final op = math.sin(phase * math.pi) * 0.22;
      if (op < 0.005) continue;
      ringPaint.color = AppColors.surface.withValues(alpha: op);
      canvas.drawCircle(Offset(cx, cy), r, ringPaint);
    }

    // Particles
    final pPaint = Paint();
    for (final p in _particles) {
      final yFrac =
          (1.0 - (loopT * (p.speed * 8000) + p.phase) % 1.0 + 1.0) % 1.0;
      final sinVal = math.sin(yFrac * math.pi).clamp(0.0, 1.0);
      final opacity = (p.op * sinVal).clamp(0.0, 0.85);
      if (opacity < 0.01) continue;
      pPaint.color = AppColors.surface.withValues(alpha: opacity);
      canvas.drawCircle(Offset(p.x * w, yFrac * h), p.r, pPaint);
    }
  }

  @override
  bool shouldRepaint(_SplashBgPainter old) =>
      old.loopT != loopT || old.loopMs != loopMs;

  static double _normX(double px, double w) => (px / w) * 2 - 1;
  static double _normY(double py, double h) => (py / h) * 2 - 1;
  static double _smoothstep(double e0, double e1, double x) {
    final t = ((x - e0) / (e1 - e0)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }
}

class _Particle {
  final double x;
  final double r;
  final double speed;
  final double op;
  final double phase;

  const _Particle({
    required this.x,
    required this.r,
    required this.speed,
    required this.op,
    required this.phase,
  });
}

class _IconBox extends StatelessWidget {
  final double loopT;
  const _IconBox({required this.loopT});

  @override
  Widget build(BuildContext context) {
    // Gradient pulses between brand cyan palette and brand accent-blue
    final pulse = 0.5 + 0.5 * math.sin(loopT * 2 * math.pi * 1.5);

    final glowColor = Color.lerp(
      AppColors.primaryAccent,
      AppColors.purple,
      pulse,
    )!;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120.r,
          height: 120.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.35 + pulse * 0.10),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
        ),
        Container(
          width: 110.r,
          height: 110.r,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAccent.withValues(
                  alpha: 0.35 + pulse * 0.15,
                ),
                blurRadius: 28,
                spreadRadius: 4,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.text.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 44.r,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(26.r),
                      topRight: Radius.circular(26.r),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryLight.withValues(alpha: 0.80),
                        AppColors.primaryLight.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: UJobLogo(
                    variant: LogoVariant.color,
                    width: 78.r,
                    height: 78.r,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomDots extends StatelessWidget {
  final double fade;
  final double loopT;
  const _BottomDots({required this.fade, required this.loopT});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 52.h,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: fade,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = (loopT * 6600 / 700 + i * 0.33) % 1.0;
            final sinVal = math.sin(phase * 2 * math.pi);
            final opacity = (0.30 + sinVal * 0.55).clamp(0.10, 0.90);
            return Transform.translate(
              offset: Offset(0, sinVal * -5.0),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 5.r,
                height: 5.r,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
