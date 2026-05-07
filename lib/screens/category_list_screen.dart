import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../services/data_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_background.dart';
import 'surah_detail_screen.dart';
import 'detail_screen.dart';

class CategoryListScreen extends StatefulWidget {
  final String title;
  final List<SurahModel> items;

  const CategoryListScreen({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final fav = context.watch<FavoritesService>();

    final filtered = _query.isEmpty
        ? widget.items
        : widget.items
            .where((i) =>
                i.title.toLowerCase().contains(_query.toLowerCase()) ||
                (i.englishTitle
                        ?.toLowerCase()
                        .contains(_query.toLowerCase()) ??
                    false) ||
                (i.arabicName?.contains(_query) ?? false) ||
                (i.description
                        ?.toLowerCase()
                        .contains(_query.toLowerCase()) ??
                    false))
            .toList();

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.title,
              style:
                  AppStyles.heading(size: 20, color: AppColors.accent)),
        ),
        body: Column(
          children: [
            // ── Search ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
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
                          hintText: 'Search...',
                          hintStyle:
                              AppStyles.body(color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── List ──
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 14),
                          Text(
                            widget.items.isEmpty
                                ? 'No data available yet'
                                : 'No items match your search',
                            textAlign: TextAlign.center,
                            style:
                                AppStyles.body(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final item = filtered[i];
                        final isFav = fav.isFav(item.id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassContainer(
                            borderRadius: 16,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            onTap: () => _openItem(item, ds),
                            child: Row(
                              children: [
                                // Number
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.accent.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text('${i + 1}',
                                        style: AppStyles.body(
                                            size: 13,
                                            weight: FontWeight.w700,
                                            color: AppColors.accent)),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Titles
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (item.arabicName != null &&
                                          item.arabicName!.isNotEmpty)
                                        Text(item.arabicName!,
                                            textAlign: TextAlign.center,
                                            style: AppStyles.arabic(
                                                size: 18,
                                                color: AppColors.accent)),
                                      Text(
                                          item.englishTitle ?? item.title,
                                          textAlign: TextAlign.center,
                                          style: AppStyles.body(
                                              size: 14,
                                              weight: FontWeight.w600,
                                              color:
                                                  AppColors.textPrimary)),
                                      if (item.description != null &&
                                          item.description!.isNotEmpty)
                                        Text(
                                            item.description!.length > 80
                                                ? '${item.description!.substring(0, 80)}...'
                                                : item.description!,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: AppStyles.caption(
                                                size: 11,
                                                color:
                                                    AppColors.textMuted)),
                                    ],
                                  ),
                                ),

                                // Star
                                GestureDetector(
                                  onTap: () => fav.toggle(item.id),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(
                                        milliseconds: 250),
                                    child: Icon(
                                      isFav
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      key: ValueKey(isFav),
                                      color: isFav
                                          ? AppColors.accent
                                          : AppColors.textMuted,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

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
                    SurahDetailScreen(
                        prayersItem: pItem, quranItem: item)));
      } else {
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => DetailScreen(item: item)));
      }
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailScreen(item: item)));
    }
  }
}
