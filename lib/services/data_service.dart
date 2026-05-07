import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/data_models.dart';

class SmartSearchResult {
  final String aiMessage;
  final List<HadithModel> hadiths;
  final List<SurahModel> items;

  SmartSearchResult({
    required this.aiMessage,
    this.hadiths = const [],
    this.items = const [],
  });

  bool get isEmpty => hadiths.isEmpty && items.isEmpty;
}

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

      if (rawData.containsKey('hadith')) {
        final hd = rawData['hadith'] as Map<String, dynamic>;
        if (hd['items'] is List) {
          _hadiths.addAll(VerseParser.parseHadith(hd['items'] as List));
        }
      }

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

      for (final sectionEntry in rawData.entries) {
        if (sectionEntry.key == 'app' ||
            sectionEntry.key == 'hadith' ||
            sectionEntry.key == 'events') {
          continue;
        }

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
          debugPrint('[DataService] $section.${catEntry.key}: ${models.length}');
        }
      }
      debugPrint('[DataService] hadiths: ${_hadiths.length}, events months: ${_eventsByMonth.length}');
    } catch (e, st) {
      debugPrint('[DataService] Error: $e\n$st');
    }
    _isLoading = false;
    notifyListeners();
  }

  List<SurahModel> getCategory(String section, String category) {
    return _allData[section]?[category] ?? [];
  }

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

  List<EventModel> getEventsForMonth(int month) {
    return _eventsByMonth[month] ?? [];
  }

  List<EventModel> getEventsForDay(int month, int day) {
    return (_eventsByMonth[month] ?? []).where((e) => e.day == day).toList();
  }

  String getDailyHadith() {
    if (_hadiths.isNotEmpty) {
      var text = _hadiths[Random().nextInt(_hadiths.length)].text;
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
    return 'Verily, with hardship comes ease. - Quran 94:6';
  }

  // ─────────────────────────────────────────────
  //  SMART SEARCH
  // ─────────────────────────────────────────────

  SmartSearchResult smartSearch(String query) {
    final q = query.toLowerCase().trim();

    // Greetings
    final greetRe = RegExp(r'^(hi|hello|salam|salaam|hey|assalam|as-salam|salamu)');
    if (greetRe.hasMatch(q)) {
      return SmartSearchResult(
        aiMessage: 'Wa Alaikum Assalam! Ask me about hadiths, duas, surahs, ziyarats, namaz, or any Islamic topic.',
      );
    }

    // Detect category
    String? cat;
    final hadithRe = RegExp(r'\b(hadith|hadees|hadis|saying|tradition|narrat|riwayat)\b');
    final duaRe = RegExp(r'\b(dua|duas|supplicat)\b');
    final surahRe = RegExp(r'\b(surah|surat|quran|verse|verses|chapter|ayat)\b');
    final ziyaratRe = RegExp(r'\b(ziyarat|ziyarah|visit|shrine)\b');
    final namazRe = RegExp(r'\b(namaz|salat|salah|rakat)\b');
    final amalRe = RegExp(r'\b(amal|amals|act|deed|practice)\b');
    final munajRe = RegExp(r'\b(munajaat|munajat|whisper)\b');

    if (hadithRe.hasMatch(q)) {
      cat = 'hadith';
    } else if (duaRe.hasMatch(q)) {
      cat = 'duas';
    } else if (surahRe.hasMatch(q)) {
      cat = 'surahs';
    } else if (ziyaratRe.hasMatch(q)) {
      cat = 'ziyarat';
    } else if (namazRe.hasMatch(q)) {
      cat = 'namaz';
    } else if (amalRe.hasMatch(q)) {
      cat = 'amal';
    } else if (munajRe.hasMatch(q)) {
      cat = 'munajaat';
    }

    // Extract topic keywords
    final stopWords = <String>{
      'show', 'me', 'related', 'to', 'about', 'find', 'search', 'for',
      'give', 'get', 'any', 'some', 'all', 'the', 'a', 'an', 'is',
      'are', 'on', 'in', 'of', 'and', 'or', 'with', 'from', 'that',
      'have', 'hadith', 'hadiths', 'hadees', 'dua', 'duas', 'surah',
      'surahs', 'quran', 'verse', 'verses', 'ziyarat', 'namaz', 'amal',
      'munajaat', 'please', 'can', 'you', 'tell', 'want', 'need',
      'like', 'looking', 'help', 'find', 'what', 'which', 'where',
      'when', 'how', 'who', 'about', 'regarding', 'concerning',
    };

    final splitRe = RegExp(r'[^a-zA-Z\u0600-\u06FF]+');
    final words = q.split(splitRe).where((w) {
      return w.length > 2 && !stopWords.contains(w.toLowerCase());
    }).toList();

    final topic = words.join(' ');

    // Search
    List<HadithModel> foundHadiths = [];
    List<SurahModel> foundItems = [];

    if (cat == 'hadith') {
      foundHadiths = _searchHadiths(words);
    } else if (cat != null) {
      foundItems = _searchInCats(_catKeys(cat), words);
    } else {
      foundHadiths = _searchHadiths(words);
      foundItems = _searchAllItems(words);
    }

    // Build message
    String msg;
    if (foundHadiths.isEmpty && foundItems.isEmpty) {
      msg = 'I couldn\'t find anything matching '
          '"${topic.isNotEmpty ? topic : query}". '
          'Try different keywords.';
    } else {
      final parts = <String>[];
      if (foundHadiths.isNotEmpty) {
        final s = foundHadiths.length > 1 ? 's' : '';
        parts.add('${foundHadiths.length} hadith$s');
      }
      if (foundItems.isNotEmpty) {
        final label = cat ?? 'item';
        final s = foundItems.length > 1 ? 's' : '';
        parts.add('${foundItems.length} $label$s');
      }
      msg = 'Here\'s what I found for '
          '"${topic.isNotEmpty ? topic : query}" - ${parts.join(' and ')}:';
    }

    return SmartSearchResult(
      aiMessage: msg,
      hadiths: foundHadiths.take(8).toList(),
      items: foundItems.take(8).toList(),
    );
  }

  List<String> _catKeys(String cat) {
    switch (cat) {
      case 'duas':
        return ['duas', 'taweez'];
      case 'surahs':
        return ['quran_chapters', 'quran verses'];
      case 'ziyarat':
        return ['ziyarat'];
      case 'namaz':
        return ['namaz'];
      case 'amal':
        return ['amal', 'special_prayers'];
      case 'munajaat':
        return ['munajaat', 'supplications'];
      default:
        return [];
    }
  }

  List<HadithModel> _searchHadiths(List<String> words) {
    if (words.isEmpty) return [];
    final results = <HadithModel>[];
    for (final h in _hadiths) {
      final t = '${h.text} ${h.reference}'.toLowerCase();
      for (final w in words) {
        if (t.contains(w)) {
          results.add(h);
          break;
        }
      }
    }
    return results;
  }

  List<SurahModel> _searchInCats(List<String> cats, List<String> words) {
    final pool = getMergedItems(cats);
    if (words.isEmpty) return pool.take(10).toList();
    return _ranked(pool, words);
  }

  List<SurahModel> _searchAllItems(List<String> words) {
    if (words.isEmpty) return [];
    return _ranked(_allItems, words);
  }

  List<SurahModel> _ranked(List<SurahModel> pool, List<String> words) {
    final scored = <MapEntry<SurahModel, double>>[];
    for (final item in pool) {
      final meta = '${item.title} ${item.englishTitle ?? ''} '
              '${item.arabicName ?? ''} ${item.description ?? ''}'
          .toLowerCase();
      double score = 0;
      for (final w in words) {
        if (meta.contains(w)) score += 3;
        if (item.content.toLowerCase().contains(w)) score += 1;
      }
      if (score > 0) {
        scored.add(MapEntry(item, score));
      }
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((s) => s.key).toList();
  }
}
