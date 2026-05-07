import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_background.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  static const _englishFonts = [
    'Plus Jakarta Sans',
    'Lora',
    'Nunito',
    'Poppins',
    'Open Sans',
    'DM Sans',
    'Source Sans 3',
  ];

  static const _arabicFonts = [
    'Amiri',
    'Scheherazade New',
    'Noto Naskh Arabic',
    'Lateef',
    'Noto Kufi Arabic',
    'Aref Ruqaa',
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Preferences',
              style:
                  AppStyles.heading(size: 20, color: AppColors.accent)),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Appearance ──
              GlassContainer(
                borderRadius: 18,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _sectionTitle(Icons.palette_rounded, 'Appearance'),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              settings.isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text('Dark Mode',
                                style: AppStyles.body(
                                    size: 14,
                                    color: AppColors.textPrimary)),
                          ],
                        ),
                        Switch(
                          value: settings.isDark,
                          onChanged: (v) => settings.toggleTheme(v),
                          activeColor: AppColors.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Font Size',
                        style: AppStyles.body(
                            size: 14, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('A',
                            style: AppStyles.body(
                                size: 12, color: AppColors.textMuted)),
                        Expanded(
                          child: Slider(
                            value: settings.fontScale,
                            min: 0.8,
                            max: 1.5,
                            divisions: 14,
                            activeColor: AppColors.accent,
                            inactiveColor: AppColors.divider,
                            label:
                                '${settings.fontScale.toStringAsFixed(1)}x',
                            onChanged: (v) => settings.setFontScale(v),
                          ),
                        ),
                        Text('A',
                            style: AppStyles.body(
                                size: 18, color: AppColors.textMuted)),
                      ],
                    ),
                    Center(
                      child: Text(
                        '${settings.fontScale.toStringAsFixed(1)}x',
                        style: AppStyles.caption(
                            size: 12, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── English Font ──
              _fontSection(
                icon: Icons.font_download_rounded,
                title: 'English Font',
                fonts: _englishFonts,
                selected: settings.fontFamily,
                onSelect: (f) => settings.setFontFamily(f),
                showPreview: true,
              ),

              const SizedBox(height: 16),

              // ── Arabic Font ──
              _fontSection(
                icon: Icons.text_fields_rounded,
                title: 'Arabic Font',
                fonts: _arabicFonts,
                selected: settings.arabicFontFamily,
                onSelect: (f) => settings.setArabicFontFamily(f),
                showPreview: false,
                isArabic: true,
              ),

              const SizedBox(height: 16),

              // ── Preview ──
              GlassContainer(
                borderRadius: 18,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Preview',
                        textAlign: TextAlign.center,
                        style: AppStyles.heading(
                            size: 14, color: AppColors.accent)),
                    const SizedBox(height: 12),
                    Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        textAlign: TextAlign.center,
                        style: AppStyles.arabic(
                            size: 22, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(
                        'In the name of Allah, the Most Gracious, the Most Merciful',
                        textAlign: TextAlign.center,
                        style: AppStyles.body(
                            size: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: AppStyles.heading(size: 15, color: AppColors.accent)),
      ],
    );
  }

  Widget _fontSection({
    required IconData icon,
    required String title,
    required List<String> fonts,
    required String selected,
    required ValueChanged<String> onSelect,
    bool showPreview = false,
    bool isArabic = false,
  }) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _sectionTitle(icon, title),
          const SizedBox(height: 16),
          ...fonts.map((font) {
            final isSelected = selected == font;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: () => onSelect(font),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent.withOpacity(0.3)
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: isArabic
                            ? Text('بِسْمِ اللَّهِ',
                                style: GoogleFonts.getFont(font,
                                    fontSize: 18,
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppColors.textPrimary))
                            : Text(font,
                                style: GoogleFonts.getFont(font,
                                    fontSize: 15,
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppColors.textPrimary)),
                      ),
                      if (isSelected)
                        Icon(Icons.check_rounded,
                            color: AppColors.accent, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
