import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/data_models.dart';

class DataService extends ChangeNotifier {
  final Map<String, Map<String, List<SurahModel>>> _allData = {};
  final List<SurahModel> _allItems = [];
  final List<HadithModel> _hadiths = [];
  final Map<int, List<EventModel>> _eventsByMonth = {};

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  List<HadithModel> get hadiths => _hadiths;

  Future<void> loadData() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/db.json');
      final rawData = json.decode(jsonStr) as Map<String, dynamic>;

      // ── Parse hadith ──
      if (rawData.containsKey('hadith')) {
        final hd = rawData['hadith'] as Map<String, dynamic>;
        if (hd['items'] is List) {
          _hadiths.addAll(VerseParser.parseHadith(hd['items'] as List));
        }
      }

      // ── Parse events ──
      if (rawData.containsKey('events')) {
        final ev = rawData['events'] as Map<String, dynamic>;
        if (ev['months'] is Map) {
          final months = ev['months'] as Map<String, dynamic>;
          for (final mEntry in months.entries) {
            final mNum = int.tryParse(mEntry.key) ?? 0;
            final mData = mEntry.value as Map<String, dynamic>;
            final events = mData['events'] as List? ?? [];
            _eventsByMonth[mNum] = events.map((e) {
              final em = e as Map<String, dynamic>;
              return EventModel(
                day: em['day'] as int? ?? 0,
                header: (em['header'] ?? '').toString(),
                content: (em['content'] ?? '').toString(),
                link: em['link']?.toString(),
                linkText: em['linkText']?.toString(),
                linkType: em['linkType'] as int? ?? 0,
                color: em['color'] as int? ?? 1,
                month: mNum,
              );
            }).toList();
          }
        }
      }

      // ── Parse all sections ──
      for (final sectionEntry in rawData.entries) {
        if (sectionEntry.key == 'app' ||
            sectionEntry.key == 'hadith' ||
            sectionEntry.key == 'events') continue;

        final section = sectionEntry.key;
        final sectionData = sectionEntry.value;
        if (sectionData is! Map<String, dynamic>) continue;
        _allData[section] = {};

        for (final catEntry in sectionData.entries) {
          final catData = catEntry.value;
          if (catData is! Map<String, dynamic>) continue;
          if (catData['items'] == null) continue;
          final itemsData = catData['items'];
          if (itemsData is! Map<String, dynamic>) continue;

          final models = <SurahModel>[];
          for (final e in itemsData.entries) {
            if (e.value is! Map<String, dynamic>) continue;
            models.add(SurahModel.fromJson(
              e.key,
              e.value as Map<String, dynamic>,
              section: section,
              category: catEntry.key,
            ));
          }

          _allData[section]![catEntry.key] = models;
          _allItems.addAll(models);
          debugPrint(
              '[DataService] $section.${catEntry.key}: ${models.length}');
        }
      }
      debugPrint('[DataService] hadiths: ${_hadiths.length}, '
          'events months: ${_eventsByMonth.length}');
    } catch (e, st) {
      debugPrint('[DataService] Error: $e\n$st');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Accessors ──

  List<SurahModel> getCategory(String section, String category) =>
      _allData[section]?[category] ?? [];

  SurahModel? getItem(String section, String category, String id) {
    try {
      return _allData[section]?[category]?.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  SurahModel? findItemById(String id) {
    for (final section in _allData.values) {
      for (final cat in section.values) {
        for (final item in cat) {
          if (item.id == id) return item;
        }
      }
    }
    return null;
  }

  List<SurahModel> getMergedItems(List<String> categoryKeys) {
    final seen = <String>{};
    final items = <SurahModel>[];
    for (final sectionEntry in _allData.entries) {
      for (final catKey in categoryKeys) {
        if (sectionEntry.value.containsKey(catKey)) {
          for (final item in sectionEntry.value[catKey]!) {
            final uid = '${item.section}:${item.id}';
            if (!seen.contains(uid)) {
              seen.add(uid);
              items.add(item);
            }
          }
        }
      }
    }
    return items;
  }

  List<SurahModel> search(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _allItems.where((item) {
      return item.title.toLowerCase().contains(q) ||
          (item.englishTitle?.toLowerCase().contains(q) ?? false) ||
          (item.arabicName?.contains(query) ?? false) ||
          (item.description?.toLowerCase().contains(q) ?? false) ||
          item.content.toLowerCase().contains(q);
    }).toList();
  }

  // ── Events ──

  List<EventModel> getEventsForMonth(int month) => _eventsByMonth[month] ?? [];

  List<EventModel> getEventsForDay(int month, int day) {
    return (_eventsByMonth[month] ?? []).where((e) => e.day == day).toList();
  }

  // ── Daily Hadith ──

  String getDailyHadith() {
    if (_hadiths.isNotEmpty) {
      var text = _hadiths[Random().nextInt(_hadiths.length)].text;
      // Strip any remaining quote marks
      while (text.isNotEmpty &&
          (text.codeUnitAt(0) == 0x22 || text.codeUnitAt(0) == 0x27)) {
        text = text.substring(1);
      }
      while (text.isNotEmpty &&
          (text.codeUnitAt(text.length - 1) == 0x22 ||
              text.codeUnitAt(text.length - 1) == 0x27)) {
        text = text.substring(0, text.length - 1);
      }
      return text.trim();
    }
    return 'Verily, with hardship comes ease. — Quran 94:6';
  }
}
