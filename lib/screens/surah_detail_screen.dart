import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/data_models.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_container.dart';

class SurahDetailScreen extends StatelessWidget {
  final SurahModel prayersItem;
  final SurahModel? quranItem;

  const SurahDetailScreen({
    super.key,
    required this.prayersItem,
    this.quranItem,
  });

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesService>();
    final isFav = fav.isFav(prayersItem.id);
    final hasTranslation = quranItem != null;

    return DefaultTabController(
      length: hasTranslation ? 2 : 1,
      child: GlassBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              prayersItem.englishTitle ?? prayersItem.title,
              style: AppStyles.heading(size: 17, color: AppColors.accent),
            ),
            actions: [
              IconButton(
                onPressed: () => fav.toggle(prayersItem.id),
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
            bottom: hasTranslation
                ? TabBar(
                    indicatorColor: AppColors.accent,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.accent,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle:
                        AppStyles.body(size: 13, weight: FontWeight.w700),
                    unselectedLabelStyle:
                        AppStyles.body(size: 13, weight: FontWeight.w400),
                    tabs: const [
                      Tab(text: 'Arabic'),
                      Tab(text: 'Translation'),
                    ],
                  )
                : null,
          ),
          body: TabBarView(
            children: [
              _buildTab(context, prayersItem, showTranslation: false),
              if (hasTranslation)
                _buildTab(context, quranItem!, showTranslation: true)
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, SurahModel item,
      {required bool showTranslation}) {
    final hasVerses = item.verses.isNotEmpty;
    final hasContent = item.content.trim().isNotEmpty;
    final hasDesc = item.description != null && item.description!.isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // _header(item),
          const SizedBox(height: 16),
          if (hasDesc) ...[
            _description(item.description!),
            const SizedBox(height: 16),
          ],
          if (hasVerses)
            _verseList(item.verses, showTranslation: showTranslation)
          else if (hasContent)
            _rawContent(item.content)
          else
            _emptyState(showTranslation),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Widget _header(SurahModel item) {
  //   return GlassContainer(
  //     borderRadius: 22,
  //     padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
  //     child: Column(
  //       children: [
  //         if (item.arabicName != null && item.arabicName!.isNotEmpty)
  //           Text(item.arabicName!,
  //               textAlign: TextAlign.center,
  //               style: AppStyles.arabic(
  //                   size: 36,
  //                   weight: FontWeight.w700,
  //                   color: AppColors.accent)),
  //         const SizedBox(height: 8),
  //         Text(item.englishTitle ?? '',
  //             textAlign: TextAlign.center,
  //             style: AppStyles.heading(size: 20, weight: FontWeight.w600)),
  //         if (item.verses.isNotEmpty) ...[
  //           const SizedBox(height: 14),
  //           Container(
  //             padding:
  //                 const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  //             decoration: BoxDecoration(
  //               color: AppColors.accent.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             child: Text('${item.verses.length} Verses',
  //                 style: AppStyles.caption(
  //                     size: 12,
  //                     weight: FontWeight.w600,
  //                     color: AppColors.accent)),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _description(String text) {
    return GlassContainer(
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
                  style: AppStyles.heading(size: 14, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 12),
          Text(text,
              textAlign: TextAlign.center,
              style: AppStyles.body(size: 13.5, height: 1.85)),
        ],
      ),
    );
  }

  // ── Verse list: transliteration in BOTH tabs, translation only in Translation tab ──
  Widget _verseList(List<VerseModel> verses, {required bool showTranslation}) {
    final hasBismillah = verses.isNotEmpty && verses[0].number.isEmpty;

    return Column(
      children: [
        if (hasBismillah)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Text(verses[0].arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppStyles.arabic(
                        size: 28,
                        weight: FontWeight.w700,
                        color: AppColors.accent)),
                // Transliteration for Bismillah — BOTH tabs
                if (verses[0].transliteration != null &&
                    verses[0].transliteration!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(verses[0].transliteration!,
                      textAlign: TextAlign.center,
                      style: AppStyles.body(
                          size: 12, color: AppColors.textMuted, height: 1.5)),
                ],
                // Translation for Bismillah — only Translation tab
                if (showTranslation &&
                    verses[0].translation != null &&
                    verses[0].translation!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(verses[0].translation!,
                      textAlign: TextAlign.center,
                      style: AppStyles.body(
                          size: 13,
                          color: AppColors.textSecondary,
                          height: 1.6)),
                ],
              ],
            ),
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
                const SizedBox(height: 14),

                // ── Arabic + verse number at END ──
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

                // ── Transliteration — BOTH tabs ──
                if (v.transliteration != null &&
                    v.transliteration!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(v.transliteration!,
                      textAlign: TextAlign.center,
                      style: AppStyles.body(
                          size: 12.5, color: AppColors.textMuted, height: 1.6)),
                ],

                // ── Translation — only Translation tab ──
                if (showTranslation &&
                    v.translation != null &&
                    v.translation!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(v.translation!,
                      textAlign: TextAlign.center,
                      style: AppStyles.body(
                          size: 13.5,
                          color: AppColors.textSecondary,
                          height: 1.7)),
                ],

                const SizedBox(height: 12),
                Divider(color: AppColors.divider, height: 1),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _rawContent(String content) {
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

  Widget _emptyState(bool isTranslation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            isTranslation
                ? 'Translation not available for this surah'
                : 'Content not available',
            textAlign: TextAlign.center,
            style: AppStyles.body(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
