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

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final fav = context.watch<FavoritesService>();

    // Resolve favorites across ALL sections
    final items = <SurahModel>[];
    for (final id in fav.ids) {
      final item = ds.findItemById(id);
      if (item != null) items.add(item);
    }

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Favorites',
              style:
                  AppStyles.heading(size: 20, color: AppColors.accent)),
        ),
        body: items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_border_rounded,
                        size: 72, color: AppColors.textMuted),
                    const SizedBox(height: 14),
                    Text('No favorites yet',
                        textAlign: TextAlign.center,
                        style: AppStyles.body(
                            size: 16, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Text('Tap the star icon to save items here',
                        textAlign: TextAlign.center,
                        style: AppStyles.caption(
                            size: 13, color: AppColors.textMuted)),
                  ],
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassContainer(
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      onTap: () {
                        if (item.category == 'quran_chapters') {
                          final qItem = ds.getItem(
                              'quranzikr', 'quran_verses', item.id);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SurahDetailScreen(
                                      prayersItem: item,
                                      quranItem: qItem)));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      DetailScreen(item: item)));
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.accent, size: 22),
                          const SizedBox(width: 14),
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
                                Text(item.englishTitle ?? item.title,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.body(
                                        size: 14,
                                        weight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => fav.toggle(item.id),
                            icon: Icon(Icons.close_rounded,
                                color: AppColors.textMuted, size: 20),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
