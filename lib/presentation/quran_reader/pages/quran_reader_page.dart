import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quran/flutter_quran.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';

import 'package:quran/presentation/choose_reciter/pages/choose_reciter.dart';
import 'package:quran/presentation/mode/pages/choose_quran_mode.dart';

const Color quranGreen = Color(0xFF16845B);
const Color quranDarkGreen = Color(0xFF126B45);

class QuranReaderPage extends StatefulWidget {
const QuranReaderPage({super.key});

@override
State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
final FlutterQuran _quran = FlutterQuran();
final GetStorage _storage = GetStorage();
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final AudioPlayer _ayahPlayer = AudioPlayer();

StreamSubscription<PlayerState>? _playerSubscription;

bool _isInitializing = true;
bool _isPlayingAyah = false;

int _currentPage = 1;
int _currentJuz = 1;
int _currentHizb = 1;

List<Map<String, dynamic>> _bookmarks = [];

static const List<int> _juzStartPages = [
1, 22, 42, 62, 82, 102, 121, 142, 162, 182,
201, 222, 242, 262, 282, 302, 322, 342, 362, 382,
402, 422, 442, 462, 482, 502, 522, 542, 562, 582,
];

static const List<int> _hizbStartPages = [
1, 11, 22, 32, 42, 52, 62, 72, 82, 92,
102, 112, 121, 131, 142, 152, 162, 172, 182, 192,
201, 211, 222, 232, 242, 252, 262, 272, 282, 292,
302, 312, 322, 332, 342, 352, 362, 372, 382, 392,
402, 412, 422, 432, 442, 452, 462, 472, 482, 492,
502, 512, 522, 532, 542, 552, 562, 572, 582, 592,
];

String get _userId => _auth.currentUser?.uid ?? 'guest';

String get _bookmarkKey => 'quran_reader_bookmarks_$_userId';

String get _pageKey => 'quran_reader_last_page_$_userId';

bool get _isCurrentPageBookmarked {
return _bookmarks.any(
(item) =>
item['isPageBookmark'] == true &&
item['page'] == _currentPage,
);
}

@override
void initState() {
super.initState();

_playerSubscription = _ayahPlayer.playerStateStream.listen((state) {
if (!mounted) return;

setState(() {
_isPlayingAyah = state.playing;
});
});

_initializeReader();
}

@override
void dispose() {
_playerSubscription?.cancel();
_ayahPlayer.dispose();
super.dispose();
}

void _updateJuzAndHizb(int page) {
final safePage = page.clamp(1, 604).toInt();

var juz = 1;
for (var i = 0; i < _juzStartPages.length; i++) {
if (safePage >= _juzStartPages[i]) {
juz = i + 1;
} else {
break;
}
}

var hizb = 1;
for (var i = 0; i < _hizbStartPages.length; i++) {
if (safePage >= _hizbStartPages[i]) {
hizb = i + 1;
} else {
break;
}
}

_currentJuz = juz;
_currentHizb = hizb;
}

Future<void> _initializeReader() async {
try {
await _quran.init();

final savedPage = _storage.read(_pageKey);
final legacyPage = _storage.read('quran_reader_last_page');

final int page = savedPage is int
? savedPage
    : legacyPage is int
? legacyPage
    : 1;

_currentPage = page.clamp(1, 604).toInt();
_updateJuzAndHizb(_currentPage);

final savedBookmarks = _storage.read(_bookmarkKey);

if (savedBookmarks is List) {
_bookmarks = savedBookmarks
    .whereType<Map>()
    .map((item) => Map<String, dynamic>.from(item))
    .toList();
} else {
final legacyBookmarks =
_storage.read('quran_reader_bookmarks');

if (legacyBookmarks is List) {
_bookmarks = legacyBookmarks
    .whereType<Map>()
    .map((item) => Map<String, dynamic>.from(item))
    .toList();
}
}

final user = _auth.currentUser;

if (user != null) {
await _loadCloudData(user.uid);
}
} catch (error) {
debugPrint('Quran reader initialization error: $error');
} finally {
if (mounted) {
setState(() => _isInitializing = false);
}
}
}

Future<void> _loadCloudData(String uid) async {
try {
final snapshot =
await _firestore.collection('users').doc(uid).get();

final data = snapshot.data();
if (data == null) return;

final cloudPage = data['quranReaderLastPage'];

if (cloudPage is int && _storage.read(_pageKey) == null) {
_currentPage = cloudPage.clamp(1, 604).toInt();
_updateJuzAndHizb(_currentPage);
await _storage.write(_pageKey, _currentPage);
}

final cloudBookmarks = data['quranReaderBookmarks'];

if (cloudBookmarks is List &&
_storage.read(_bookmarkKey) == null) {
_bookmarks = cloudBookmarks
    .whereType<Map>()
    .map((item) => Map<String, dynamic>.from(item))
    .toList();

await _storage.write(_bookmarkKey, _bookmarks);
}
} catch (error) {
debugPrint('Quran cloud loading error: $error');
}
}

Future<void> _savePage(int page) async {
final safePage = page.clamp(1, 604).toInt();

if (mounted) {
setState(() {
_currentPage = safePage;
_updateJuzAndHizb(safePage);
});
} else {
_currentPage = safePage;
_updateJuzAndHizb(safePage);
}

await _storage.write(_pageKey, safePage);

final user = _auth.currentUser;
if (user == null) return;

try {
await _firestore.collection('users').doc(user.uid).set({
'quranReaderLastPage': safePage,
}, SetOptions(merge: true));
} catch (error) {
debugPrint('Quran page saving error: $error');
}
}

void _onPageChanged(int pageIndex) {
final page = (pageIndex + 1).clamp(1, 604).toInt();

if (page == _currentPage) return;

setState(() {
_currentPage = page;
_updateJuzAndHizb(page);
});

unawaited(_savePage(page));
}

Future<void> _saveBookmarks() async {
await _storage.write(_bookmarkKey, _bookmarks);

final user = _auth.currentUser;
if (user == null) return;

try {
await _firestore.collection('users').doc(user.uid).set({
'quranReaderBookmarks': _bookmarks,
}, SetOptions(merge: true));
} catch (error) {
debugPrint('Quran bookmarks saving error: $error');
}
}

Future<void> _addCurrentPageBookmark() async {
final page = _currentPage;

final existingIndex = _bookmarks.indexWhere(
(item) =>
item['isPageBookmark'] == true &&
item['page'] == page,
);

if (existingIndex != -1) {
setState(() {
_bookmarks.removeAt(existingIndex);
});

await _saveBookmarks();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('تم حذف علامة الصفحة $page')),
);

return;
}

