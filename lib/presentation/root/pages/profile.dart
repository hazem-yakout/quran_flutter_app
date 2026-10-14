
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GetStorage storage = GetStorage();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  List<int> favorites = [];
  List<int> recentlyPlayed = [];

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  final List<String> surahNames = [
    'الفاتحة',
    'البقرة',
    'آل عمران',
    'النساء',
    'المائدة',
    'الأنعام',
    'الأعراف',
    'الأنفال',
    'التوبة',
    'يونس',
    'هود',
    'يوسف',
    'الرعد',
    'إبراهيم',
    'الحجر',
    'النحل',
    'الإسراء',
    'الكهف',
    'مريم',
    'طه',
    'الأنبياء',
    'الحج',
    'المؤمنون',
    'النور',
    'الفرقان',
    'الشعراء',
    'النمل',
    'القصص',
    'العنكبوت',
    'الروم',
    'لقمان',
    'السجدة',
    'الأحزاب',
    'سبأ',
    'فاطر',
    'يس',
    'الصافات',
    'ص',
    'الزمر',
    'غافر',
    'فصلت',
    'الشورى',
    'الزخرف',
    'الدخان',
    'الجاثية',
    'الأحقاف',
    'محمد',
    'الفتح',
    'الحجرات',
    'ق',
    'الذاريات',
    'الطور',
    'النجم',
    'القمر',
    'الرحمن',
    'الواقعة',
    'الحديد',
    'المجادلة',
    'الحشر',
    'الممتحنة',
    'الصف',
    'الجمعة',
    'المنافقون',
    'التغابن',
    'الطلاق',
    'التحريم',
    'الملك',
    'القلم',
    'الحاقة',
    'المعارج',
    'نوح',
    'الجن',
    'المزمل',
    'المدثر',
    'القيامة',
    'الإنسان',
    'المرسلات',
    'النبأ',
    'النازعات',
    'عبس',
    'التكوير',
    'الانفطار',
    'المطففين',
    'الانشقاق',
    'البروج',
    'الطارق',
    'الأعلى',
    'الغاشية',
    'الفجر',
    'البلد',
    'الشمس',
    'الليل',
    'الضحى',
    'الشرح',
    'التين',
    'العلق',
    'القدر',
    'البينة',
    'الزلزلة',
    'العاديات',
    'القارعة',
    'التكاثر',
    'العصر',
    'الهمزة',
    'الفيل',
    'قريش',
    'الماعون',
    'الكوثر',
    'الكافرون',
    'النصر',
    'المسد',
    'الإخلاص',
    'الفلق',
    'الناس',
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // =========================
  // LOAD DATA
  // =========================

  Future<void> loadData() async {
    final uid = userId;

    if (uid == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      return;
    }

    final favoritesKey = '${uid}_favorites';
    final recentlyPlayedKey = '${uid}_recentlyPlayed';

    // Load local data first.
    List<int> loadedFavorites =
    _toIntList(storage.read<List>(favoritesKey));

    List<int> loadedRecentlyPlayed =
    _toIntList(storage.read<List>(recentlyPlayedKey));

    if (mounted) {
      setState(() {
        favorites = loadedFavorites;
        recentlyPlayed = loadedRecentlyPlayed;
        isLoading = true;
      });
    }

    try {
      final doc = await firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data() ?? {};

        if (data['favorites'] is List) {
          loadedFavorites = _toIntList(data['favorites'] as List);
        }

        if (data['recentlyPlayed'] is List) {
          loadedRecentlyPlayed =
              _toIntList(data['recentlyPlayed'] as List);
        }

        // Cache cloud data locally for this user.
        await storage.write(favoritesKey, loadedFavorites);
        await storage.write(recentlyPlayedKey, loadedRecentlyPlayed);
      }

      if (!mounted) return;

      setState(() {
        favorites = loadedFavorites;
        recentlyPlayed = loadedRecentlyPlayed;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Profile Firestore error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر تحميل البيانات من السحابة. يتم عرض البيانات المحلية إن وجدت.',
          ),
        ),
      );
    }
  }

  List<int> _toIntList(List<dynamic>? data) {
    if (data == null) return [];

    return data
        .map((e) => int.tryParse(e.toString()))
        .whereType<int>()
        .where((number) => number >= 1 && number <= 114)
        .toList();
  }

  // =========================
  // SURAH CARD
  // =========================

  Widget buildSurahCard(
      int surahNumber, {
        required bool isFavorite,
      }) {
    if (surahNumber < 1 || surahNumber > surahNames.length) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          isFavorite ? Icons.favorite : Icons.history,
          color: isFavorite ? Colors.red : null,
        ),
        title: Text(
          surahNames[surahNumber - 1],
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 18),
        ),
        trailing: Text('$surahNumber'),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadData,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(
                  Icons.person,
                  size: 55,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Center(
              child: Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (user?.email != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  user!.email!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 25),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              const Text(
                '❤️ Favorites',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (favorites.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'No favorite surahs yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...favorites.map(
                      (number) => buildSurahCard(
                    number,
                    isFavorite: true,
                  ),
                ),

              const SizedBox(height: 30),

              const Text(
                '🕘 Recently Played',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (recentlyPlayed.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'No recently played surahs',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...recentlyPlayed.map(
                      (number) => buildSurahCard(
                    number,
                    isFavorite: false,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
