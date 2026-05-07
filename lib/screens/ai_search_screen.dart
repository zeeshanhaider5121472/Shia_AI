import 'dart:math';
import '../services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_background.dart';
import 'surah_detail_screen.dart';
import 'detail_screen.dart';
import 'hadith_detail_screen.dart';

class AiSearchScreen extends StatefulWidget {
  final String initialQuery;
  const AiSearchScreen({super.key, required this.initialQuery});

  @override
  State<AiSearchScreen> createState() => _AiSearchScreenState();
}

class _AiSearchScreenState extends State<AiSearchScreen> {
  final _messages = <_Msg>[];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _process(widget.initialQuery);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _process(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _messages.add(_Msg.user(query));
      _typing = true;
    });
    _scroll();

    Future.delayed(const Duration(milliseconds: 700), () {
      final result = context.read<DataService>().smartSearch(query);
      setState(() {
        _typing = false;
        _messages.add(_Msg.ai(result));
      });
      _scroll();
    });
  }

  void _scroll() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsService>();

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text('Shia AI',
                  style: AppStyles.heading(
                      size: 18, color: AppColors.accent)),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _messages.length + (_typing ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == _messages.length) return _typingBubble();
                  final m = _messages[i];
                  return m.isUser ? _userBubble(m) : _aiBubble(m);
                },
              ),
            ),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  // ── User bubble ──
  Widget _userBubble(_Msg m) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(left: 50, bottom: 14),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(m.text,
            style: AppStyles.body(
                size: 14,
                weight: FontWeight.w500,
                color: Colors.white)),
      ),
    );
  }

  // ── AI bubble ──
  Widget _aiBubble(_Msg m) {
    final r = m.result!;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.88),
        margin: const EdgeInsets.only(right: 16, bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.glass,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.auto_awesome_rounded,
                        color: AppColors.accent, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(r.aiMessage,
                        style: AppStyles.body(
                            size: 13.5,
                            color: AppColors.textPrimary,
                            height: 1.65)),
                  ),
                ],
              ),
            ),

            if (!r.isEmpty) ...[
              const SizedBox(height: 10),
              // Hadith results
              ...r.hadiths.map((h) => _hadithCard(h)),
              // Item results
              ...r.items.map((item) => _itemCard(item)),
            ],
          ],
        ),
      ),
    );
  }

  // ── Hadith result card ──
  Widget _hadithCard(HadithModel h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        borderRadius: 14,
        padding: const EdgeInsets.all(14),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => HadithDetailScreen(hadith: h))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote_rounded,
                    color: AppColors.accent, size: 14),
                const SizedBox(width: 6),
                Text('Hadith',
                    style: AppStyles.caption(
                        size: 11, color: AppColors.accent)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 8),
            Text(h.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.body(
                    size: 13,
                    color: AppColors.textPrimary,
                    height: 1.7)),
            if (h.reference.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(h.reference,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.caption(
                      size: 11, color: AppColors.textMuted)),
            ],
          ],
        ),
      ),
    );
  }

  // ── Item result card ──
  Widget _itemCard(SurahModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        borderRadius: 14,
        padding: const EdgeInsets.all(14),
        onTap: () => _openItem(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(item.category,
                      style: AppStyles.caption(
                          size: 10, color: AppColors.accent)),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.textMuted),
              ],
            ),
            if (item.arabicName != null &&
                item.arabicName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(item.arabicName!,
                  textDirection: TextDirection.rtl,
                  style: AppStyles.arabic(
                      size: 18, color: AppColors.accent)),
            ],
            const SizedBox(height: 4),
            Text(item.englishTitle ?? item.title,
                style: AppStyles.body(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            if (item.description != null &&
                item.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(item.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.caption(
                      size: 11.5, color: AppColors.textMuted)),
            ],
          ],
        ),
      ),
    );
  }

  // ── Typing indicator ──
  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 60, bottom: 14),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded,
                color: AppColors.accent, size: 16),
            const SizedBox(width: 12),
            _TypingDots(),
          ],
        ),
      ),
    );
  }

  // ── Input bar ──
  Widget _inputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
      child: GlassContainer(
        borderRadius: 28,
        padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                style: AppStyles.body(size: 14),
                decoration: InputDecoration(
                  hintText: 'Ask about hadiths, duas, surahs...',
                  hintStyle:
                      AppStyles.body(color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (q) {
                  if (q.trim().isNotEmpty) {
                    _process(q);
                    _inputCtrl.clear();
                  }
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                final q = _inputCtrl.text;
                if (q.trim().isNotEmpty) {
                  _process(q);
                  _inputCtrl.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openItem(SurahModel item) {
    final ds = context.read<DataService>();
    if (item.category == 'quran_chapters') {
      final qItem =
          ds.getItem('quranzikr', 'quran verses', item.id);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SurahDetailScreen(
                  prayersItem: item, quranItem: qItem)));
    } else if (item.category == 'quran verses') {
      final pItem =
          ds.getItem('prayers', 'quran_chapters', item.id);
      if (pItem != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SurahDetailScreen(
                    prayersItem: pItem, quranItem: item)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailScreen(item: item)));
      }
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailScreen(item: item)));
    }
  }
}

// ═══════════════════════════════════════════
//  Message model
// ═══════════════════════════════════════════

class _Msg {
  final bool isUser;
  final String text;
  final SmartSearchResult? result;

  _Msg.user(this.text) : isUser = true, result = null;
  _Msg.ai(this.result) : isUser = false, text = '';
}

// ═══════════════════════════════════════════
//  Animated typing dots
// ═══════════════════════════════════════════

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_c.value - i * 0.2) % 1.0);
            final o = phase < 0.5
                ? (phase * 2).clamp(0.0, 1.0)
                : (2.0 - phase * 2).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.25 + o * 0.75),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
