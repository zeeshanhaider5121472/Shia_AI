create a readme.md file which contains Markdown table of the db.json
and a structure to tell how all the functinalities are connected and working

markdown
markdown
# Shia AI — Flutter App

> **Islamic prayers, ziyarat, duas, quran, hadith and more**
> Version 2.0.0 · Package: `com.shia_ai.app`

A beautifully designed Flutter application with **Glassmorphism UI** that provides access to Quranic chapters, duas, supplications, ziyarats, and more — all sourced from a local `db.json` database.

---

## Table of Contents

- [Shia AI — Flutter App](#shia-ai--flutter-app)
  - [Table of Contents](#table-of-contents)
  - [Architecture Overview](#architecture-overview)
  - [Folder Structure](#folder-structure)
  - [Data Flow Diagram](#data-flow-diagram)
  - [Screen \& Feature Map](#screen--feature-map)
    - [Button → Screen Routing](#button--screen-routing)
  - [Database Contents](#database-contents)
    - [`db.json` Top-Level Structure](#dbjson-top-level-structure)
- [1. Clone the repository](#1-clone-the-repository)
- [2. Place your db.json in assets/](#2-place-your-dbjson-in-assets)
- [3. Install dependencies](#3-install-dependencies)
- [4. Run the app](#4-run-the-app)

---
db.json
├── app
├── prayers
│   ├── quran_chapters.items  ←── Surah list (Arabic only)
│   ├── duas.items            ──┐
│   ├── supplications.items   ──┤
│   ├── ziyarats.items        ──┤── Merged across sections
│   ├── munajaat.items        ──┤   for grid buttons
│   └── ...                   ──┘
│
└── quranzikr
    ├── quran_verses.items    ←── Surah list (with translation)
    ├── duas.items            ──┐
    ├── supplications.items   ──┤── Merged with prayers
    ├── ziyarats.items        ──┤   counterparts
    └── ...                   ──┘


Click "Surahs" button
  └─ CategoryListScreen (from prayers.quran_chapters only)
       └─ Click surah
            └─ SurahDetailScreen
                 ├─ Tab 1: Arabic (prayers.quran_chapters[id])
                 └─ Tab 2: Translation (quranzikr.quran_verses[id])

Click "Duas" button
  └─ CategoryListScreen (merged: prayers.duas + quranzikr.duas)
       └─ Click dua
            └─ DetailScreen (no tabs, just content)

Home search
  └─ Searches ALL items across ALL sections
       └─ Click result
            ├─ If quran_chapters → SurahDetailScreen (2 tabs)
            ├─ If quran_verses  → SurahDetailScreen (2 tabs)
            └─ Otherwise        → DetailScreen

Favorites
  └─ Resolves IDs across ALL sections
       └─ Click → opens correct screen based on category



## Architecture Overview

┌─────────────────────────────────────────────────────────────┐
│ main.dart │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐ │
│ │ DataService │ │FavService │ │ ShiaAIApp │ │
│ │ (ChangeNotify)│ │(ChangeNotify)│ │ (MaterialApp) │ │
│ └──────┬───────┘ └──────┬───────┘ └────────┬─────────┘ │
│ │ │ │ │
│ └──── Provider ───┘ │ │
│ │ │ │
│ ┌─────────▼────────────────────────────▼─────────┐ │
│ │ HomeScreen │ │
│ │ ┌─────────────┐ ┌──────────┐ ┌───────────┐ │ │
│ │ │ Search Bar │ │Daily │ │Prayer │ │ │
│ │ │ (TextField) │ │Hadith │ │Times Card │ │ │
│ │ └──────┬──────┘ └──────────┘ └───────────┘ │ │
│ │ │ │ │
│ │ ┌──────▼──────────────────────────────────┐ │ │
│ │ │ 15 Category Grid Buttons │ │ │
│ │ └──┬───┬───┬───┬───┬───┬───┬───┬───┬───┬──┘ │ │
│ └─────┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───────┘ │
│ │ │ │ │ │ │ │ │ │ │ │
│ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ │
│ CategoryListScreen / FavoritesScreen / TasbeehScreen │
│ │ │
│ ▼ │
│ DetailScreen │
└─────────────────────────────────────────────────────────────┘


---

## Folder Structure

shia_ai/
│
├── assets/
│ └── db.json ← Primary database (Quran, Duas, etc.)
│
├── lib/
│ ├── main.dart ← App entry point, providers, theme
│ │
│ ├── models/
│ │ └── data_models.dart ← SurahModel, VerseModel data classes
│ │
│ ├── services/
│ │ ├── data_service.dart ← Loads db.json, search, category access
│ │ └── favorites_service.dart ← SharedPreferences-based favorites
│ │
│ ├── widgets/
│ │ ├── glass_container.dart ← Reusable Glassmorphism container
│ │ └── animated_background.dart ← Animated gradient mesh background
│ │
│ └── screens/
│ ├── home_screen.dart ← Main dashboard (search, hadith, grid)
│ ├── category_list_screen.dart ← List view of items in a category
│ ├── detail_screen.dart ← Full content display (Arabic + text)
│ ├── favorites_screen.dart ← Starred items list
│ └── tasbeeh_screen.dart ← Digital tasbeeh counter
│
├── pubspec.yaml ← Dependencies & asset declarations
└── README.md ← This file


---

## Data Flow Diagram

text
text
                    ┌──────────────┐
                    │  db.json     │
                    │  (assets/)   │
                    └──────┬───────┘
                           │
                  rootBundle.loadString()
                           │
                           ▼
                ┌─────────────────────┐
                │   DataService       │
                │                     │
                │ • loadData()        │  ← Called once at startup
                │ • getCategory(key)  │  ← Returns List<SurahModel>
                │ • search(query)     │  ← Searches title, desc, content
                │ • getDailyHadith()  │  ← Rotating daily hadith
                └────────┬────────────┘
                         │
                Provider.of<DataService>()
                         │
     ┌───────────────────┼───────────────────┐
     ▼                   ▼                   ▼
┌─────────────┐ ┌──────────────┐ ┌──────────────┐
│ HomeScreen │ │ CategoryList │ │ DetailScreen │
│ │ │ Screen │ │ │
│ • Search │ │ │ │ • Header │
│ • Daily Hadith│ │ • Filtered │ │ • Description │
│ • Prayer Times│ │ list view │ │ • Verses │
│ • 15 buttons │ │ • Search bar │ │ • Arabic │
└──────────────┘ │ • Star toggle│ │ • Translation │
└──────┬───────┘ └───────────────┘
│
Provider.of()
│
┌──────▼───────┐
│ FavoritesSvc │
│ │
│ • init() │ ← Loads from SharedPreferences
│ • toggle(id) │ ← Add/remove favorite
│ • isFav(id) │ ← Check if starred
└──────────────┘
│
┌──────▼───────┐
│ Favorites │
│ Screen │
│ │
│ • All starred│
│ items │
└──────────────┘

text
text

---

## Screen & Feature Map

┌─────────────────────────────────────────────────────────────────────┐
│ HOME SCREEN │
│ │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Bismillah Header │ │
│ └─────────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 🔍 Search Bar → onSubmitted → DataService.search() │ │
│ └─────────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 📜 Daily Hadith ← DataService.getDailyHadith() │ │
│ └─────────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ ⏰ Prayer Times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)│ │
│ └─────────────────────────────────────────────────────────────┘ │
│ ┌─────────┬─────────┬─────────┐ │
│ │ ⭐ Fav │ 📖 Surah│ 🤲 Duas │ Row 1 │
│ ├─────────┼─────────┼─────────┤ │
│ │ 🙏 Supp │ 🕌 Taqee│ 🕌 Namaz│ Row 2 │
│ ├─────────┼─────────┼─────────┤ │
│ │ 📍 Ziya │ 📚 Aamal│ 📅 Calen│ Row 3 │
│ ├─────────┼─────────┼─────────┤ │
│ │ 📖 Libr │ ❤️ Muna │ 🔖 Baqey│ Row 4 │
│ ├─────────┼─────────┼─────────┤ │
│ │ 🧭 Qibla│ 🔢 Tash │ ⚙️ Pref │ Row 5 │
│ └─────────┴─────────┴─────────┘ │
└─────────────────────────────────────────────────────────────────────┘

text
text

### Button → Screen Routing

| # | Grid Button | Key in Code | Navigates To | Data Source |
|---|------------|-------------|--------------|-------------|
| 1 | **Favorites** | `favorites` | `FavoritesScreen` | SharedPreferences (starred IDs) |
| 2 | **Surahs** | `quran_chapters` | `CategoryListScreen` | `db.json → prayers.quran_chapters.items` |
| 3 | **Duas** | `duas` | `CategoryListScreen` | `db.json → prayers.duas.items` |
| 4 | **Supplications** | `supplications` | `CategoryListScreen` | `db.json → prayers.supplications.items` |
| 5 | **Taqeebat e Namaz** | `taqeebat` | `CategoryListScreen` | `db.json → prayers.taqeebat.items` |
| 6 | **Namaz** | `namaz` | `CategoryListScreen` | `db.json → prayers.namaz.items` |
| 7 | **Ziyarats** | `ziyarats` | `CategoryListScreen` | `db.json → prayers.ziyarats.items` |
| 8 | **Aamaal** | `aamaal` | `CategoryListScreen` | `db.json → prayers.aamaal.items` |
| 9 | **Calendar & Times** | `calendar` | SnackBar (Coming Soon) | — |
| 10 | **Library** | `library` | `CategoryListScreen` | `db.json → prayers.library.items` |
| 11 | **Munajaat** | `munajaat` | `CategoryListScreen` | `db.json → prayers.munajaat.items` |
| 12 | **Baqeyaat as Saalehaat** | `baqeyaat` | `CategoryListScreen` | `db.json → prayers.baqeyaat.items` |
| 13 | **Qibla Finder** | `qibla` | SnackBar (Coming Soon) | — |
| 14 | **Tasbeeh Counter** | `tasbeeh` | `TasbeehScreen` | In-app state |
| 15 | **Preferences** | `settings` | SnackBar (Coming Soon) | — |

---

## Database Contents

### `db.json` Top-Level Structure

```json
{
  "app": { "name": "Shia AI", "version": "2.0.0", "package": "com.shia_ai.app" },
  "prayers": {
    "quran_chapters": {
      "description": "Quranic chapters (Surahs) with Arabic text and translations",
      "count": 118,
      "items": { ... }
    }
  }
}

Available Quranic Chapters in db.json

ID	Surah #	English Name	Arabic Name	Verses	Revealed In	Key Virtues / Benefits
A94	90	Al-Balad	البلد	20	Makkah	Safe from Wrath of Allah on Day of Reckoning; counted among pious; cure for nose ailments
A27	23	Al-Mu'minun	المؤمنون	118	Makkah	Comfort at time of death; great status in hereafter; hating intoxicating drinks
A51	47	Muhammad	محمد	37	Madinah	Quenched thirst from rivers of Jannah; no doubts about religion; thousand angels send salutations at grave
A53	49	Al-Hujurat	الحجرات	18	Madinah	Reward compared to 10× believers & disbelievers; Shaitan runs away; safety in war; increases breast-milk
A52	48	Al-Fath	الفتح	29	Madinah	As if present at conquest of Makkah; sincere servant of Allah; cure for heart problems; protection for travelers
A54	50	Qaf	ق	45	Makkah	No suffering at time of death; increased sustenance; easy accounting on Day of Judgement; cure for eye ailments
A59	55	Ar-Rahman	الرحمن	78	Makkah	Removes hypocrisy; intercession on Day of Judgement; considered martyr if dies after reciting; cures eye ailments
A58	54	Al-Qamar	القمر	55	Makkah	Face shines like full moon on Day of Reckoning; mount from Jannah; highly respected by people
A86	82	Al-Infitar	الإنفطار	19	Makkah	No curtain between Allah and reciter; prisoner released sooner; sins equal to raindrops forgiven; good for eyes
A45	41	Fussilat	فصلت	54	Makkah	10 rewards per letter; light on Day of Judgement; alleviates eye problems
A48	44	Ad-Dukhan	الدخان	59	Makkah	70,000 angels pray for forgiveness; all sins forgiven on Thursday nights; protection from Shaitan; no nightmares; trade prospers
A49	45	Al-Jathiya	الجاثية	37	Makkah	No fright on Day of Judgement; private parts remain covered; beloved of people; safe from tyrant rulers
A99	95	At-Tin	التين	8	Makkah	Great palace in Jannah; reward cannot be counted; evil effects removed from food
A98	94	Ash-Sharh	الشرح	8	Makkah	Good fortune and certitude in religion; relieves chest pains; cure for urination and heart problems
A97	93	Ad-Dhuha	الضحى	11	Makkah	Allah is pleased; missing person returns; forgotten items kept safe
A91	87	Al-A'la	الأعلى	19	Makkah	Reward = 10× letters in divine books; enter Jannah through any door; relieves ear pains
A90	86	At-Tariq	الطارق	17	Makkah	Reward = 10× heavenly bodies; honoured by Allah; recited over anything keeps it safe; sure cure for medicine
A57	53	An-Najm	النجم	26	Makkah	Reward = 10× believers & sinners; respectable life; courageous before rulers; wins debates
A92	88	Al-Ghashiya	الغاشية	26	Makkah	Easy accounting on Day of Judgement; saved from Jahannam; removes fright from babies; removes bad food effects
A96	92	Al-Lail	الليل	21	Makkah	Pleasing reward in Book of Deeds; increased Tawfiq; good dreams; 15× before sleep = dreams of pleasure
A30	26	Ash-Shu'ara	الشعراء	227	Makkah	Counted among Awliyaa-ullah; comes out of grave reciting Shahadah; protection from thieves, drowning, burning
A56	52	At-Tur	الطور	49	Makkah	Safe from wrath of Allah; good fortune; early release from prison; keeps children healthy

Item Schema (per entry in items)

text
text
{
  "id":          "A94"                           // Unique identifier
  "title":       "90 : Al-Balad البلد"          // Surah number + English + Arabic name
  "content":     "SURAH AL-BALAD (THE CITY)\r\n  // Full content block containing:
                  \r\n                            //   1. Title (ALL CAPS)
                  This Surah has 20 verses...     //   2. Description / Virtues / Benefits
                  \r\n                            //   3. Arabic verses separated by --
                  --بِسْمِ اللهِ...--             //   4. Verse numbers in (parentheses)
                  (1)--وَ...--(2)--..."
}

Content Parsing Logic

text
text
content string
    │
    ├──► Split by \r\n\r\n (double newline)
    │
    ├──► Lines BEFORE Arabic block → Description / Virtues
    │
    └──► Arabic block (lines containing -- and Arabic chars)
         │
         └──► Split by "--"
              │
              ├──► Each segment = one verse
              ├──► Extract verse number from (n) pattern
              └──► Arabic text = segment minus number


Feature Details

1. Home Screen (home_screen.dart)

Component	Widget	Data Source	Interaction
Bismillah	Static Text with Amiri font	Hardcoded Arabic	—
Search Bar	GlassContainer + TextField	DataService.search()	onSubmitted → opens bottom sheet with results
Daily Hadith	GlassContainer + Text	DataService.getDailyHadith()	Rotates daily based on day-of-year
Prayer Times	GlassContainer + horizontal Row	Hardcoded (static)	Horizontal scroll
Grid (15 items)	SliverGrid (3 columns)	_cats list (hardcoded labels)	onTap → route to appropriate screen

Animations:

Staggered fade + slide on every section (delay = index * 120ms)
Grid items stagger with index * 55ms delay
AnimatedBackground with 12-second cycling gradient

2. Category List Screen (category_list_screen.dart)

text
text
┌─────────────────────────────────────────┐
│  AppBar: Category Title (gold)          │
├─────────────────────────────────────────┤
│  🔍 Search Bar (filters local list)     │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │ [#] Arabic Name        ⭐ Star  │    │
│  │     English Title               │    │
│  │     Description preview...      │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │ [#] Arabic Name        ⭐ Star  │    │
│  │     ...                         │    │
│  └─────────────────────────────────┘    │
│           ...                            │
└─────────────────────────────────────────┘

Action	Result
Tap item row	Navigate to DetailScreen with SurahModel
Tap star icon	FavoritesService.toggle(id) — adds/removes from favorites
Type in search bar	Filters list by title and description (case-insensitive)

3. Detail Screen (detail_screen.dart)

text
text
┌─────────────────────────────────────────┐
│  AppBar: English Name    ⭐ (favorite)  │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │        العربية Name              │    │
│  │        English Name              │    │
│  │        [XX Verses] badge         │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │  📖 Virtues & Benefits           │    │
│  │  Description text...             │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │  بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ  │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │  [1]                            │    │
│  │  Arabic verse text (RTL)        │    │
│  │  ─────────────────              │    │
│  │  Transliteration (if available) │    │
│  │  Translation (if available)     │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │  [2]                            │    │
│  │  ...                            │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘

Content Display Rules:


Content Type	Font	Direction	Alignment
Arabic text	Amiri (25px)	RTL	Right
Arabic name (header)	Amiri (38px)	RTL	Center
English title	PlayfairDisplay (22px)	LTR	Center
Description	Lora (14.5px)	LTR	Left
Transliteration	Lora italic (14px)	LTR	Left
Translation	Lora (14px)	LTR	Left
Verse number	Lora bold (12px)	—	Center (in circle)

4. Favorites Screen (favorites_screen.dart)

State	Display
Empty	Star icon (80px, 12% opacity) + "No favorites yet" + "Tap the star icon to save items here"
Has items	List of starred items with Arabic name, English name, close button to remove

Persistence:SharedPreferences stores a JSON array of favorite IDs.


dart
dart
// Storage format
key: "favorites"
value: "[\"A94\",\"A52\",\"A59\"]"

5. Tasbeeh Screen (tasbeeh_screen.dart)

text
text
┌─────────────────────────────────────────┐
│  AppBar: Tasbeeh Counter    🔄 Reset   │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │  سُبْحَانَ اللّٰهِ               │    │
│  │  SubhanAllah                     │    │
│  │  ● ● ● ● ● ●                    │    │
│  └─────────────────────────────────┘    │
│                                         │
│           ┌─────────────┐               │
│           │             │               │
│           │     17      │               │  ← Tappable circle
│           │    of 33    │               │     (pulse animation)
│           │             │               │
│           └─────────────┘               │
│                                         │
│  ████████████████░░░░░░░  (progress)    │
│                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐      │
│  │ Total  │ │ Target │ │Remain  │      │
│  │  45    │ │  33    │ │  16    │      │
│  └────────┘ └────────┘ └────────┘      │
│                                         │
│  Target: [33] [34] [99] [100]           │
└─────────────────────────────────────────┘

Feature	Details
Dhikr options	6 presets: SubhanAllah, Alhamdulillah, Allahu Akbar, La Ilaha IllAllah, Astaghfirullah, La Hawla Wala Quwwata
Tap counting	Haptic feedback (HapticFeedback.lightImpact) + scale pulse animation
Auto-reset	Counter resets to 0 when target is reached
Target presets	33, 34, 99, 100 — changes reset the counter
Stats	Total count (persists across targets), Target, Remaining
Progress bar	LinearProgressIndicator with gold accent

6. Search (Home Screen)

text
text
User types query
       │
       ▼
DataService.search(query)
       │
       ├── Searches: title, description, content
       ├── Case-insensitive
       └── Returns List<SurahModel>
                │
                ▼
    showModalBottomSheet
       │
       └── DraggableScrollableSheet (70% → 95% height)
           ├── "Results for 'query'" header
           ├── Glass cards for each result
           └── Empty state: "No results found"


UI / Design System

Color Palette

css
css
:root {
  --bg-primary:       #0a0015;    /* Deep space purple-black */
  --bg-secondary:     #1a0533;    /* Dark purple */
  --bg-tertiary:      #0d1b2a;    /* Navy */
  --accent-gold:      #D4AF37;    /* Islamic gold */
  --accent-teal:      #00BFA5;    /* Prayer times accent */
  --accent-pink:      #E91E63;    /* Duas accent */
  --text-primary:     rgba(255,255,255,0.9);
  --text-secondary:   rgba(255,255,255,0.7);
  --text-muted:       rgba(255,255,255,0.4);
  --glass-bg:         rgba(255,255,255,0.12);
  --glass-border:     rgba(255,255,255,0.18);
  --glass-shadow:     rgba(0,0,0,0.25);
}

Glassmorphism Properties

Property	Value
Background gradient	white(0.20) → white(0.12) (top-left to bottom-right)
Border	1.5px solid white(0.18)
Blur	sigmaX: 15, sigmaY: 15 (BackdropFilter)
Shadow	black(0.25), blur: 20px, offset: (0, 8)
Border radius	14–24px (context-dependent)

Typography

Usage	Font	Weight	Size
App title / Headers	PlayfairDisplay	Bold	22–26px
Arabic text	Amiri	Regular/Bold	23–38px
Body text	Lora	Regular	14–15px
Captions / Labels	Lora	Regular	11–13px
Bismillah	Amiri	—	22px

Animation Timing

Element	Animation	Duration	Delay
Background gradient	Continuous linear	12s	—
Section fade-in	Opacity + Slide Y	600ms + (delay×120ms)	0–600ms stagger
Grid items	Opacity + Slide Y	500ms + (index×55ms)	0–825ms stagger
Star toggle	Scale + Color	300ms	—
Tasbeeh tap	Scale pulse	150ms	—
Favorite icon	AnimatedSwitcher	300ms	—


Setup & Installation

Prerequisites

Flutter SDK ≥ 3.0.0
Dart SDK ≥ 3.0.0

Steps

bash
bash
# 1. Clone the repository
git clone https://github.com/your-username/shia_ai.git
cd shia_ai

# 2. Place your db.json in assets/
cp /path/to/your/db.json assets/db.json

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run

Dependencies

Package	Version	Purpose
flutter	SDK	Core framework
google_fonts	^6.1.0	Amiri, Lora, PlayfairDisplay fonts
shared_preferences	^2.2.2	Persist favorites locally
provider	^6.1.1	State management (DataService, FavoritesService)


How Everything Connects (Summary)

text
text
                    ┌─────────────────────┐
                    │      db.json        │
                    │  (assets folder)    │
                    └─────────┬───────────┘
                              │
                     loadData() at startup
                              │
                              ▼
                    ┌─────────────────────┐
                    │    DataService      │◄── ChangeNotifier
                    │                     │
                    │ categories map:     │    Provided via
                    │  "quran_chapters"   │    MultiProvider
                    │   → List<SurahModel>│
                    └─────────┬───────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
       HomeScreen     CategoryList      DetailScreen
       ┌────────┐     Screen            ┌──────────┐
       │ Search │────►Filtered List────►│ Header   │
       │ Hadith │     with stars        │ Desc/Vrt │
       │ Times  │                       │ Verses   │
       │ 15 Btns│                       │ Arabic   │
       └────────┘                       │ Translit │
              │                         │ Translate│
              │                         └──────────┘
              │
    ┌─────────┼─────────┐
    │         │         │
    ▼         ▼         ▼
 Favorites  Tasbeeh   (Coming Soon)
 Screen     Screen    Qibla / Calendar
    │         │       / Preferences
    │         │
    ▼         ▼
 SharedPrefs  In-app State
 (persisted)  (volatile)

Key Design Decisions

1.Single db.json — All content lives in one file, parsed once at startup by DataService
2.Provider pattern — DataService and FavoritesService are ChangeNotifiers provided at the root; any widget can watch() or read() them
3.Favorites are IDs only — Only the item ID (e.g., A94) is stored in SharedPreferences; the full object is resolved from DataService at render time
4.Content is self-describing — Each item's content field contains its own description/virtues section plus the full Arabic text; the DetailScreen parses and renders both
5.Glassmorphism everywhere — A single GlassContainer widget is reused across all screens with configurable borderRadius, blur, and opacity
6.Staggered animations — Every screen uses index-based delay calculations to create a cascading reveal effect without external animation libraries


License

This project is for personal/educational use. The Quranic content and hadith references are sourced from Islamic scholarly traditions.