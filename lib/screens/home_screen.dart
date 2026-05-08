import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/data_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_container.dart';
import 'ai_search_screen.dart';
import 'calender_screen.dart';
import 'category_list_screen.dart';
import 'favorites_screen.dart';
import 'hadith_list_screen.dart';
import 'preferences_screen.dart';
import 'qibla_screen.dart';
import 'tasbeeh_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _visible = false;
  bool _hadithExpanded = false;
  String? _cachedHadith;

  final _cats = <(String, String, IconData)>[
    ('favorites', 'Favorites', Icons.star_rounded),
    ('quran_chapters', 'Surahs', Icons.menu_book_rounded),
    ('duas', 'Duas', Icons.back_hand_rounded),
    ('namaz', 'Namaz', Icons.mosque_rounded),
    ('ziyarat', 'Ziyarats', Icons.place_rounded),
    ('amal', 'Aamaal', Icons.auto_stories_rounded),
    ('munajaat', 'Munajaat', Icons.favorite_rounded),
    ('hadiths', 'Hadiths', Icons.format_quote_rounded),
    ('calendar', 'Calendar\n& Times', Icons.calendar_month_rounded),
    ('qibla', 'Qibla\nFinder', Icons.explore_rounded),
    ('tasbeeh', 'Tasbeeh\nCounter', Icons.radio_button_checked_rounded),
    ('preferences', 'Preferences', Icons.settings_rounded),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _visible = true);
    });
    // Auto-detect location on first open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ls = context.read<LocationService>();
      if (!ls.hasLocation && !ls.loading) {
        ls.detectLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final ls = context.watch<LocationService>();
    context.watch<SettingsService>();

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Title with font icon ──
              SliverToBoxAdapter(
                child: _fade(
                    0,
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Shia AI',
                              textAlign: TextAlign.center,
                              style: AppStyles.heading(
                                  size: 26,
                                  weight: FontWeight.w800,
                                  color: AppColors.accent)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const PreferencesScreen())),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.text_fields_rounded,
                                  color: AppColors.accent.withOpacity(0.6),
                                  size: 16),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              // ── Bismillah (BRIGHTER) ──
              SliverToBoxAdapter(
                child: _fade(
                    0,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064E\u0647\u0650 \u0627\u0644\u0631\u0651\u064E\u062D\u0652\u0645\u0670\u0646\u0650 \u0627\u0644\u0631\u0651\u064E\u062D\u0650\u064A\u0652\u0645\u0650',
                        textAlign: TextAlign.center,
                        style: AppStyles.arabic(
                            size: 20, color: AppColors.textSecondary),
                      ),
                    )),
              ),
              // ── Galaxy Search Bar ──
              SliverToBoxAdapter(
                child: _fade(
                    1,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                      child: _GalaxySearchBar(
                        onSubmitted: (q) {
                          if (q.trim().isNotEmpty) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AiSearchScreen(
                                        initialQuery: q.trim())));
                          }
                        },
                      ),
                    )),
              ),
              // ── Daily Hadith ──
              SliverToBoxAdapter(
                child: _fade(
                    2,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: _buildHadithCard(ds),
                    )),
              ),
              // ── Prayer Times (auto-loaded) ──
              SliverToBoxAdapter(
                child: _fade(
                    3,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: _buildPrayerTimes(ls),
                    )),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Text('Explore',
                      textAlign: TextAlign.center,
                      style: AppStyles.heading(size: 16)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildGridItem(i),
                    childCount: _cats.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fade(int delay, Widget child) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 400 + delay * 80),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }

  Widget _buildHadithCard(DataService ds) {
    _cachedHadith ??= ds.getDailyHadith();
    final text = _cachedHadith!;
    final isLong = text.length > 180;

    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.format_quote_rounded,
                  color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text('Daily Hadith',
                  style: AppStyles.heading(size: 14, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: _hadithExpanded ? null : 3,
              overflow: _hadithExpanded ? null : TextOverflow.ellipsis,
              style: AppStyles.body(
                  size: 13.5, color: AppColors.textSecondary, height: 1.8),
            ),
          ),
          if (isLong)
            GestureDetector(
              onTap: () => setState(() => _hadithExpanded = !_hadithExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  _hadithExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimes(LocationService ls) {
    final times = ls.prayerTimes.isNotEmpty
        ? ls.prayerTimes.entries.map((e) => (e.key, e.value)).toList()
        : [
            ('Fajr', '--:--'),
            ('Sunrise', '--:--'),
            ('Dhuhr', '--:--'),
            ('Asr', '--:--'),
            ('Maghrib', '--:--'),
            ('Isha', '--:--'),
          ];

    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => ls.detectLocation(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (ls.loading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: AppColors.accent),
                  )
                else
                  Icon(Icons.location_on_rounded,
                      color: AppColors.accent, size: 16),
                if (ls.cityName.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(ls.cityName,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.caption(
                            size: 10, color: AppColors.textMuted)),
                  ),
                ] else if (ls.error.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(ls.error,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.caption(
                            size: 10, color: const Color(0xFFF87171))),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(Icons.refresh_rounded,
                    color: AppColors.textMuted, size: 13),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_rounded,
                  color: AppColors.accent, size: 15),
              const SizedBox(width: 6),
              Text('Prayer Times',
                  style: AppStyles.heading(size: 13, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: times
                  .map((t) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            Text(t.$1, style: AppStyles.caption(size: 10)),
                            const SizedBox(height: 4),
                            Text(t.$2,
                                style: AppStyles.heading(
                                    size: 14, weight: FontWeight.w600)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(int index) {
    final c = _cats[index];
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 350 + index * 40),
      curve: Curves.easeOutCubic,
      child: GlassContainer(
        borderRadius: 18,
        padding: const EdgeInsets.all(10),
        onTap: () => _onTap(c.$1, c.$2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(c.$3, color: AppColors.accent, size: 24),
            ),
            const SizedBox(height: 10),
            Text(c.$2,
                textAlign: TextAlign.center,
                style: AppStyles.body(
                    size: 10.5,
                    weight: FontWeight.w600,
                    color: AppColors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  void _onTap(String key, String title) {
    final ds = context.read<DataService>();
    switch (key) {
      case 'favorites':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FavoritesScreen()));
        break;
      case 'tasbeeh':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const TasbeehScreen()));
        break;
      case 'hadiths':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HadithListScreen()));
        break;
      case 'preferences':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PreferencesScreen()));
        break;
      case 'calendar':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
        break;
      case 'qibla':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const QiblaScreen()));
        break;
      case 'quran_chapters':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CategoryListScreen(
                    title: title,
                    items: ds.getCategory('prayers', 'quran_chapters'))));
        break;
      case 'namaz':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CategoryListScreen(
                    title: title, items: ds.getCategory('prayers', 'namaz'))));
        break;
      case 'duas':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CategoryListScreen(
                    title: title,
                    items: ds.getMergedItems(['duas', 'taweez']))));
        break;
      case 'ziyarat':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CategoryListScreen(
                    title: title, items: ds.getMergedItems(['ziyarat']))));
        break;
      case 'amal':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CategoryListScreen(
                    title: title,
                    items: ds.getMergedItems(['amal', 'special_prayers']))));
        break;
      case 'munajaat':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CategoryListScreen(
                    title: title,
                    items: ds.getMergedItems(['munajaat', 'supplications']))));
        break;
    }
  }
}

