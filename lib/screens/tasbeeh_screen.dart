import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_container.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _total = 0;
  int _target = 33;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final _dhikrs = [
    (
      '\u0633\u064F\u0628\u0652\u062D\u064E\u0627\u0646\u064E \u0627\u0644\u0644\u0651\u0670\u0647\u0650',
      'SubhanAllah'
    ),
    (
      '\u0627\u064E\u0644\u0652\u062D\u064E\u0645\u0652\u062F\u064F \u0644\u0650\u0644\u0651\u0670\u0647\u0650',
      'Alhamdulillah'
    ),
    (
      '\u0627\u064E\u0644\u0644\u0651\u0670\u0647\u064F \u0627\u064E\u0643\u0652\u0628\u064E\u0631\u064F',
      'Allahu Akbar'
    ),
    (
      '\u0644\u0627 \u0627\u0650\u0644\u0670\u0647\u064E \u0627\u0650\u0644\u0651\u064E\u0627 \u0627\u0644\u0644\u0651\u0670\u0647\u064F',
      'La Ilaha IllAllah'
    ),
    (
      '\u0627\u064E\u0633\u0652\u062A\u064E\u063A\u0652\u0641\u0650\u0631\u064F \u0627\u0644\u0644\u0651\u0670\u0647\u064E',
      'Astaghfirullah'
    ),
    (
      '\u0644\u0627 \u062D\u064E\u0648\u0652\u0644\u064E \u0648\u064E\u0644\u0627 \u0642\u064F\u0648\u0651\u064E\u0629\u064E \u0627\u0650\u0644\u0651\u064E\u0627 \u0628\u0650\u0627\u0644\u0644\u0651\u0670\u0647\u0650',
      'La Hawla Wala Quwwata'
    ),
  ];
  int _selDhikr = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _tap() {
    HapticFeedback.lightImpact();
    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
    setState(() {
      _count++;
      _total++;
      if (_count >= _target) _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Tasbeeh Counter',
            style: AppStyles.heading(size: 20, color: AppColors.accent),
          ),
          actions: [
            IconButton(
              onPressed: () => setState(() {
                _count = 0;
                _total = 0;
              }),
              icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Dhikr Selector ──
                GlassContainer(
                  borderRadius: 18,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        _dhikrs[_selDhikr].$1,
                        textAlign: TextAlign.center,
                        style: AppStyles.arabic(
                          size: 28,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dhikrs[_selDhikr].$2,
                        textAlign: TextAlign.center,
                        style: AppStyles.caption(
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _dhikrs.length,
                          (i) => GestureDetector(
                            onTap: () => setState(() => _selDhikr = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: i == _selDhikr ? 18 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: i == _selDhikr
                                    ? AppColors.accent
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Counter Circle ──
                ScaleTransition(
                  scale: _pulseAnim,
                  child: GestureDetector(
                    onTap: _tap,
                    child: GlassContainer(
                      borderRadius: 110,
                      width: 200,
                      height: 200,
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_count',
                              style: AppStyles.heading(
                                size: 56,
                                weight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                            Text(
                              'of $_target',
                              style: AppStyles.caption(
                                size: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Progress Bar ──
                GlassContainer(
                  borderRadius: 10,
                  padding: const EdgeInsets.all(3),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _target > 0 ? _count / _target : 0,
                      backgroundColor: Colors.white.withOpacity(0.04),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.accent),
                      minHeight: 7,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Stats ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('Total', '$_total'),
                    _buildStat('Target', '$_target'),
                    _buildStat('Remaining', '${_target - _count}'),
                  ],
                ),

                const Spacer(),

                // ── Target selector ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Target: ',
                      style: AppStyles.caption(
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    ...[33, 34, 99, 100].map((t) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _target = t;
                              _count = 0;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: _target == t
                                    ? AppColors.accent.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _target == t
                                      ? AppColors.accent.withOpacity(0.4)
                                      : AppColors.glassBorder,
                                ),
                              ),
                              child: Text(
                                '$t',
                                style: AppStyles.body(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: _target == t
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),

                const SizedBox(height: 12),
                Text(
                  'Tap the circle to count',
                  textAlign: TextAlign.center,
                  style:
                      AppStyles.caption(size: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return GlassContainer(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Text(
            value,
            style: AppStyles.heading(
              size: 20,
              weight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppStyles.caption(size: 11),
          ),
        ],
      ),
    );
  }
}