final bookmark = <String, dynamic>{
'ayahId': -page,
'page': page,
'ayahNumber': page,
'surahName': 'علامة صفحة',
'ayahText': '',
'isPageBookmark': true,
'createdAt': DateTime.now().toIso8601String(),
};

setState(() {
_bookmarks.insert(0, bookmark);
});

await _saveBookmarks();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('تم حفظ الصفحة $page')),
);
}

Future<void> _addAyahBookmark(dynamic ayah) async {
final int ayahId = ayah.id as int;
final int page = ayah.page as int;

final exists = _bookmarks.any(
(item) =>
item['isPageBookmark'] != true &&
item['ayahId'] == ayahId,
);

if (exists) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('الآية موجودة بالفعل في العلامات المرجعية'),
),
);
return;
}

final bookmark = <String, dynamic>{
'ayahId': ayahId,
'page': page,
'ayahNumber': ayah.ayahNumber,
'surahName': ayah.surahNameAr,
'ayahText': ayah.ayah,
'surahNumber': ayah.surahNumber,
'createdAt': DateTime.now().toIso8601String(),
};

setState(() {
_bookmarks.insert(0, bookmark);
});

await _saveBookmarks();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('تمت إضافة الآية إلى العلامات المرجعية'),
),
);
}

Future<void> _removeBookmark(
Map<String, dynamic> bookmark,
StateSetter? updateSheet,
) async {
setState(() {
_bookmarks.removeWhere(
(item) =>
item['createdAt'] == bookmark['createdAt'] &&
item['ayahId'] == bookmark['ayahId'] &&
item['page'] == bookmark['page'],
);
});

updateSheet?.call(() {});

await _saveBookmarks();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('تم حذف العلامة المرجعية')),
);
}

