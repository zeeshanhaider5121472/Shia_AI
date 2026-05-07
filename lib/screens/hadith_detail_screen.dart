import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_background.dart';

class HadithDetailScreen extends StatelessWidget {
  final HadithModel hadith;
  const HadithDetailScreen({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Hadith',
              style:
                  AppStyles.heading(size: 18, color: AppColors.accent)),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassContainer(
                borderRadius: 22,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  children: [
                    Icon(Icons.format_quote_rounded,
                        color: AppColors.accent, size: 36),
                    const SizedBox(height: 20),
                    Text(
                      '"${hadith.text}"',
                      textAlign: TextAlign.center,
                      style: AppStyles.body(
                        size: 18,
                        weight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              if (hadith.reference.isNotEmpty) ...[
                const SizedBox(height: 16),
                GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_rounded,
                          color: AppColors.accent, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          hadith.reference,
                          textAlign: TextAlign.center,
                          style: AppStyles.caption(
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
