class VerseModel {
  final String number;
  final String arabic;
  final String? transliteration;
  final String? translation;

  VerseModel({
    required this.number,
    required this.arabic,
    this.transliteration,
    this.translation,
  });
}

class SurahModel {
  final String id;
  final String title;
  final String content;
  final String? englishTitle;
  final String? arabicName;
  final String? description;
  final List<VerseModel> verses;
  final String section;
  final String category;

  SurahModel({
    required this.id,
    required this.title,
    required this.content,
    this.englishTitle,
    this.arabicName,
    this.description,
    this.verses = const [],
    required this.section,
    required this.category,
  });

  factory SurahModel.fromJson(
    String id,
    Map<String, dynamic> json, {
    required String section,
    required String category,
  }) {
    final title = json['title'] as String? ?? '';
    final content = (json['content'] ?? json['data'] ?? '') as String;

    String? engTitle;
    String? arName;
    final titleParts = title.split(':');
    if (titleParts.length >= 2) {
      final nameStr = titleParts.sublist(1).join(':').trim();
      final words = nameStr.split(RegExp(r'\s+'));
      final eng = <String>[];
      final ar = <String>[];
      for (final w in words) {
        if (RegExp(r'[\u0600-\u06FF]').hasMatch(w)) {
          ar.add(w);
        } else {
          eng.add(w);
        }
      }
      engTitle = eng.join(' ');
      arName = ar.join(' ');
    }

    String? desc;
    List<VerseModel> verses = [];

    if (category == 'quran_verses') {
      verses = VerseParser.parseQuranVerses(content);
      desc = VerseParser.extractDescription(content);
    } else {
      final result = VerseParser.parsePrayers(content);
      desc = result.$1;
      verses = result.$2;
    }

    return SurahModel(
      id: id,
      title: title,
      content: content,
      englishTitle: engTitle,
      arabicName: arName,
      description: desc,
      verses: verses,
      section: section,
      category: category,
    );
  }
}

String toArabicNumeral(String number) {
  const map = {
    '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
    '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
  };
  return number.split('').map((d) => map[d] ?? d).join();
}

class VerseParser {
  // ─────────────────────────────────────────────
  //  PRAYERS FORMAT: single line with -- separators
  // ─────────────────────────────────────────────

  static (String?, List<VerseModel>) parsePrayers(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    String? desc;
    final verses = <VerseModel>[];

    int arabicIdx = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('--') &&
          RegExp(r'[\u0600-\u06FF]').hasMatch(lines[i])) {
        arabicIdx = i;
        break;
      }
    }

    if (arabicIdx > 0) {
      final descLines = <String>[];
      for (int i = 0; i < arabicIdx; i++) {
        final t = lines[i].trim();
        if (t.isEmpty) continue;
        if (t == t.toUpperCase() && t.length < 120 && t.length > 3) continue;
        descLines.add(t);
      }
      desc = descLines.join('\n').trim();
      if (desc.isEmpty) desc = null;
    }

    if (arabicIdx >= 0) {
      final parts = lines[arabicIdx].split('--');
      for (final p in parts) {
        final t = p.trim();
        if (t.isEmpty) continue;
        final numMatch = RegExp(r'[（(](\d+)[）)]').firstMatch(t);
        String num = '';
        String text = t;
        if (numMatch != null) {
          num = numMatch.group(1) ?? '';
          text = t.substring(0, numMatch.start).trim();
        }
        if (text.isNotEmpty) {
          verses.add(VerseModel(
            number: num,
            arabic: text,
            transliteration: generateTransliteration(text),
          ));
        }
      }
    }

    return (desc, verses);
  }

  // ─────────────────────────────────────────────
  //  QURAN VERSES FORMAT (quranzikr.quran_verses):
  //  Arabic line (1)\nEnglish line\nArabic line (2)\nEnglish line\n...
  // ─────────────────────────────────────────────

  static List<VerseModel> parseQuranVerses(String content) {
    if (content.trim().isEmpty) return [];

    final lines = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final verses = <VerseModel>[];
    String currentNumber = '';
    String? currentArabic;
    String? currentTranslation;

    void save() {
      if (currentArabic != null && currentArabic!.isNotEmpty) {
        verses.add(VerseModel(
          number: currentNumber,
          arabic: currentArabic!,
          transliteration: generateTransliteration(currentArabic!),
          translation: currentTranslation,
        ));
      }
      currentNumber = '';
      currentArabic = null;
      currentTranslation = null;
    }

    for (final line in lines) {
      final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(line);

      if (hasArabic) {
        // Save previous verse
        if (currentArabic != null) save();

        // Extract verse number and STRIP it from the text
        final numMatch = RegExp(r'[（(](\d+)[）)]').firstMatch(line);
        currentNumber = numMatch?.group(1) ?? '';
        if (numMatch != null) {
          // Remove "(1)" from the Arabic text
          currentArabic = line.substring(0, numMatch.start).trim();
        } else {
          currentArabic = line;
        }
        currentTranslation = null;
      } else {
        currentTranslation = line;
      }
    }

    save();
    return verses;
  }

  // ─────────────────────────────────────────────
  //  TRANSLITERATION GENERATOR
  //  Basic Arabic → Latin character mapping
  // ─────────────────────────────────────────────

  static String generateTransliteration(String arabic) {
    const charMap = <String, String>{
      // Consonants
      'ب': 'b', 'ت': 't', 'ث': 'th', 'ج': 'j',
      'ح': 'h', 'خ': 'kh', 'د': 'd', 'ذ': 'dh',
      'ر': 'r', 'ز': 'z', 'س': 's', 'ش': 'sh',
      'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z',
      'ع': "'", 'غ': 'gh', 'ف': 'f', 'ق': 'q',
      'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n',
      'ه': 'h', 'و': 'w', 'ي': 'y', 'ة': 'h',

      // Alef variants
      'ا': 'a', 'أ': 'a', 'إ': 'i', 'آ': 'aa',
      'ى': 'a', 'ٱ': '',

      // Hamza
      'ء': "'", 'ؤ': 'u', 'ئ': 'i',

      // Short vowels (diacritics)
      'َ': 'a', 'ِ': 'i', 'ُ': 'u',
      'ً': 'an', 'ٌ': 'un', 'ٍ': 'in',
      'ْ': '', 'ّ': '', 'ٰ': 'a',

      // Special
      'ﷲ': 'Allah',
    };

    final sb = StringBuffer();
    for (final char in arabic.split('')) {
      sb.write(charMap[char] ?? char);
    }

    var result = sb.toString();
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    return result.trim();
  }

  // ─────────────────────────────────────────────

  static String? extractDescription(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    final descLines = <String>[];
    for (final line in lines) {
      final t = line.trim();
      if (t.isEmpty) continue;
      if (RegExp(r'[\u0600-\u06FF]').hasMatch(t)) break;
      if (t == t.toUpperCase() && t.length < 120 && t.length > 3) continue;
      descLines.add(t);
    }
    return descLines.isNotEmpty ? descLines.join('\n').trim() : null;
  }
}
