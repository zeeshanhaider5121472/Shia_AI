import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/data_models.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_container.dart';

class DetailScreen extends StatelessWidget {
  final SurahModel item;
  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesService>();
    final isFav = fav.isFav(item.id);

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(item.englishTitle ?? item.title,
              style: AppStyles.heading(size: 17, color: AppColors.accent)),
          actions: [
            IconButton(
              onPressed: () => fav.toggle(item.id),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                  key: ValueKey(isFav),
                  color: isFav ? AppColors.accent : AppColors.textSecondary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Header ──
              // GlassContainer(
              //   borderRadius: 22,
              //   padding:
              //       const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              //   child: Column(
              //     children: [
              //       if (item.arabicName != null &&
              //           item.arabicName!.isNotEmpty)
              //         Text(item.arabicName!,
              //             textAlign: TextAlign.center,
              //             style: AppStyles.arabic(
              //                 size: 36,
              //                 weight: FontWeight.w700,
              //                 color: AppColors.accent)),
              //       const SizedBox(height: 8),
              //       Text(item.englishTitle ?? '',
              //           textAlign: TextAlign.center,
              //           style: AppStyles.heading(
              //               size: 20, weight: FontWeight.w600)),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 16),

              // ── Description ──
              if (item.description != null && item.description!.isNotEmpty) ...[
                GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_stories_rounded,
                              color: AppColors.accent, size: 16),
                          const SizedBox(width: 8),
                          Text('Virtues & Benefits',
                              style: AppStyles.heading(
                                  size: 14, color: AppColors.accent)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(item.description!,
                          textAlign: TextAlign.center,
                          style: AppStyles.body(size: 13.5, height: 1.85)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Content ──
              if (item.verses.isNotEmpty)
                _buildVerseList(item.verses)
              else
                _buildRawContent(item.content),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Verse list — NO glass, number at END.
  Widget _buildVerseList(List<VerseModel> verses) {
    final hasBismillah = verses.isNotEmpty && verses[0].number.isEmpty;

    return Column(
      children: [
        if (hasBismillah)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(verses[0].arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppStyles.arabic(
                    size: 28,
                    weight: FontWeight.w700,
                    color: AppColors.accent)),
          ),
        ...List.generate(verses.length, (i) {
          final v = verses[i];
          if (i == 0 && v.number.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Arabic + number at end
                RichText(
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: v.arabic,
                        style: AppStyles.arabic(size: 24)
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      if (v.number.isNotEmpty)
                        TextSpan(
                          text: '  \u00AB${toArabicNumeral(v.number)}\u00BB  ',
                          style: AppStyles.arabic(
                              size: 15,
                              weight: FontWeight.w700,
                              color: AppColors.accent),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Divider(color: AppColors.divider, height: 1),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Raw content fallback.
  Widget _buildRawContent(String content) {
    final lines = content.split(RegExp(r'\r?\n'));

    return Column(
      children: lines.map((line) {
        final t = line.trim();
        if (t.isEmpty) return const SizedBox(height: 12);

        final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(t);
        final isHeading = t == t.toUpperCase() && t.length < 80 && t.length > 3;

        if (isArabic) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(t,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppStyles.arabic(size: 22)),
          );
        }

        if (isHeading) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(t,
                textAlign: TextAlign.center,
                style: AppStyles.heading(size: 15, color: AppColors.accent)),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(t,
              textAlign: TextAlign.center, style: AppStyles.body(size: 13.5)),
        );
      }).toList(),
    );
  }
}
