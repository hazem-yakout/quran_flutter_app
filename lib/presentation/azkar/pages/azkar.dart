
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AzkarPage extends StatefulWidget {
  final bool initialEvening;

  const AzkarPage({
    super.key,
    this.initialEvening = false,
  });

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> {
  late bool isEvening;
  final Map<String, int> progress = {};

  static const List<Map<String, dynamic>> morningAzkar = [
    {
      'text': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ.',
      'count': 1,
      'title': 'ذكر الصباح',
    },
    {
      'text': 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ.',
      'count': 1,
      'title': 'ذكر الصباح',
    },
    {
      'text': 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا.',
      'count': 3,
      'title': 'رضيت بالله ربًا',
    },
    {
      'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.',
      'count': 100,
      'title': 'التسبيح',
    },
    {
      'text': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ.',
      'count': 1,
      'title': 'العفو والعافية',
    },
    {
      'text': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
      'count': 3,
      'title': 'الاستعاذة',
    },
    {
      'text': 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ.',
      'count': 3,
      'title': 'سورة الإخلاص',
    },
    {
      'text': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ.',
      'count': 3,
      'title': 'سورة الفلق',
    },
    {
      'text': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ.',
      'count': 3,
      'title': 'سورة الناس',
    },
    {
      'text': 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ.',
      'count': 10,
      'title': 'الصلاة على النبي ﷺ',
    },
  ];

  static const List<Map<String, dynamic>> eveningAzkar = [
    {
      'text': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ.',
      'count': 1,
      'title': 'ذكر المساء',
    },
    {
      'text': 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ.',
      'count': 1,
      'title': 'ذكر المساء',
    },
    {
      'text': 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا.',
      'count': 3,
      'title': 'رضيت بالله ربًا',
    },
    {
      'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.',
      'count': 100,
      'title': 'التسبيح',
    },
    {
      'text': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
      'count': 3,
      'title': 'الاستعاذة',
    },
    {
      'text': 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ.',
      'count': 3,
      'title': 'سورة الإخلاص',
    },
    {
      'text': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ.',
      'count': 3,
      'title': 'سورة الفلق',
    },
    {
      'text': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ.',
      'count': 3,
      'title': 'سورة الناس',
    },
    {
      'text': 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ.',
      'count': 10,
      'title': 'الصلاة على النبي ﷺ',
    },
  ];

  @override
  void initState() {
    super.initState();
    isEvening = widget.initialEvening;
    _loadProgress();
  }

  String _storageKey(int index) =>
      'azkar_${isEvening ? 'evening' : 'morning'}_$index';

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final azkar = isEvening ? eveningAzkar : morningAzkar;

    if (!mounted) return;

    setState(() {
      for (int i = 0; i < azkar.length; i++) {
        progress[_storageKey(i)] = prefs.getInt(_storageKey(i)) ?? 0;
      }
    });
  }

  Future<void> _increment(int index, int maxCount) async {
    final key = _storageKey(index);
    final current = progress[key] ?? 0;

    if (current >= maxCount) return;

    setState(() {
      progress[key] = current + 1;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, current + 1);
  }

  Future<void> _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final azkar = isEvening ? eveningAzkar : morningAzkar;

    setState(() {
      for (int i = 0; i < azkar.length; i++) {
        progress[_storageKey(i)] = 0;
      }
    });

    for (int i = 0; i < azkar.length; i++) {
      await prefs.setInt(_storageKey(i), 0);
    }
  }

  Future<void> _changeMode(bool evening) async {
    if (isEvening == evening) return;

    setState(() {
      isEvening = evening;
      progress.clear();
    });

    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? Colors.greenAccent : Colors.green.shade800;
    final azkar = isEvening ? eveningAzkar : morningAzkar;

    final completed = List.generate(azkar.length, (i) {
      return (progress[_storageKey(i)] ?? 0) >=
          (azkar[i]['count'] as int);
    }).where((done) => done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'إعادة العدادات',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetProgress,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _modeButton(
                      title: '☀️ أذكار الصباح',
                      selected: !isEvening,
                      primary: primary,
                      onTap: () => _changeMode(false),
                    ),
                  ),
                  Expanded(
                    child: _modeButton(
                      title: '🌙 أذكار المساء',
                      selected: isEvening,
                      primary: primary,
                      onTap: () => _changeMode(true),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Text(
                  'الأذكار المكتملة',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '$completed / ${azkar.length}',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: azkar.length,
              itemBuilder: (context, index) {
                final item = azkar[index];
                final target = item['count'] as int;
                final key = _storageKey(index);
                final count = progress[key] ?? 0;
                final done = count >= target;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: done
                          ? primary.withValues(alpha: 0.5)
                          : theme.dividerColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (done)
                              Icon(
                                Icons.check_circle_rounded,
                                color: primary,
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item['text'] as String,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: theme.textTheme.titleMedium?.copyWith(
                            height: 2,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text(
                              'التكرار: $target',
                              style: theme.textTheme.bodySmall,
                            ),
                            const Spacer(),
                            Text(
                              '$count / $target',
                              style: TextStyle(
                                color: done
                                    ? primary
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: count / target,
                            minHeight: 5,
                            color: primary,
                            backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: done
                              ? null
                              : () => _increment(index, target),
                          icon: Icon(
                            done
                                ? Icons.check_rounded
                                : Icons.touch_app_rounded,
                          ),
                          label: Text(
                            done ? 'تم الذكر' : 'اضغط للتسبيح',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: isDark
                                ? Colors.black
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required String title,
    required bool selected,
    required Color primary,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: selected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 13,
              horizontal: 4,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white)
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
