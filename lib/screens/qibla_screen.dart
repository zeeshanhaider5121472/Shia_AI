import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_background.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ls = context.read<LocationService>();
      if (!ls.hasLocation && !ls.loading) {
        ls.detectLocation();
      }
    });
  }

  String _directionName(double deg) {
    const names = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW',
    ];
    return names[((deg + 11.25) / 22.5).floor() % 16];
  }

  String _formatDist(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    if (km < 100) return '${km.toStringAsFixed(1)} km';
    return '${km.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km';
  }

  @override
  Widget build(BuildContext context) {
    final ls = context.watch<LocationService>();

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Qibla Finder',
              style:
                  AppStyles.heading(size: 20, color: AppColors.accent)),
        ),
        body: Center(
          child: ls.loading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                        color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text('Detecting location...',
                        style: AppStyles.body(
                            color: AppColors.textSecondary)),
                  ],
                )
              : !ls.hasLocation || ls.qiblaDirection == null
                  ? _buildDetectPrompt(ls)
                  : _buildCompass(ls),
        ),
      ),
    );
  }

  Widget _buildDetectPrompt(LocationService ls) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_rounded,
              size: 72, color: AppColors.textMuted),
          const SizedBox(height: 20),
          Text('Location Required',
              textAlign: TextAlign.center,
              style: AppStyles.heading(size: 20)),
          const SizedBox(height: 8),
          Text(
            'Allow location access to determine the Qibla direction from your position.',
            textAlign: TextAlign.center,
            style: AppStyles.body(
                size: 14, color: AppColors.textSecondary, height: 1.7),
          ),
          if (ls.error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(ls.error,
                textAlign: TextAlign.center,
                style: AppStyles.body(
                    size: 13,
                    color: const Color(0xFFF87171))),
          ],
          const SizedBox(height: 28),
          GestureDetector(
            onTap: ls.detectLocation,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Detect Location',
                  style: AppStyles.body(
                      size: 15,
                      weight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass(LocationService ls) {
    final qibla = ls.qiblaDirection!;
    final dist = ls.distanceToKaaba ?? 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Info card ──
          GlassContainer(
            borderRadius: 20,
            padding:
                const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              children: [
                Text('Qibla Direction',
                    textAlign: TextAlign.center,
                    style: AppStyles.heading(
                        size: 14, color: AppColors.accent)),
                const SizedBox(height: 8),
                Text(
                  '${qibla.toStringAsFixed(1)}\u00B0  '
                  '${_directionName(qibla)}',
                  textAlign: TextAlign.center,
                  style: AppStyles.heading(
                      size: 28, weight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text('${_formatDist(dist)} to Kaaba',
                    textAlign: TextAlign.center,
                    style: AppStyles.caption(
                        size: 13, color: AppColors.textMuted)),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Compass ──
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (ctx, val, child) {
              return Opacity(
                opacity: val,
                child: Transform.scale(
                  scale: 0.85 + 0.15 * val,
                  child: child,
                ),
              );
            },
            child: SizedBox(
              width: 300,
              height: 300,
              child: CustomPaint(
                painter: CompassPainter(
                  qiblaDirection: qibla,
                  accentColor: AppColors.accent,
                  textColor: AppColors.textPrimary,
                  secondaryColor: AppColors.textSecondary,
                  mutedColor: AppColors.textMuted,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Instruction ──
          GlassContainer(
            borderRadius: 14,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Rotate your device so the arrow points upward, then face that direction.',
                    textAlign: TextAlign.center,
                    style: AppStyles.body(
                        size: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  COMPASS PAINTER
// ═══════════════════════════════════════════

class CompassPainter extends CustomPainter {
  final double qiblaDirection;
  final Color accentColor;
  final Color textColor;
  final Color secondaryColor;
  final Color mutedColor;

  CompassPainter({
    required this.qiblaDirection,
    required this.accentColor,
    required this.textColor,
    required this.secondaryColor,
    required this.mutedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final radius = min(cx, cy) - 20;

    // ── Outer ring ──
    canvas.drawCircle(
      center, radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = mutedColor.withOpacity(0.35),
    );

    // ── Inner ring ──
    canvas.drawCircle(
      center, radius - 28,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = mutedColor.withOpacity(0.15),
    );

    // ── Tick marks ──
    for (int deg = 0; deg < 360; deg += 2) {
      final isMajor = deg % 30 == 0;
      final isMedium = deg % 10 == 0;
      if (!isMajor && !isMedium) continue;

      final rad = (deg - 90) * pi / 180;
      final inner = radius - (isMajor ? 20 : 10);
      final outer = radius - 3;

      canvas.drawLine(
        Offset(cx + inner * cos(rad), cy + inner * sin(rad)),
        Offset(cx + outer * cos(rad), cy + outer * sin(rad)),
        Paint()
          ..strokeWidth = isMajor ? 2.5 : 1
          ..strokeCap = StrokeCap.round
          ..color = isMajor
              ? textColor.withOpacity(0.6)
              : mutedColor.withOpacity(0.3),
      );
    }

    // ── Degree numbers (every 30°, skip cardinals) ──
    for (int deg = 0; deg < 360; deg += 30) {
      if (deg % 90 == 0) continue;
      final rad = (deg - 90) * pi / 180;
      final r = radius - 38;
      _text(canvas, '$deg',
          Offset(cx + r * cos(rad), cy + r * sin(rad)),
          TextStyle(color: mutedColor, fontSize: 10));
    }

    // ── Intercardinal dots ──
    for (final deg in [45, 135, 225, 315]) {
      final rad = (deg - 90) * pi / 180;
      final r = radius - 38;
      canvas.drawCircle(
        Offset(cx + r * cos(rad), cy + r * sin(rad)),
        2,
        Paint()..color = mutedColor.withOpacity(0.4),
      );
    }

    // ── Cardinal labels ──
    final cardinals = [
      ('N', 0, true),
      ('E', 90, false),
      ('S', 180, false),
      ('W', 270, false),
    ];
    for (final (label, deg, isNorth) in cardinals) {
      final rad = (deg - 90) * pi / 180;
      final r = radius - 38;
      _text(
        canvas, label,
        Offset(cx + r * cos(rad), cy + r * sin(rad)),
        TextStyle(
          color: isNorth ? const Color(0xFFEF4444) : secondaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    // ── Qibla arrow ──
    final qRad = (qiblaDirection - 90) * pi / 180;
    final arrowLen = radius - 55;
    final arrowEnd = Offset(
      cx + arrowLen * cos(qRad),
      cy + arrowLen * sin(qRad),
    );

    // Glow
    canvas.drawLine(
      center, arrowEnd,
      Paint()
        ..color = accentColor.withOpacity(0.15)
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Line
    canvas.drawLine(
      center, arrowEnd,
      Paint()
        ..color = accentColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Arrowhead
    final headLen = 14.0;
    final headAngle = atan2(arrowEnd.dy - cy, arrowEnd.dx - cx);
    final path = Path()
      ..moveTo(
        arrowEnd.dx + headLen * cos(headAngle),
        arrowEnd.dy + headLen * sin(headAngle),
      )
      ..lineTo(
        arrowEnd.dx + headLen * 0.5 * cos(headAngle + 2.5),
        arrowEnd.dy + headLen * 0.5 * sin(headAngle + 2.5),
      )
      ..lineTo(
        arrowEnd.dx + headLen * 0.5 * cos(headAngle - 2.5),
        arrowEnd.dy + headLen * 0.5 * sin(headAngle - 2.5),
      )
      ..close();
    canvas.drawPath(path, Paint()..color = accentColor);

    // Kaaba square at tip
    final kaabaR = arrowLen + 20;
    final kaabaPos = Offset(
      cx + kaabaR * cos(qRad),
      cy + kaabaR * sin(qRad),
    );
    canvas.drawRect(
      Rect.fromCenter(center: kaabaPos, width: 13, height: 13),
      Paint()..color = accentColor,
    );

    // ── Center dot ──
    canvas.drawCircle(center, 4, Paint()..color = accentColor);
  }

  void _text(Canvas canvas, String text, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CompassPainter old) =>
      old.qiblaDirection != qiblaDirection;
}
