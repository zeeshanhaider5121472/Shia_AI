import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_background.dart';
import 'category_list_screen.dart';
import 'surah_detail_screen.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';
import 'tasbeeh_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _visible = false;
  String _locationName = 'Tap to detect location';
  bool _loadingLocation = false;

  // (key, label, icon)
  final _cats = <(String, String, IconData)>[
    ('favorites', 'Favorites', Icons.star_rounded),
    ('quran_chapters', 'Surahs', Icons.menu_book_rounded),
    ('duas', 'Duas', Icons.back_hand_rounded),
    ('supplications', 'Supplications', Icons.volunteer_activism_rounded),
    ('taqeebat', 'Taqeebat\ne Namaz', Icons.accessibility_new_rounded),
    ('namaz', 'Namaz', Icons.mosque_rounded),
    ('ziyarats', 'Ziyarats', Icons.place_rounded),
    ('aamaal', 'Aamaal', Icons.auto_stories_rounded),
    ('calendar', 'Calendar\n& Times', Icons.calendar_month_rounded),
    ('library', 'Library', Icons.local_library_rounded),
    ('munajaat', 'Munajaat', Icons.favorite_rounded),
    ('baqeyaat', 'Baqeyaat as\nSaalehaat', Icons.bookmark_rounded),
    ('qibla', 'Qibla\nFinder', Icons.explore_rounded),
    ('tasbeeh', 'Tasbeeh\nCounter', Icons.radio_button_checked_rounded),
    ('settings', 'Preferences', Icons.settings_rounded),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  // ── Location ──

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationName = 'Location permission denied';
          _loadingLocation = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      final places = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (places.isNotEmpty) {
        final p = places.first;
        final name = [p.locality ?? p.subAdministrativeArea ?? '', p.country ?? '']
            .where((s) => s.isNotEmpty)
            .join(', ');
        setState(() {
          _locationName = name.isEmpty ? 'Location found' : name;
          _loadingLocation = false;
        });
      }
    } catch (_) {
      setState(() {
        _locationName = 'Unable to detect';
        _loadingLocation = false;
      });
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Title ──
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

              // ── Bismillah ──
              SliverToBoxAdapter(
                child: _fade(0, Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064E\u0647\u0650 \u0627\u0644\u0631\u0651\u064E\u062D\u0652\u0645\u0670\u0646\u0650 \u0627\u0644\u0631\u0651\u064E\u062D\u0650\u064A\u0652\u0645\u0650',
                    textAlign: TextAlign.center,
                    style: AppStyles.arabic(size: 20, color: AppColors.textMuted),
                  ),
                )),
              ),

              // ── Search ──
              SliverToBoxAdapter(
                child: _fade(1, Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: GlassContainer(
                    borderRadius: 14,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                                _showSearchResults(ds.search(q.trim()), q.trim());
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),

              // ── Daily Hadith ──
              SliverToBoxAdapter(
                child: _fade(2, Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: GlassContainer(
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
                        Text(ds.getDailyHadith(),
                            textAlign: TextAlign.center,
                            style: AppStyles.body(
                                size: 13.5,
                                color: AppColors.textSecondary,
                                height: 1.8)),
                      ],
                    ),
                  ),
                )),
              ),

              // ── Prayer Times ──
              SliverToBoxAdapter(
                child: _fade(3, Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: _buildPrayerTimes(),
                )),
              ),

              // ── Section title ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Text('Explore',
                      textAlign: TextAlign.center,
                      style: AppStyles.heading(size: 16)),
                ),
              ),

              // ── Grid ──
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

  // ── Staggered fade ──
  Widget _fade(int delay, Widget child) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500 + delay * 100),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        duration: Duration(milliseconds: 500 + delay * 100),
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }

  // ── Prayer Times ──
  Widget _buildPrayerTimes() {
    const times = [
      ('Fajr', '5:12'),
      ('Sunrise', '6:34'),
      ('Dhuhr', '12:15'),
      ('Asr', '3:45'),
      ('Maghrib', '6:58'),
      ('Isha', '8:20'),
    ];

    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _getLocation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_loadingLocation)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: AppColors.accent),
                  )
                else
                  Icon(Icons.location_on_rounded,
                      color: AppColors.accent, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(_locationName,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.caption(
                          size: 12, color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 4),
                Icon(Icons.refresh_rounded,
                    color: AppColors.textMuted, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_rounded,
                  color: AppColors.accent, size: 15),
              const SizedBox(width: 6),
              Text('Prayer Times',
                  style:
                      AppStyles.heading(size: 13, color: AppColors.accent)),
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

  // ── Grid item ──
  Widget _buildGridItem(int index) {
    final c = _cats[index];
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 400 + index * 45),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.25),
        duration: Duration(milliseconds: 400 + index * 45),
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
      ),
    );
  }

  // ── Navigation ──
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
      case 'qibla':
      case 'settings':
      case 'calendar':
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$title — Coming Soon',
              style: AppStyles.body(size: 13)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface,
        ));
        break;
      case 'quran_chapters':
        // Surahs: only from prayers (detail screen has 2 tabs)
        final items = ds.getCategory('prayers', 'quran_chapters');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    CategoryListScreen(title: title, items: items)));
        break;
      default:
        // All other categories: merged across all sections
        final items = ds.getMergedItems([key]);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    CategoryListScreen(title: title, items: items)));
    }
  }

  // ── Search results bottom sheet ──
  void _showSearchResults(List<SurahModel> results, String query) {
    final ds = context.read<DataService>();

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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  _openItem(item, ds);
                                },
                                child: Column(
                                  children: [
                                    // Source badge
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
                                    Text(
                                        item.englishTitle ?? item.title,
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

  /// Opens the correct detail screen based on item category.
  void _openItem(SurahModel item, DataService ds) {
    if (item.category == 'quran_chapters') {
      final qItem = ds.getItem('quranzikr', 'quran_verses', item.id);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  SurahDetailScreen(prayersItem: item, quranItem: qItem)));
    } else if (item.category == 'quran_verses') {
      final pItem = ds.getItem('prayers', 'quran_chapters', item.id);
      if (pItem != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    SurahDetailScreen(prayersItem: pItem, quranItem: item)));
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
