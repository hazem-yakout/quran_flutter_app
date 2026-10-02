import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final GetStorage storage = GetStorage();

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

  List<int> getFavorites() {
    final List<dynamic> data =
        storage.read('favorites') ?? [];

    return data
        .map((e) => int.parse(e.toString()))
        .toList();
  }

  List<int> getRecentlyPlayed() {
    final List<dynamic> data =
        storage.read('recentlyPlayed') ?? [];

    return data
        .map((e) => int.parse(e.toString()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = getFavorites();
    final recentlyPlayed = getRecentlyPlayed();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),

      body: ListView(
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

          const SizedBox(height: 35),

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
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

          ...favorites.map(
                (surahNumber) {
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  title: Text(
                    surahNames[surahNumber - 1],
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  trailing: Text(
                    '$surahNumber',
                  ),
                ),
              );
            },
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
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

          ...recentlyPlayed.map(
                (surahNumber) {
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.history,
                  ),
                  title: Text(
                    surahNames[surahNumber - 1],
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  trailing: Text(
                    '$surahNumber',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}