void _openBookmarks() {
showModalBottomSheet<void>(
context: context,
isScrollControlled: true,
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(
top: Radius.circular(24),
),
),
builder: (sheetContext) {
return StatefulBuilder(
builder: (context, setSheetState) {
return SafeArea(
child: SizedBox(
height: MediaQuery.of(context).size.height * 0.7,
child: Column(
children: [
const SizedBox(height: 12),
Container(
width: 42,
height: 4,
decoration: BoxDecoration(
color: Colors.grey.shade400,
borderRadius: BorderRadius.circular(8),
),
),
Padding(
padding: const EdgeInsets.all(18),
child: Row(
children: [
const Icon(
Icons.bookmark,
color: quranGreen,
),
const SizedBox(width: 10),
const Expanded(
child: Text(
'العلامات المرجعية',
style: TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),
),
Text('${_bookmarks.length}'),
],
),
),
const Divider(height: 1),
Expanded(
child: _bookmarks.isEmpty
? const Center(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.bookmark_border,
size: 56,
color: quranGreen,
),
SizedBox(height: 12),
Text(
'لا توجد علامات مرجعية حتى الآن',
),
],
),
)
    : ListView.builder(
itemCount: _bookmarks.length,
itemBuilder: (context, index) {
final bookmark = _bookmarks[index];
final isPage =
bookmark['isPageBookmark'] == true;

return ListTile(
key: ValueKey(
'${bookmark['ayahId']}_${bookmark['createdAt']}',
),
leading: CircleAvatar(
backgroundColor:
const Color(0x1F16845B),
child: Icon(
isPage
? Icons.menu_book
    : Icons.bookmark,
color: quranGreen,
),
),
title: Text(
isPage
? 'الصفحة ${bookmark['page']}'
    : '${bookmark['surahName'] ?? 'القرآن الكريم'}'
' - الآية ${bookmark['ayahNumber'] ?? ''}',
),
subtitle: isPage
? const Text(
'علامة مرجعية للصفحة',
)
    : Text(
'صفحة ${bookmark['page'] ?? 1}',
),
onTap: () {
final page =
(bookmark['page'] as int? ?? 1)
    .clamp(1, 604)
    .toInt();

Navigator.pop(sheetContext);
_quran.navigateToPage(page);
unawaited(_savePage(page));
},
trailing: IconButton(
tooltip: 'حذف العلامة',
icon: const Icon(
Icons.delete_outline,
color: Colors.redAccent,
),
onPressed: () {
unawaited(
_removeBookmark(
bookmark,
setSheetState,
),
);
},
),
);
},
),
),
],
),
),
);
},
);
},
);
}

void _openNavigation() {
final surahs = _quran.getAllSurahs();
final jozzs = _quran.getAllJozzs();
final hizbs = _quran.getAllHizbs();

showModalBottomSheet<void>(
context: context,
isScrollControlled: true,
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(
top: Radius.circular(24),
),
),
builder: (sheetContext) {
return DefaultTabController(
length: 4,
child: SafeArea(
child: SizedBox(
height: MediaQuery.of(context).size.height * 0.72,
child: Column(
children: [
const SizedBox(height: 18),
const Text(
'الانتقال إلى',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
const TabBar(
labelColor: quranGreen,
indicatorColor: quranGreen,
tabs: [
Tab(text: 'السور'),
Tab(text: 'الأجزاء'),
Tab(text: 'الأحزاب'),
Tab(text: 'الصفحات'),
],
),
Expanded(
child: TabBarView(
children: [
ListView.builder(
itemCount: surahs.length,
itemBuilder: (context, index) {
return ListTile(
leading: CircleAvatar(
backgroundColor:
const Color(0x1F16845B),
child: Text('${index + 1}'),
),
title: Text(
surahs[index],
textDirection: TextDirection.rtl,
),
onTap: () {
Navigator.pop(sheetContext);
_quran.navigateToSurah(index + 1);
},
);
},
),
ListView.builder(
itemCount: jozzs.length,
itemBuilder: (context, index) {
return ListTile(
leading: const Icon(
Icons.menu_book,
color: quranGreen,
),
title: Text('الجزء ${index + 1}'),
subtitle: Text(jozzs[index]),
onTap: () {
Navigator.pop(sheetContext);
_quran.navigateToJozz(index + 1);
},
);
},
),
ListView.builder(
itemCount: hizbs.length,
itemBuilder: (context, index) {
return ListTile(
leading: const Icon(
Icons.library_books,
color: quranGreen,
),
title: Text('الحزب ${index + 1}'),
subtitle: Text(hizbs[index]),
onTap: () {
Navigator.pop(sheetContext);
_quran.navigateToHizb(index + 1);
},
);
},
),
_PagePicker(
currentPage: _currentPage,
onGo: (page) {
Navigator.pop(sheetContext);
_quran.navigateToPage(page);
unawaited(_savePage(page));
},
),
],
),
),
],
),
),
),
);
},
);
}