// ═══════════════════════════════════════════
//  GALAXY SEARCH BAR
// ═══════════════════════════════════════════

class _GalaxySearchBar extends StatefulWidget {
  final ValueChanged<String>? onSubmitted;
  const _GalaxySearchBar({this.onSubmitted});

  @override
  State<_GalaxySearchBar> createState() => _GalaxySearchBarState();
}

class _GalaxySearchBarState extends State<_GalaxySearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (ctx, _) {
              final dy = sin(_ctrl.value * 2 * pi) * 1.5;
              final tilt = sin(_ctrl.value * 4 * pi) * 0.08;
              final glow = _focusNode.hasFocus
                  ? 0.6 + sin(_ctrl.value * 2 * pi) * 0.2
                  : 0.3 + sin(_ctrl.value * 2 * pi) * 0.15;

              return Transform.translate(
                offset: Offset(0, dy),
                child: Transform.rotate(
                  angle: tilt,
                  child: CustomPaint(
                    size: const Size(28, 28),
                    painter: _RobotPainter(
                      color: AppColors.accent,
                      glow: glow,
                      focused: _focusNode.hasFocus,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              style: AppStyles.body(size: 14),
              decoration: InputDecoration(
                hintText: 'Chat with Shia AI...',
                hintStyle: AppStyles.body(color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: widget.onSubmitted,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.accent.withOpacity(0.5),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  CUTE NEON ROBOT PAINTER
// ═══════════════════════════════════════════

class _RobotPainter extends CustomPainter {
  final Color color;
  final double glow;
  final bool focused;

  _RobotPainter({
    required this.color,
    required this.glow,
    required this.focused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 1;
    final headR = size.width * 0.36;

    // ── Glow aura ──
    canvas.drawCircle(
      Offset(cx, cy),
      headR + 5,
      Paint()
        ..color = color.withOpacity(glow * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // ── Antenna stem ──
    canvas.drawLine(
      Offset(cx, cy - headR + 1),
      Offset(cx, cy - headR - 4),
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // ── Antenna ball ──
    canvas.drawCircle(
      Offset(cx, cy - headR - 5.5),
      focused ? 2.8 : 2.2,
      Paint()..color = color,
    );

    // ── Ear bolts ──
    canvas.drawCircle(
        Offset(cx - headR - 1, cy - 1), 1.5, Paint()..color = color);
    canvas.drawCircle(
        Offset(cx + headR + 1, cy - 1), 1.5, Paint()..color = color);

    // ── Head outline ──
    canvas.drawCircle(
      Offset(cx, cy),
      headR,
      Paint()..color = color.withOpacity(0.06),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      headR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = color,
    );

    // ── Eyes ──
    final eyeY = cy - 1.5;
    final eyeX = headR * 0.4;
    final eyeR = focused ? 2.8 : 2.2;

    // Eye glow
    canvas.drawCircle(Offset(cx - eyeX, eyeY), eyeR + 2,
        Paint()..color = color.withOpacity(glow * 0.25));
    canvas.drawCircle(Offset(cx + eyeX, eyeY), eyeR + 2,
        Paint()..color = color.withOpacity(glow * 0.25));

    // Eye dots
    canvas.drawCircle(
        Offset(cx - eyeX, eyeY), eyeR, Paint()..color = color);
    canvas.drawCircle(
        Offset(cx + eyeX, eyeY), eyeR, Paint()..color = color);

    // ── Smile ──
    final smileW = headR * 0.55;
    final smileH = headR * 0.35;
    final smileRect = Rect.fromCenter(
      center: Offset(cx, cy + 3.5),
      width: smileW,
      height: smileH,
    );
    canvas.drawArc(
      smileRect,
      0.15,
      0.9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RobotPainter old) =>
      old.glow != glow || old.focused != focused;
}
