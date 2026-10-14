
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';

import 'package:quran/presentation/mode/pages/choose_quran_mode.dart';
import 'package:quran/presentation/root/pages/profile.dart';
import 'package:quran/presentation/choose_reciter/pages/choose_reciter.dart';
import 'package:quran/presentation/quran_reader/pages/quran_reader_page.dart';

class Root extends StatefulWidget {
  final String reciterName;
  final String reciterServer;

  const Root({
    super.key,
    required this.reciterName,
    required this.reciterServer,
  });

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final GetStorage storage = GetStorage();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription<PlayerState>? playerSubscription;

  double volume = 1.0;
  int currentSurah = 1;
  bool autoPlay = false;

  Set<int> favorites = {};
  List<int> recentlyPlayed = [];

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  final List<String> surahNames = [
    'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة',
    'الأنعام', 'الأعراف', 'الأنفال', 'التوبة', 'يونس',
    'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
    'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه',
    'الأنبياء', 'الحج', 'المؤمنون', 'النور', 'الفرقان',
    'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
    'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر',
    'يس', 'الصافات', 'ص', 'الزمر', 'غافر',
    'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية',
    'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق',
    'الذاريات', 'الطور', 'النجم', 'القمر', 'الرحمن',
    'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
    'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق',
    'التحريم', 'الملك', 'القلم', 'الحاقة', 'المعارج',
    'نوح', 'الجن', 'المزمل', 'المدثر', 'القيامة',
    'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس',
    'التكوير', 'الانفطار', 'المطففين', 'الانشقاق', 'البروج',
    'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد',
    'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين',
    'العلق', 'القدر', 'البينة', 'الزلزلة', 'العاديات',
    'القارعة', 'التكاثر', 'العصر', 'الهمزة', 'الفيل',
    'قريش', 'الماعون', 'الكوثر', 'الكافرون', 'النصر',
    'المسد', 'الإخلاص', 'الفلق', 'الناس',
  ];

