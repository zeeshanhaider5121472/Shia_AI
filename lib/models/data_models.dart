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

class HadithModel {
  final String text;
  final String reference;

  HadithModel({required this.text, required this.reference});
}

class EventModel {
  final int day;
  final String header;
  final String content;
  final String? link;
  final String? linkText;
  final int linkType;
  final int color;
  final int month;

  EventModel({
    required this.day,
    required this.header,
    required this.content,
    this.link,
    this.linkText,
    required this.linkType,
    required this.color,
    required this.month,
  });
}

class HijriDate {
  final int year;
  final int month;
  final int day;

  HijriDate(this.year, this.month, this.day);

  static const monthNames = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Ula',
    'Jumada al-Thani',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhul Qi'dah",
    'Dhul Hijjah',
  ];

  String get monthName => monthNames[month - 1];

  static HijriDate fromGregorian(DateTime date) {
    final jd = _toJulianDay(date.year, date.month, date.day);
    return _fromJulianDay(jd);
  }

  static int _toJulianDay(int y, int m, int d) {
    final a = ((14 - m) / 12).floor();
    final yy = y + 4800 - a;
    final mm = m + 12 * a - 3;
    return d +
        ((153 * mm + 2) / 5).floor() +
        365 * yy +
        (yy / 4).floor() -
        (yy / 100).floor() +
        (yy / 400).floor() -
        32045;
  }

  static HijriDate _fromJulianDay(int jd) {
    var l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    final j = ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
        (l / 5670).floor() * ((43 * l) / 15238).floor();
    l = l -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final m = ((24 * l) / 709).floor();
    final d = l - ((709 * m) / 24).floor();
    final y = 30 * n + j - 30;
    return HijriDate(y, m, d);
  }

  DateTime toGregorian() {
    final jd = ((11 * year + 3) / 30).floor() +
        354 * year +
        30 * month -
        ((month - 1) / 2).floor() +
        day +
        1948440 -
        385;
    final l = jd + 68569;
    final n = ((4 * l) / 146097).floor();
    final l2 = l - ((146097 * n + 3) / 4).floor();
    final i = ((4000 * (l2 + 1)) / 1461001).floor();
    final l3 = l2 - ((1461 * i) / 4).floor() + 31;
    final j = ((80 * l3) / 2447).floor();
    final dd = l3 - ((2447 * j) / 80).floor();
    final l4 = (j / 11).floor();
    final mm = j + 2 - 12 * l4;
    final yy = 100 * (n - 49) + i + l4;
    return DateTime(yy, mm, dd);
  }
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

    if (category == 'quran verses') {
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
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };
  return number.split('').map((d) => map[d] ?? d).join();
}

class VerseParser {
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
        if (currentArabic != null) save();
        final numMatch = RegExp(r'[（(](\d+)[）)]').firstMatch(line);
        currentNumber = numMatch?.group(1) ?? '';
        if (numMatch != null) {
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

  static List<HadithModel> parseHadith(List<dynamic> items) {
    final hadiths = <HadithModel>[];

    for (int i = 0; i < items.length; i++) {
      final s = items[i].toString().trim();
      if (s.isEmpty) continue;

      if (s.startsWith('[')) {
        if (hadiths.isNotEmpty) {
          final last = hadiths.removeLast();
          hadiths.add(HadithModel(
            text: last.text,
            reference: _clean(s, isRef: true),
          ));
        }
      } else {
        hadiths.add(HadithModel(text: _clean(s), reference: ''));
      }
    }

    return hadiths;
  }

  static String _clean(String s, {bool isRef = false}) {
    var r = s.trim();
    if (r.startsWith('\uFEFF')) r = r.substring(1);
    while (r.isNotEmpty &&
        (r.codeUnitAt(0) == 0x22 ||
            r.codeUnitAt(0) == 0x5C ||
            r.codeUnitAt(0) == 0x20 ||
            r.codeUnitAt(0) == 0xFEFF ||
            (isRef && r.codeUnitAt(0) == 0x5B))) {
      r = r.substring(1);
    }
    while (r.isNotEmpty &&
        (r.codeUnitAt(r.length - 1) == 0x22 ||
            r.codeUnitAt(r.length - 1) == 0x5C ||
            r.codeUnitAt(r.length - 1) == 0x20 ||
            r.codeUnitAt(r.length - 1) == 0x2C ||
            (isRef && r.codeUnitAt(r.length - 1) == 0x5D))) {
      r = r.substring(0, r.length - 1);
    }
    return r.trim();
  }

  static String generateTransliteration(String arabic) {
    const charMap = <String, String>{
      'ب': 'b', 'ت': 't', 'ث': 'th', 'ج': 'j',
      'ح': 'h', 'خ': 'kh', 'د': 'd', 'ذ': 'dh',
      'ر': 'r', 'ز': 'z', 'س': 's', 'ش': 'sh',
      'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z',
      'ع': "'", 'غ': 'gh', 'ف': 'f', 'ق': 'q',
      'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n',
      'ه': 'h', 'و': 'w', 'ي': 'y', 'ة': 'h',
      'ا': 'a', 'أ': 'a', 'إ': 'i', 'آ': 'aa',
      'ى': 'a', 'ٱ': '', 'ء': "'", 'ؤ': 'u', 'ئ': 'i',
      'َ': 'a', 'ِ': 'i', 'ُ': 'u',
      'ً': 'an', 'ٌ': 'un', 'ٍ': 'in',
      'ْ': '', 'ّ': '', 'ٰ': 'a', 'ﷲ': 'Allah',
    };
    final sb = StringBuffer();
    for (final char in arabic.split('')) {
      sb.write(charMap[char] ?? char);
    }
    return sb.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

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
