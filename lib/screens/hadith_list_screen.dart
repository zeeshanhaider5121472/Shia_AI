import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_background.dart';
import 'hadith_detail_screen.dart';

class HadithListScreen extends StatefulWidget {
  const HadithListScreen({super.key});

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final hadiths = ds.hadiths;

    final filtered = _query.isEmpty
        ? hadiths
        : hadiths
            .where((h) =>
                h.text.toLowerCase().contains(_query.toLowerCase()) ||
                h.reference.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Hadiths',
              style:
                  AppStyles.heading(size: 20, color: AppColors.accent)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
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
                          hintText: 'Search hadiths...',
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
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.format_quote_rounded,
                              size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 14),
                          Text(
                            hadiths.isEmpty
                                ? 'No hadiths in database'
                                : 'No hadiths match your search',
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
                        final h = filtered[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassContainer(
                            borderRadius: 16,
                            padding: const EdgeInsets.all(18),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        HadithDetailScreen(hadith: h))),
                            child: Column(
                              children: [
                                Text(
                                  '"${h.text}"',
                                  textAlign: TextAlign.center,
                                  style: AppStyles.body(
                                    size: 14,
                                    color: AppColors.textPrimary,
                                    height: 1.8,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (h.reference.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '[${h.reference}]',
                                    textAlign: TextAlign.center,
                                    style: AppStyles.caption(
                                      size: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
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
}