  @override
  void initState() {
    super.initState();

    loadData();
    audioPlayer.setVolume(volume);

    playerSubscription = audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNextSurah();
      }
    });
  }

  // =========================
  // LOAD USER DATA
  // =========================

  Future<void> loadData() async {
    final uid = userId;

    if (uid == null) {
      debugPrint('No authenticated user.');
      return;
    }

    final favoritesKey = '${uid}_favorites';
    final recentKey = '${uid}_recentlyPlayed';

    try {
      final List<dynamic> localFavorites =
          storage.read<List>(favoritesKey) ?? [];

      final List<dynamic> localRecent =
          storage.read<List>(recentKey) ?? [];

      Set<int> loadedFavorites = localFavorites
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toSet();

      List<int> loadedRecent = localRecent
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();

      if (mounted) {
        setState(() {
          favorites = loadedFavorites;
          recentlyPlayed = loadedRecent;
        });
      }

      final docRef = firestore.collection('users').doc(uid);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() ?? {};

        if (data['favorites'] is List) {
          loadedFavorites = (data['favorites'] as List)
              .map((e) => int.tryParse(e.toString()))
              .whereType<int>()
              .toSet();
        }

        if (data['recentlyPlayed'] is List) {
          loadedRecent = (data['recentlyPlayed'] as List)
              .map((e) => int.tryParse(e.toString()))
              .whereType<int>()
              .toList();
        }
      }

      await storage.write(favoritesKey, loadedFavorites.toList());
      await storage.write(recentKey, loadedRecent);

      await docRef.set({
        'favorites': loadedFavorites.toList(),
        'recentlyPlayed': loadedRecent,
        'reciterName': widget.reciterName,
        'reciterServer': widget.reciterServer,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        favorites = loadedFavorites;
        recentlyPlayed = loadedRecent;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // =========================
  // SAVE USER DATA
  // =========================

  Future<void> saveUserData() async {
    final uid = userId;

    if (uid == null) {
      debugPrint('Cannot save data: no authenticated user.');
      return;
    }

    final favoriteList = favorites.toList();
    final recentList = List<int>.from(recentlyPlayed);

    await storage.write('${uid}_favorites', favoriteList);
    await storage.write('${uid}_recentlyPlayed', recentList);

    try {
      await firestore.collection('users').doc(uid).set({
        'favorites': favoriteList,
        'recentlyPlayed': recentList,
        'reciterName': widget.reciterName,
        'reciterServer': widget.reciterServer,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing user data: $e');
    }
  }

  // =========================
  // BACK TO MODE SELECTION
  // =========================

  void goToChooseQuranMode() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ChooseQuranModePage(),
      ),
    );
  }

  // =========================
  // CHANGE RECITER
  // =========================

  void goToChooseReciter() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ChooseReciterPage(),
      ),
    );
  }

  // =========================
  // PLAY SURAH
  // =========================

  Future<void> playSurah(int surahNumber) async {
    if (surahNumber < 1 || surahNumber > 114) return;

    try {
      setState(() {
        currentSurah = surahNumber;
      });

      recentlyPlayed.remove(surahNumber);
      recentlyPlayed.insert(0, surahNumber);

      if (recentlyPlayed.length > 10) {
        recentlyPlayed.removeLast();
      }

      await saveUserData();

      final number = surahNumber.toString().padLeft(3, '0');

      await audioPlayer.setUrl(
        '${widget.reciterServer}$number.mp3',
      );

      await audioPlayer.setVolume(volume);
      await audioPlayer.play();
    } catch (e) {
      debugPrint('Audio Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في تشغيل السورة'),
        ),
      );
    }
  }

  // =========================
  // PLAY / PAUSE
  // =========================

  Future<void> togglePlayPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      if (audioPlayer.audioSource == null) {
        await playSurah(currentSurah);
      } else {
        await audioPlayer.play();
      }
    }
  }

  // =========================
  // STOP
  // =========================

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    await audioPlayer.seek(Duration.zero);
  }

  // =========================
  // NEXT SURAH
  // =========================

  Future<void> playNextSurah() async {
    if (!autoPlay) return;

    if (currentSurah >= 114) {
      if (mounted) {
        setState(() {
          autoPlay = false;
        });
      }
      return;
    }

    await playSurah(currentSurah + 1);
  }

  // =========================
  // AUTO PLAY
  // =========================

  void toggleAutoPlay() {
    setState(() {
      autoPlay = !autoPlay;
    });
  }

  // =========================
  // VOLUME
  // =========================

  Future<void> increaseVolume() async {
    setState(() {
      volume = (volume + 0.1).clamp(0.0, 1.0).toDouble();
    });

    await audioPlayer.setVolume(volume);
  }

  Future<void> decreaseVolume() async {
    setState(() {
      volume = (volume - 0.1).clamp(0.0, 1.0).toDouble();
    });

    await audioPlayer.setVolume(volume);
  }

  // =========================
  // FAVORITES
  // =========================

  Future<void> toggleFavorite(int surahNumber) async {
    setState(() {
      if (favorites.contains(surahNumber)) {
        favorites.remove(surahNumber);
      } else {
        favorites.add(surahNumber);
      }
    });

    await saveUserData();
  }

  // =========================
  // FORMAT TIME
  // =========================

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    playerSubscription?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final isFavorite = favorites.contains(currentSurah);

    return Scaffold(
      extendBodyBehindAppBar: true,

      // Back arrow replaces the swap button.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: goToChooseQuranMode,
          tooltip: 'الرجوع لاختيار الوضع',
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 28,
          ),
        ),
        title: const Text(
          'Quran',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuranReaderPage(),
                ),
              );
            },
            tooltip: 'قراءة القرآن',
            icon: const Icon(
              Icons.menu_book_rounded,
              size: 27,
            ),
          ),
          IconButton(
            onPressed: goToChooseReciter,
            tooltip: 'تغيير القارئ',
            icon: const Icon(
              Icons.record_voice_over_outlined,
              size: 27,
            ),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(),
                ),
              );

              await loadData();
            },
            tooltip: 'الملف الشخصي',
            icon: const Icon(
              Icons.person_outline,
              size: 29,
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/ka3ba.webp',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                isDark ? 0.38 : 0.25,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 5),

                // =========================
                // PLAYER
                // =========================

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.55)
                        : Colors.white.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  surahNames[currentSurah - 1],
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.reciterName,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // SEEK SLIDER

                      StreamBuilder<Duration?>(
                        stream: audioPlayer.durationStream,
                        builder: (context, durationSnapshot) {
                          final duration =
                              durationSnapshot.data ?? Duration.zero;

                          return StreamBuilder<Duration>(
                            stream: audioPlayer.positionStream,
                            builder: (context, positionSnapshot) {
                              Duration position =
                                  positionSnapshot.data ?? Duration.zero;

                              if (position > duration) {
                                position = duration;
                              }

                              final double maxValue =
                              duration.inMilliseconds > 0
                                  ? duration.inMilliseconds.toDouble()
                                  : 1.0;

                              final double value = position
                                  .inMilliseconds
                                  .toDouble()
                                  .clamp(0.0, maxValue)
                                  .toDouble();

                              return Column(
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 4,
                                      activeTrackColor: Colors.green,
                                      inactiveTrackColor: isDark
                                          ? Colors.white24
                                          : Colors.black12,
                                      thumbColor: Colors.green,
                                      thumbShape:
                                      const RoundSliderThumbShape(
                                        enabledThumbRadius: 7,
                                      ),
                                    ),
                                    child: Slider(
                                      value: value,
                                      min: 0,
                                      max: maxValue,
                                      onChanged:
                                      duration.inMilliseconds == 0
                                          ? null
                                          : (newValue) async {
                                        await audioPlayer.seek(
                                          Duration(
                                            milliseconds:
                                            newValue.toInt(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDuration(position),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        formatDuration(duration),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 2),

                      // PLAYER CONTROLS

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                onPressed: decreaseVolume,
                                icon: const Icon(
                                  Icons.volume_down_rounded,
                                  size: 30,
                                ),
                              ),
                              Text(
                                'DOWN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 8),

                          Column(
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: stopAudio,
                                  icon: const Icon(
                                    Icons.stop_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'RESET',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          Column(
                            children: [
                              StreamBuilder<PlayerState>(
                                stream: audioPlayer.playerStateStream,
                                builder: (context, snapshot) {
                                  final playing =
                                      snapshot.data?.playing ?? false;

                                  return Container(
                                    width: 62,
                                    height: 62,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: togglePlayPause,
                                      icon: Icon(
                                        playing
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 38,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'PLAY',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          Column(
                            children: [
                              IconButton(
                                onPressed: increaseVolume,
                                icon: const Icon(
                                  Icons.volume_up_rounded,
                                  size: 30,
                                ),
                              ),
                              Text(
                                'UP',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 5),

                          IconButton(
                            onPressed: () {
                              toggleFavorite(currentSurah);
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 29,
                              color: isFavorite
                                  ? Colors.red
                                  : isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Volume ${(volume * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // AUTO PLAY

                      GestureDetector(
                        onTap: toggleAutoPlay,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: autoPlay
                                ? Colors.green
                                : isDark
                                ? Colors.white12
                                : Colors.black12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.playlist_play_rounded,
                                size: 20,
                                color: autoPlay
                                    ? Colors.white
                                    : isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                autoPlay
                                    ? 'Auto Play ON'
                                    : 'Auto Play OFF',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: autoPlay
                                      ? Colors.white
                                      : isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // SURAH HEADER

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Surahs',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 5,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '114 Surahs',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // SURAH LIST

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: surahNames.length,
                    itemBuilder: (context, index) {
                      final surahNumber = index + 1;
                      final isFav = favorites.contains(surahNumber);
                      final isCurrent = currentSurah == surahNumber;

                      return Container(
                        height: 55,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.green.withOpacity(0.78)
                              : isDark
                              ? Colors.black.withOpacity(0.40)
                              : Colors.white.withOpacity(0.70),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          leading: CircleAvatar(
                            radius: 17,
                            backgroundColor: isCurrent
                                ? Colors.green
                                : isDark
                                ? Colors.white12
                                : Colors.black12,
                            child: Text(
                              '$surahNumber',
                              style: TextStyle(
                                fontSize: 12,
                                color: isCurrent
                                    ? Colors.white
                                    : isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          title: Text(
                            surahNames[index],
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isCurrent
                                  ? Colors.white
                                  : isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          trailing: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              toggleFavorite(surahNumber);
                            },
                            icon: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 22,
                              color: isFav
                                  ? Colors.red
                                  : isDark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          onTap: () {
                            playSurah(surahNumber);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