Future<void> _showAyahTafsir(dynamic ayah) async {
showModalBottomSheet<void>(
context: context,
isScrollControlled: true,
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(
top: Radius.circular(24),
),
),
builder: (sheetContext) {
return SafeArea(
child: Padding(
padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
child: SizedBox(
height: MediaQuery.of(context).size.height * 0.65,
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Center(
child: Container(
width: 42,
height: 4,
decoration: BoxDecoration(
color: Colors.grey.shade400,
borderRadius: BorderRadius.circular(8),
),
),
),
const SizedBox(height: 18),
Text(
'${ayah.surahNameAr} - الآية ${ayah.ayahNumber}',
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 16),
Text(
'${ayah.ayah}',
textDirection: TextDirection.rtl,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 23,
height: 1.9,
),
),
const Divider(height: 28),
const Text(
'التفسير الميسّر',
textDirection: TextDirection.rtl,
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
color: quranGreen,
),
),
const SizedBox(height: 8),
Expanded(
child: FutureBuilder<String>(
future: _fetchTafsir(ayah.id as int),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(
color: quranGreen,
),
);
}

if (snapshot.hasError) {
return Center(
child: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.wifi_off,
size: 35,
color: Colors.grey,
),
const SizedBox(height: 8),
const Text(
'تعذّر تحميل التفسير.',
textDirection: TextDirection.rtl,
),
const SizedBox(height: 8),
OutlinedButton.icon(
onPressed: () {
Navigator.pop(sheetContext);
_showAyahTafsir(ayah);
},
icon: const Icon(Icons.refresh),
label: const Text('إعادة المحاولة'),
),
],
),
),
);
}

final tafsir = snapshot.data;

if (tafsir == null || tafsir.trim().isEmpty) {
return const Center(
child: Text(
'لا يتوفر تفسير لهذه الآية.',
textDirection: TextDirection.rtl,
),
);
}

return SingleChildScrollView(
child: Text(
tafsir,
textDirection: TextDirection.rtl,
textAlign: TextAlign.justify,
style: const TextStyle(
fontSize: 17,
height: 1.9,
),
),
);
},
),
),
const SizedBox(height: 12),
Row(
children: [
Expanded(
child: OutlinedButton.icon(
onPressed: () {
Navigator.pop(sheetContext);
unawaited(_playAyah(ayah));
},
icon: const Icon(Icons.play_arrow),
label: const Text('استماع للآية'),
),
),
const SizedBox(width: 10),
Expanded(
child: FilledButton.icon(
style: FilledButton.styleFrom(
backgroundColor: quranGreen,
),
onPressed: () {
Navigator.pop(sheetContext);
unawaited(_addAyahBookmark(ayah));
},
icon: const Icon(Icons.bookmark_add),
label: const Text('حفظ الآية'),
),
),
],
),
],
),
),
),
);
},
);
}

Future<String> _fetchTafsir(int ayahId) async {
final client = HttpClient();

try {
final uri = Uri.parse(
'https://api.alquran.cloud/v1/ayah/$ayahId/ar.muyassar',
);

final request = await client
    .getUrl(uri)
    .timeout(const Duration(seconds: 20));

final response = await request.close().timeout(
const Duration(seconds: 20),
);

final body = await response.transform(utf8.decoder).join();

if (response.statusCode != 200) {
debugPrint(
'Tafsir HTTP error ${response.statusCode}: $body',
);
throw Exception('Tafsir request failed');
}

final decoded = jsonDecode(body) as Map<String, dynamic>;

if (decoded['code'] != 200) {
debugPrint('Tafsir API error: $decoded');
throw Exception('Tafsir API returned an error');
}

final data = decoded['data'] as Map<String, dynamic>?;
final tafsir = data?['text']?.toString();

if (tafsir == null || tafsir.trim().isEmpty) {
throw Exception('Tafsir is empty');
}

return tafsir;
} catch (error) {
debugPrint('Tafsir loading error: $error');
rethrow;
} finally {
client.close(force: true);
}
}

