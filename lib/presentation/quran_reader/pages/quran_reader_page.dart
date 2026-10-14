
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quran/flutter_quran.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitializing = true;
  bool _isPlaying = false;
  bool _isLoadingTafsir = false;

  int _currentPage = 1;
  int? _playingAyahId;
  double _volume = 1.0;

  List<Map<String, dynamic>> _bookmarks = [];

  String get _userId => _auth.currentUser?.uid ?? 'guest';

  String get _bookmarkKey => 'quran_reader_bookmarks_$_userId';

  String get _pageKey => 'quran_reader_last_page_$_userId';

  @override
  void initState() {
    super.initState();
    _initializeReader();
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;

      setState(() {
        _isPlaying = state.playing;
      });
    });
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

      _currentPage = page.clamp(1, 604);

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
        setState(() {
          _isInitializing = false;
        });
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

      if (cloudPage is int &&
          _storage.read(_pageKey) == null) {
        _currentPage = cloudPage.clamp(1, 604);
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
    _currentPage = page.clamp(1, 604);

    await _storage.write(_pageKey, _currentPage);

    final user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'quranReaderLastPage': _currentPage,
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      debugPrint('Quran page saving error: $error');
    }
  }

  void _onPageChanged(int pageIndex) {
    final page = (pageIndex + 1).clamp(1, 604);

    if (page == _currentPage) return;

    setState(() {
      _currentPage = page;
    });

    _savePage(page);
  }

  Future<void> _saveBookmarks() async {
    await _storage.write(_bookmarkKey, _bookmarks);

    final user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'quranReaderBookmarks': _bookmarks,
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      debugPrint('Quran bookmarks saving error: $error');
    }
  }

  Future<void> _addBookmark(dynamic ayah) async {
    final int ayahId = ayah.id as int;
    final int page = (ayah.page as int?) ?? _currentPage;

    final exists = _bookmarks.any(
          (bookmark) => bookmark['ayahId'] == ayahId,
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

  Future<void> _removeBookmark(Map<String, dynamic> bookmark) async {
    setState(() {
      _bookmarks.removeWhere(
            (item) => item['ayahId'] == bookmark['ayahId'],
      );
    });

    await _saveBookmarks();
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
                        Text('لا توجد علامات مرجعية حتى الآن'),
                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: _bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = _bookmarks[index];

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0x1F16845B),
                          child: Icon(
                            Icons.bookmark,
                            color: quranGreen,
                          ),
                        ),
                        title: Text(
                          '${bookmark['surahName'] ?? 'القرآن الكريم'}'
                              ' - الآية ${bookmark['ayahNumber'] ?? ''}',
                        ),
                        subtitle: Text(
                          'صفحة ${bookmark['page'] ?? 1}',
                        ),
                        onTap: () {
                          final page =
                              bookmark['page'] as int? ?? 1;

                          Navigator.pop(sheetContext);

                          _quran.navigateToPage(
                            page.clamp(1, 604),
                          );
                          _savePage(page);
                        },
                        trailing: IconButton(
                          tooltip: 'حذف العلامة',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            _removeBookmark(bookmark);
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
                              title: Text(
                                'الجزء ${index + 1}',
                              ),
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
                              title: Text(
                                'الحزب ${index + 1}',
                              ),
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
                            _savePage(page);
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

  Future<void> _playAyah(dynamic ayah) async {
    final int ayahId = ayah.id as int;

    try {
      if (_playingAyahId == ayahId && _isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      setState(() {
        _playingAyahId = ayahId;
      });

      final url =
          'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$ayahId.mp3';

      await _audioPlayer.setUrl(url);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play();
    } catch (error) {
      debugPrint('Ayah audio error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تشغيل صوت الآية. حاول مرة أخرى.'),
        ),
      );
    }
  }

  Future<void> _showTafsir(dynamic ayah) async {
    if (!mounted) return;

    setState(() {
      _isLoadingTafsir = true;
    });

    String tafsir = '';

    try {
      final int ayahId = ayah.id as int;

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse(
          'https://api.alquran.cloud/v1/ayah/$ayahId/ar.muyassar',
        ),
      );

      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode != 200) {
        throw HttpException('Tafsir request failed');
      }

      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>?;

      tafsir = data?['text'] as String? ?? '';
    } catch (error) {
      debugPrint('Tafsir loading error: $error');
      tafsir = 'تعذر تحميل التفسير. تحقق من اتصال الإنترنت وحاول مرة أخرى.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTafsir = false;
        });
      }
    }

    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفسير الآية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: quranGreen,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'التفسير الميسّر',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: _isLoadingTafsir
                ? const Center(
              child: CircularProgressIndicator(
                color: quranGreen,
              ),
            )
                : Text(
              tafsir,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 17,
                height: 1.8,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'إغلاق',
                style: TextStyle(color: quranGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAyahActions(dynamic ayah) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${ayah.surahNameAr} - الآية ${ayah.ayahNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.play_circle_outline,
                    color: quranGreen,
                  ),
                  title: const Text('تشغيل صوت الآية'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _playAyah(ayah);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.menu_book_outlined,
                    color: quranGreen,
                  ),
                  title: const Text('تفسير الآية'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showTafsir(ayah);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.bookmark_add_outlined,
                    color: quranGreen,
                  ),
                  title: const Text('إضافة إلى العلامات المرجعية'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _addBookmark(ayah);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSearch() {
    showSearch<void>(
      context: context,
      delegate: QuranSearchDelegate(
        _quran,
        onAyahSelected: (ayah) {
          _quran.navigateToAyah(ayah);
          _savePage(ayah.page as int? ?? _currentPage);
        },
        onAyahActions: _showAyahActions,
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
                final value = int.tryParse(controller.text.trim());

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
    await _audioPlayer.pause();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const ChooseQuranModePage(),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'البحث في القرآن',
            onPressed: _openSearch,
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
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book,
                  color: quranGreen,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'مصحف المدينة',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _openPageDialog,
                  icon: const Icon(
                    Icons.find_in_page_outlined,
                    size: 18,
                  ),
                  label: Text('صفحة $_currentPage'),
                  style: TextButton.styleFrom(
                    foregroundColor: quranGreen,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPressStart: (details) {
                // Long-press actions are available from search results.
                // The Quran package owns the page rendering and gestures.
              },
              child: FlutterQuranScreen(
                useDefaultAppBar: false,
                onPageChanged: _onPageChanged,
              ),
            ),
          ),
          _AudioControlBar(
            player: _audioPlayer,
            isPlaying: _isPlaying,
            volume: _volume,
            onVolumeChanged: (value) {
              setState(() {
                _volume = value;
              });
              _audioPlayer.setVolume(value);
            },
            onPlayPause: () async {
              if (_audioPlayer.playerState.processingState ==
                  ProcessingState.idle) {
                return;
              }

              if (_isPlaying) {
                await _audioPlayer.pause();
              } else {
                await _audioPlayer.play();
              }
            },
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
              setState(() {
                _page = value.round();
              });
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

class _AudioControlBar extends StatelessWidget {
  const _AudioControlBar({
    required this.player,
    required this.isPlaying,
    required this.volume,
    required this.onVolumeChanged,
    required this.onPlayPause,
  });

  final AudioPlayer player;
  final bool isPlaying;
  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.headphones,
                color: quranGreen,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'استماع للآيات',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: isPlaying ? 'إيقاف مؤقت' : 'استئناف',
                onPressed: onPlayPause,
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: quranGreen,
                  size: 34,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.volume_down,
                size: 20,
              ),
              Expanded(
                child: Slider(
                  value: volume,
                  min: 0,
                  max: 1,
                  activeColor: quranGreen,
                  onChanged: onVolumeChanged,
                ),
              ),
              const Icon(
                Icons.volume_up,
                size: 20,
              ),
            ],
          ),
          StreamBuilder<Duration?>(
            stream: player.durationStream,
            builder: (context, durationSnapshot) {
              final duration =
                  durationSnapshot.data ?? Duration.zero;

              return StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, positionSnapshot) {
                  final position =
                      positionSnapshot.data ?? Duration.zero;

                  final maxDuration =
                  duration.inMilliseconds.toDouble();

                  final currentPosition =
                  position.inMilliseconds.toDouble();

                  return Row(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(fontSize: 11),
                      ),
                      Expanded(
                        child: Slider(
                          value: maxDuration <= 0
                              ? 0
                              : currentPosition.clamp(
                            0,
                            maxDuration,
                          ),
                          min: 0,
                          max: maxDuration <= 0 ? 1 : maxDuration,
                          activeColor: quranGreen,
                          onChanged: maxDuration <= 0
                              ? null
                              : (value) {
                            player.seek(
                              Duration(
                                milliseconds: value.round(),
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class QuranSearchDelegate extends SearchDelegate<void> {
  QuranSearchDelegate(
      this.quran, {
        required this.onAyahSelected,
        required this.onAyahActions,
      });

  final FlutterQuran quran;
  final ValueChanged<dynamic> onAyahSelected;
  final ValueChanged<dynamic> onAyahActions;

  static const int _maxResults = 100;

  @override
  String get searchFieldLabel => 'ابحث بكلمات من الآية';

  @override
  TextDirection get queryTextDirection => TextDirection.rtl;

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
        .replaceAll(
      RegExp(r'[^\u0621-\u064A0-9\s]'),
      ' ',
    )
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
        final results = quran.search(value);

        for (final ayah in results) {
          final id = ayah.id;

          if (id is int) {
            uniqueAyahs[id] = ayah;
          }
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
      final ayahText = _normalizeArabic(
        '${ayah.ayah} ${ayah.ayahText}',
      );

      return words.any(
            (word) => ayahText.contains(word),
      );
    }).toList();

    results.sort((a, b) {
      final textA = _normalizeArabic(
        '${a.ayah} ${a.ayahText}',
      );

      final textB = _normalizeArabic(
        '${b.ayah} ${b.ayahText}',
      );

      final matchA =
      textA.contains(normalizedInput) ? 0 : 1;

      final matchB =
      textB.contains(normalizedInput) ? 0 : 1;

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
    final normalizedQuery = _normalizeArabic(query);

    if (normalizedQuery.isEmpty) {
      return const Center(
        child: Text('اكتب كلمة أو جزءًا من آية للبحث'),
      );
    }

    final results = _searchAyahs(query);

    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 52,
                color: quranGreen,
              ),
              SizedBox(height: 12),
              Text(
                'لم يتم العثور على نتائج',
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 8),
              Text(
                'جرّب كلمة أخرى أو اكتب جزءًا أقصر من الآية.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: const Color(0x1F16845B),
            child: Text(
              '${ayah.ayahNumber}',
              style: const TextStyle(
                color: quranGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${ayah.surahNameAr} • صفحة ${ayah.page}',
                    textDirection: TextDirection.rtl,
                  ),
                ),
                IconButton(
                  tooltip: 'خيارات الآية',
                  onPressed: () => onAyahActions(ayah),
                  icon: const Icon(
                    Icons.more_vert,
                    color: quranGreen,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            close(context, null);
            quran.navigateToAyah(ayah);
            onAyahSelected(ayah);
          },
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
                  fontSize: 18,                  fontWeight: FontWeight.bold,

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
