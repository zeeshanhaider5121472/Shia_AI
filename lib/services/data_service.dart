import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/data_models.dart';

class DataService extends ChangeNotifier {
  final Map<String, Map<String, List<SurahModel>>> _allData = {};
  final List<SurahModel> _allItems = [];
  final List<String> _hadithItems = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/db.json');
      final rawData = json.decode(jsonStr) as Map<String, dynamic>;

      for (final sectionEntry in rawData.entries) {
        if (sectionEntry.key == 'app') continue;

        final section = sectionEntry.key;
        final sectionData = sectionEntry.value as Map<String, dynamic>;
        _allData[section] = {};

        for (final catEntry in sectionData.entries) {
          final catData = catEntry.value;
          if (catData is! Map<String, dynamic>) continue;
          if (catData['items'] == null) continue;

          final itemsData = catData['items'];

          // ── List of strings (like hadith) ──
          if (itemsData is List) {
            if (catEntry.key == 'hadith') {
              for (final item in itemsData) {
                final s = item.toString().trim();
                if (s.isNotEmpty) _hadithItems.add(s);
              }
            }
            debugPrint('[DataService] Loaded $section.${catEntry.key}: '
                '${itemsData.length} string items');
            continue;
          }

          // ── Map of objects (normal categories) ──
          if (itemsData is! Map<String, dynamic>) continue;
          final items = itemsData;
          final models = <SurahModel>[];

          for (final e in items.entries) {
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

          debugPrint('[DataService] Loaded $section.${catEntry.key}: '
              '${models.length} items');
        }
      }

      debugPrint('[DataService] Total hadith: ${_hadithItems.length}');
    } catch (e, st) {
      debugPrint('[DataService] Error: $e\n$st');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Accessors ──

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

  List<String> get sections => _allData.keys.toList();

  // ── Daily Hadith: random from db.json hadith section ──

  String getDailyHadith() {
    if (_hadithItems.isNotEmpty) {
      return _hadithItems[Random().nextInt(_hadithItems.length)];
    }
    return '"Verily, with hardship comes ease." — Quran 94:6';
  }
}