Future<void> _playAyah(dynamic ayah) async {
try {
final int surahNumber = ayah.surahNumber as int;
final int ayahNumber = ayah.ayahNumber as int;

final surah = surahNumber.toString().padLeft(3, '0');
final ayahFormatted = ayahNumber.toString().padLeft(3, '0');

final url =
'https://everyayah.com/data/Husary_128kbps/'
'$surah$ayahFormatted.mp3';

await _ayahPlayer.stop();
await _ayahPlayer.setUrl(url);
await _ayahPlayer.play();
} catch (error) {
debugPrint('Ayah audio error: $error');

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'تعذّر تشغيل الآية. تأكد من الإنترنت وحاول مرة أخرى.',
),
),
);
}
}

Future<void> _openListening() async {
await Navigator.push<void>(
context,
MaterialPageRoute<void>(
builder: (_) => const ChooseReciterPage(),
),
);
}

Future<void> _openPageDialog() async {
final controller = TextEditingController(
text: '$_currentPage',
);

final page = await showDialog<int>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('الانتقال إلى صفحة'),
content: TextField(
controller: controller,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
hintText: 'من 1 إلى 604',
prefixIcon: Icon(Icons.menu_book),
),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(dialogContext),
child: const Text('إلغاء'),
),
FilledButton(
onPressed: () {
final value =
int.tryParse(controller.text.trim());

if (value == null || value < 1 || value > 604) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('أدخل رقم صفحة من 1 إلى 604'),
),
);
return;
}

Navigator.pop(dialogContext, value);
},
child: const Text('انتقال'),
),
],
);
},
);

controller.dispose();

if (page == null) return;

_quran.navigateToPage(page);
await _savePage(page);
}

Future<void> _goBack() async {
if (!mounted) return;

Navigator.pushReplacement(
context,
MaterialPageRoute<void>(
builder: (_) => ChooseQuranModePage(),
),
);
}

@override
Widget build(BuildContext context) {
final isDark =
Theme.of(context).brightness == Brightness.dark;

return Scaffold(
appBar: AppBar(
backgroundColor: quranGreen,
foregroundColor: Colors.white,
elevation: 0,
leading: IconButton(
tooltip: 'رجوع',
icon: const Icon(Icons.arrow_back),
onPressed: _goBack,
),
title: const Text(
'القرآن الكريم',
style: TextStyle(fontWeight: FontWeight.bold),
),
centerTitle: true,
actions: [
IconButton(
tooltip: 'البحث في القرآن',
onPressed: () {
showSearch<void>(
context: context,
delegate: QuranSearchDelegate(
_quran,
onAyahSelected: (ayah) {
_quran.navigateToAyah(ayah);
unawaited(_savePage(ayah.page as int));
},
onTafsir: _showAyahTafsir,
onBookmark: _addAyahBookmark,
onPlay: _playAyah,
),
);
},
icon: const Icon(Icons.search),
),
IconButton(
tooltip: 'العلامات المرجعية',
onPressed: _openBookmarks,
icon: const Icon(Icons.bookmark_outline),
),
IconButton(
tooltip: 'الانتقال',
onPressed: _openNavigation,
icon: const Icon(Icons.menu_book_outlined),
),
],
),
body: _isInitializing
? const Center(
child: CircularProgressIndicator(
color: quranGreen,
),
)
    : Column(
children: [
Container(
width: double.infinity,
color: isDark
? quranDarkGreen.withValues(alpha: 0.35)
    : const Color(0xFFEAF5EF),
padding: const EdgeInsets.symmetric(
horizontal: 8,
vertical: 3,
),
child: Row(
children: [
Expanded(
child: Row(
children: [
const Icon(
Icons.menu_book,
color: quranGreen,
size: 19,
),
const SizedBox(width: 5),
Text(
'الجزء $_currentJuz',
style: const TextStyle(
fontWeight: FontWeight.w600,
fontSize: 12,
),
),
const SizedBox(width: 12),
Text(
'الحزب $_currentHizb',
style: const TextStyle(
fontWeight: FontWeight.w600,
fontSize: 12,
),
),
],
),
),
IconButton(
tooltip: _isCurrentPageBookmarked
? 'إزالة العلامة المرجعية'
    : 'حفظ الصفحة الحالية',
visualDensity: VisualDensity.compact,
onPressed: _addCurrentPageBookmark,
icon: Icon(
_isCurrentPageBookmarked
? Icons.bookmark
    : Icons.bookmark_border,
color: _isCurrentPageBookmarked
? Colors.amber
    : quranGreen,
size: 22,
),
),
IconButton(
tooltip: 'الاستماع للقرآن',
visualDensity: VisualDensity.compact,
onPressed: _openListening,
icon: const Icon(
Icons.headphones,
color: quranGreen,
size: 22,
),
),
TextButton(
onPressed: _openPageDialog,
style: TextButton.styleFrom(
foregroundColor: quranGreen,
padding: const EdgeInsets.symmetric(
horizontal: 5,
),
minimumSize: const Size(0, 32),
),
child: Text(
'$_currentPage',
style: const TextStyle(fontSize: 13),
),
),
],
),
),
Expanded(
child: SizedBox.expand(
child: FlutterQuranScreen(
useDefaultAppBar: false,
onPageChanged: _onPageChanged,
onAyahTap: (ayah) {
unawaited(_showAyahTafsir(ayah));
},
),
),
),
if (_isPlayingAyah)
Material(
color: quranGreen,
child: SafeArea(
top: false,
child: ListTile(
dense: true,
leading: const Icon(
Icons.graphic_eq,
color: Colors.white,
),
title: const Text(
'جاري تشغيل الآية',
style: TextStyle(color: Colors.white),
),
trailing: IconButton(
tooltip: 'إيقاف الصوت',
onPressed: () async {
await _ayahPlayer.stop();
},
icon: const Icon(
Icons.stop_circle_outlined,
color: Colors.white,
),
),
),
),
),
],
),
);
}
}

