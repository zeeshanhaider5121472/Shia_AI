import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/data_models.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_container.dart';
import 'detail_screen.dart';
import 'surah_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late HijriDate _todayHijri;
  late int _viewYear;
  late int _viewMonth;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _todayHijri = HijriDate.fromGregorian(DateTime.now());
    _viewYear = _todayHijri.year;
    _viewMonth = _todayHijri.month;
    _selectedDay = _todayHijri.day;
  }

  void _prevMonth() {
    setState(() {
      _viewMonth--;
      if (_viewMonth < 1) {
        _viewMonth = 12;
        _viewYear--;
      }
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _viewMonth++;
      if (_viewMonth > 12) {
        _viewMonth = 1;
        _viewYear++;
      }
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final todayGreg = DateTime.now();
    final monthEvents = ds.getEventsForMonth(_viewMonth);
    final selectedEvents = _selectedDay != null
        ? ds.getEventsForDay(_viewMonth, _selectedDay!)
        : <EventModel>[];

    final daysWithEvents = <int, int>{};
    for (final e in monthEvents) {
      daysWithEvents[e.day] = e.color;
    }

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Calendar & Times',
              style: AppStyles.heading(size: 20, color: AppColors.accent)),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Today Card ──
              GlassContainer(
                borderRadius: 22,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      '${_todayHijri.day} ${_todayHijri.monthName} '
                      '${_todayHijri.year} AH',
                      textAlign: TextAlign.center,
                      style: AppStyles.heading(
                          size: 20,
                          weight: FontWeight.w700,
                          color: AppColors.accent),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(todayGreg),
                      textAlign: TextAlign.center,
                      style: AppStyles.body(
                          size: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Today's Events ──
              ..._buildTodayEvents(ds),

              const SizedBox(height: 16),

              // ── Month Header ──
              GlassContainer(
                borderRadius: 18,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _prevMonth,
                          icon: Icon(Icons.chevron_left_rounded,
                              color: AppColors.accent),
                        ),
                        Column(
                          children: [
                            Text(
                              '${HijriDate.monthNames[_viewMonth - 1]} '
                              '$_viewYear',
                              style: AppStyles.heading(
                                  size: 16,
                                  weight: FontWeight.w700,
                                  color: AppColors.accent),
                            ),
                            Text(
                              'AH',
                              style: AppStyles.caption(size: 11),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: Icon(Icons.chevron_right_rounded,
                              color: AppColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Day headers ──
                    Row(
                      children: ['Sa', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr']
                          .map((d) => Expanded(
                                child: Text(d,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.caption(
                                        size: 11, color: AppColors.textMuted)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),

                    // ── Day grid ──
                    _buildDayGrid(daysWithEvents),
                  ],
                ),
              ),

              // ── Selected Day Events ──
              if (_selectedDay != null && selectedEvents.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...selectedEvents.map((e) => _buildEventCard(e, ds)),
              ],

              if (_selectedDay != null && selectedEvents.isEmpty) ...[
                const SizedBox(height: 16),
                GlassContainer(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No events on ${_selectedDay} '
                    '${HijriDate.monthNames[_viewMonth - 1]}',
                    textAlign: TextAlign.center,
                    style: AppStyles.body(color: AppColors.textMuted),
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

  List<Widget> _buildTodayEvents(DataService ds) {
    final events = ds.getEventsForDay(_todayHijri.month, _todayHijri.day);
    if (events.isEmpty) return [];

    return [
      GlassContainer(
        borderRadius: 18,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_rounded, color: AppColors.accent, size: 16),
                const SizedBox(width: 8),
                Text("Today's Events",
                    style:
                        AppStyles.heading(size: 14, color: AppColors.accent)),
              ],
            ),
            const SizedBox(height: 12),
            ...events.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: e.color == 1
                              ? const Color(0xFF34D399)
                              : const Color(0xFFF87171),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(e.header,
                          textAlign: TextAlign.center,
                          style: AppStyles.body(
                              size: 13,
                              weight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(e.content,
                          textAlign: TextAlign.center,
                          style: AppStyles.body(
                              size: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.7)),
                      if (e.linkText != null && e.linkText!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: GestureDetector(
                            onTap: () => _openLink(e),
                            child: Text(
                              e.linkText!,
                              textAlign: TextAlign.center,
                              style: AppStyles.body(
                                size: 12,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    ];
  }

  Widget _buildDayGrid(Map<int, int> daysWithEvents) {
    // First day of Hijri month — approximate day-of-week
    final firstGreg = HijriDate(_viewYear, _viewMonth, 1).toGregorian();
    final firstWeekday = firstGreg.weekday % 7; // 0=Sat
    const totalCells = 42; // 6 rows * 7 cols

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: totalCells,
      itemBuilder: (ctx, i) {
        final dayNum = i - firstWeekday + 1;
        if (dayNum < 1 || dayNum > 30) {
          return const SizedBox.shrink();
        }

        final isToday = dayNum == _todayHijri.day &&
            _viewMonth == _todayHijri.month &&
            _viewYear == _todayHijri.year;
        final isSelected = dayNum == _selectedDay;
        final eventColor = daysWithEvents[dayNum];

        return GestureDetector(
          onTap: () => setState(() => _selectedDay = dayNum),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withOpacity(0.2)
                  : isToday
                      ? AppColors.accent.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isToday
                  ? Border.all(color: AppColors.accent.withOpacity(0.4))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: AppStyles.body(
                    size: 13,
                    weight: isToday || isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isToday || isSelected
                        ? AppColors.accent
                        : AppColors.textPrimary,
                  ),
                ),
                if (eventColor != null)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: eventColor == 1
                          ? const Color(0xFF34D399)
                          : const Color(0xFFF87171),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventCard(EventModel e, DataService ds) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: e.color == 1
                        ? const Color(0xFF34D399)
                        : const Color(0xFFF87171),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(e.header,
                      textAlign: TextAlign.center,
                      style: AppStyles.heading(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(e.content,
                textAlign: TextAlign.center,
                style: AppStyles.body(
                    size: 13, color: AppColors.textSecondary, height: 1.8)),
            if (e.linkText != null && e.linkText!.isNotEmpty) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _openLink(e),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        e.linkType == 3
                            ? Icons.link_rounded
                            : Icons.open_in_new_rounded,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(e.linkText!,
                            style: AppStyles.body(
                                size: 12,
                                weight: FontWeight.w600,
                                color: AppColors.accent)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openLink(EventModel e) async {
    if (e.link == null || e.link!.isEmpty) return;

    if (e.linkType == 3) {
      // Website link
      final uri = Uri.parse(e.link!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (e.linkType == 2) {
      // Internal DB link — find item by ID
      final ds = context.read<DataService>();
      final item = ds.findItemById(e.link!);
      if (item != null) {
        if (item.category == 'quran_chapters') {
          final qItem = ds.getItem('quranzikr', 'quran verses', item.id);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      SurahDetailScreen(prayersItem: item, quranItem: qItem)));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => DetailScreen(item: item)));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Item ${e.link} not found', style: AppStyles.body(size: 13)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface,
        ));
      }
    }
  }
}
