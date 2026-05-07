import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_background.dart';
import 'calender_screen.dart';
import 'category_list_screen.dart';
import 'surah_detail_screen.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';
import 'tasbeeh_screen.dart';
import 'hadith_list_screen.dart';
import 'preferences_screen.dart';
import 'qibla_screen.dart';

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
              SliverToBoxAdapter(
                child: _fade(0, Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 4),
                  child: Text('Shia AI',
                      textAlign: TextAlign.center,
                      style: AppStyles.heading(
                          size: 26,
                          weight: FontWeight.w800,
                          color: AppColors.accent)),
                )),
              ),
              SliverToBoxAdapter(
                child: _fade(0, Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064E\u0647\u0650 \u0627\u0644\u0631\u0651\u064E\u062D\u0652\u0645\u0670\u0646\u0650 \u0627\u0644\u0631\u0651\u064E\u062D\u0650\u064A\u0652\u0645\u0650',
                    textAlign: TextAlign.center,
                    style: AppStyles.arabic(
                        size: 20, color: AppColors.textMuted),
                  ),
                )),
              ),
              SliverToBoxAdapter(
                child: _fade(1, Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: GlassContainer(
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: AppColors.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            style: AppStyles.body(size: 14),
                            decoration: InputDecoration(
                              hintText: 'Search surahs, duas, prayers...',
                              hintStyle:
                                  AppStyles.body(color: AppColors.textMuted),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onSubmitted: (q) {
                              if (q.trim().isNotEmpty) {
                                _showSearchResults(
                                    ds.search(q.trim()), q.trim());
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
              SliverToBoxAdapter(
                child: _fade(2, Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: _buildHadithCard(ds),
                )),
              ),
              SliverToBoxAdapter(
                child: _fade(3, Padding(
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
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
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

  // ── CACHED hadith — same text on expand/collapse ──
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
                  style: AppStyles.heading(
                      size: 14, color: AppColors.accent)),
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
                  size: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.8),
            ),
          ),
          if (isLong)
            GestureDetector(
              onTap: () =>
                  setState(() => _hadithExpanded = !_hadithExpanded),
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

  // ── PRAYER TIMES — uses LocationService API ──
  Widget _buildPrayerTimes(LocationService ls) {
    final times = ls.prayerTimes.isNotEmpty
        ? ls.prayerTimes.entries
            .map((e) => (e.key, e.value))
            .toList()
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
          // Location row
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
                            size: 10,
                            color: const Color(0xFFF87171))),
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
                  style: AppStyles.heading(
                      size: 13, color: AppColors.accent)),
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            Text(t.$1,
                                style: AppStyles.caption(size: 10)),
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
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TasbeehScreen()));
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
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CalendarScreen()));
        break;
      case 'qibla':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const QiblaScreen()));
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
                    title: title,
                    items: ds.getCategory('prayers', 'namaz'))));
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
                    title: title,
                    items: ds.getMergedItems(['ziyarat']))));
        break;
      case 'amal':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CategoryListScreen(
                    title: title,
                    items: ds.getMergedItems(
                        ['amal', 'special_prayers']))));
        break;
      case 'munajaat':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CategoryListScreen(
                    title: title,
                    items: ds.getMergedItems(
                        ['munajaat', 'supplications']))));
        break;
    }
  }

  void _showSearchResults(List<SurahModel> results, String query) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        builder: (ctx, scrollCtrl) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Results for "$query"',
                      textAlign: TextAlign.center,
                      style: AppStyles.heading(
                          size: 16, color: AppColors.accent)),
                ),
                Expanded(
                  child: results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text('No results found',
                                  style: AppStyles.body(
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollCtrl,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: results.length,
                          itemBuilder: (ctx, i) {
                            final item = results[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GlassContainer(
                                borderRadius: 14,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _openItem(item);
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent
                                            .withOpacity(0.08),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${item.section} › ${item.category}',
                                        style: AppStyles.caption(
                                            size: 10,
                                            color: AppColors.textMuted),
                                      ),
                                    ),
                                    if (item.arabicName != null &&
                                        item.arabicName!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(item.arabicName!,
                                          textAlign: TextAlign.center,
                                          style: AppStyles.arabic(
                                              size: 20,
                                              color: AppColors.accent)),
                                    ],
                                    Text(item.englishTitle ?? item.title,
                                        textAlign: TextAlign.center,
                                        style: AppStyles.body(
                                            size: 14,
                                            weight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openItem(SurahModel item) {
    final ds = context.read<DataService>();
    if (item.category == 'quran_chapters') {
      final qItem = ds.getItem('quranzikr', 'quran verses', item.id);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SurahDetailScreen(
                  prayersItem: item, quranItem: qItem)));
    } else if (item.category == 'quran verses') {
      final pItem = ds.getItem('prayers', 'quran_chapters', item.id);
      if (pItem != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SurahDetailScreen(
                    prayersItem: pItem, quranItem: item)));
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => DetailScreen(item: item)));
      }
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailScreen(item: item)));
    }
  }
}