class _PagePicker extends StatefulWidget {
const _PagePicker({
required this.currentPage,
required this.onGo,
});

final int currentPage;
final ValueChanged<int> onGo;

@override
State<_PagePicker> createState() => _PagePickerState();
}

class _PagePickerState extends State<_PagePicker> {
late int _page;

@override
void initState() {
super.initState();
_page = widget.currentPage;
}

@override
Widget build(BuildContext context) {
return Padding(
padding: const EdgeInsets.all(22),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.menu_book,
size: 44,
color: quranGreen,
),
const SizedBox(height: 20),
Text(
'صفحة $_page',
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
Slider(
value: _page.toDouble(),
min: 1,
max: 604,
divisions: 603,
activeColor: quranGreen,
label: '$_page',
onChanged: (value) {
setState(() => _page = value.round());
},
),
const SizedBox(height: 12),
FilledButton.icon(
style: FilledButton.styleFrom(
backgroundColor: quranGreen,
),
onPressed: () => widget.onGo(_page),
icon: const Icon(Icons.arrow_forward),
label: const Text('انتقال إلى الصفحة'),
),
],
),
);
}
}

class QuranSearchDelegate extends SearchDelegate<void> {
QuranSearchDelegate(
this.quran, {
required this.onAyahSelected,
required this.onTafsir,
required this.onBookmark,
required this.onPlay,
});

final FlutterQuran quran;
final ValueChanged<dynamic> onAyahSelected;
final ValueChanged<dynamic> onTafsir;
final ValueChanged<dynamic> onBookmark;
final ValueChanged<dynamic> onPlay;

static const int _maxResults = 100;

@override
String get searchFieldLabel => 'ابحث بكلمات من الآية';

String _normalizeArabic(String text) {
return text
    .replaceAll(
RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
'',
)
    .replaceAll('ـ', '')
    .replaceAll(RegExp('[أإآٱ]'), 'ا')
    .replaceAll('ى', 'ي')
    .replaceAll('ؤ', 'و')
    .replaceAll('ئ', 'ي')
    .replaceAll('ة', 'ه')
    .replaceAll(RegExp(r'[^\u0621-\u064A0-9\s]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
}

List<dynamic> _searchAyahs(String text) {
final normalizedInput = _normalizeArabic(text);

if (normalizedInput.isEmpty) return [];

final words = normalizedInput
    .split(' ')
    .where((word) => word.length >= 2)
    .toSet()
    .toList();

if (words.isEmpty) return [];

final Map<int, dynamic> uniqueAyahs = {};

void searchLibrary(String value) {
if (value.trim().isEmpty) return;

try {
for (final ayah in quran.search(value)) {
uniqueAyahs[ayah.id as int] = ayah;
}
} catch (error) {
debugPrint('Arabic Quran search error: $error');
}
}

searchLibrary(text.trim());
searchLibrary(normalizedInput);

for (final word in words) {
searchLibrary(word);
}

final results = uniqueAyahs.values.where((ayah) {
final ayahText =
_normalizeArabic('${ayah.ayah} ${ayah.ayahText}');

return words.any((word) => ayahText.contains(word));
}).toList();

results.sort((a, b) {
final textA =
_normalizeArabic('${a.ayah} ${a.ayahText}');
final textB =
_normalizeArabic('${b.ayah} ${b.ayahText}');

final matchA = textA.contains(normalizedInput) ? 0 : 1;
final matchB = textB.contains(normalizedInput) ? 0 : 1;

if (matchA != matchB) {
return matchA.compareTo(matchB);
}

return (a.id as int).compareTo(b.id as int);
});

return results.take(_maxResults).toList();
}

@override
List<Widget> buildActions(BuildContext context) {
return [
if (query.isNotEmpty)
IconButton(
tooltip: 'مسح البحث',
icon: const Icon(Icons.clear),
onPressed: () {
query = '';
showSuggestions(context);
},
),
];
}

@override
Widget buildLeading(BuildContext context) {
return IconButton(
tooltip: 'رجوع',
icon: const Icon(Icons.arrow_back),
onPressed: () => close(context, null),
);
}

@override
Widget buildResults(BuildContext context) {
if (_normalizeArabic(query).isEmpty) {
return const Center(
child: Text('اكتب كلمة أو جزءًا من آية للبحث'),
);
}

final results = _searchAyahs(query);

if (results.isEmpty) {
return const Center(
child: Padding(
padding: EdgeInsets.all(24),
child: Text('لم يتم العثور على نتائج'),
),
);
}

return ListView.separated(
itemCount: results.length,
separatorBuilder: (_, __) => const Divider(height: 1),
itemBuilder: (context, index) {
final ayah = results[index];

return ListTile(
contentPadding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 8,
),
title: Text(
'${ayah.ayah}',
textDirection: TextDirection.rtl,
textAlign: TextAlign.right,
style: const TextStyle(
fontSize: 19,
height: 1.8,
),
),
subtitle: Padding(
padding: const EdgeInsets.only(top: 8),
child: Text(
'${ayah.surahNameAr} • الآية ${ayah.ayahNumber} • صفحة ${ayah.page}',
textDirection: TextDirection.rtl,
),
),
onTap: () => onTafsir(ayah),
trailing: PopupMenuButton<String>(
tooltip: 'خيارات الآية',
onSelected: (value) {
if (value == 'go') {
close(context, null);
quran.navigateToAyah(ayah);
onAyahSelected(ayah);
} else if (value == 'bookmark') {
onBookmark(ayah);
} else if (value == 'play') {
onPlay(ayah);
} else if (value == 'tafsir') {
onTafsir(ayah);
}
},
itemBuilder: (_) => const [
PopupMenuItem(
value: 'tafsir',
child: Text('عرض التفسير'),
),
PopupMenuItem(
value: 'go',
child: Text('الانتقال إلى الآية'),
),
PopupMenuItem(
value: 'bookmark',
child: Text('حفظ الآية'),
),
PopupMenuItem(
value: 'play',
child: Text('استماع للآية'),
),
],
child: const Icon(
Icons.more_vert,
color: quranGreen,
),
),
);
},
);
}

@override
Widget buildSuggestions(BuildContext context) {
if (query.trim().isEmpty) {
return const Center(
child: Padding(
padding: EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.menu_book,
size: 56,
color: quranGreen,
),
SizedBox(height: 12),
Text(
'ابحث في آيات القرآن الكريم',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
SizedBox(height: 8),
Text(
'يمكنك البحث بكلمة مثل الرحمن أو الحمد لله.',
textAlign: TextAlign.center,
),
],
),
),
);
}

return buildResults(context);
}
}
