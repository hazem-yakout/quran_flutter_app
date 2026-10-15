
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HadithPage extends StatelessWidget {
  const HadithPage({super.key});

  static const List<Map<String, String>> hadiths = [
    {
      'text': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى.',
      'narrator': 'عمر بن الخطاب رضي الله عنه',
      'source': 'صحيح البخاري، حديث 1؛ وصحيح مسلم، حديث 1907',
      'category': 'الإخلاص والنية',
    },
    {
      'text': 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ.',
      'narrator': 'أبو هريرة رضي الله عنه',
      'source': 'صحيح البخاري، حديث 6018؛ وصحيح مسلم، حديث 47',
      'category': 'حسن الكلام',
    },
    {
      'text': 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ.',
      'narrator': 'أنس بن مالك رضي الله عنه',
      'source': 'صحيح البخاري، حديث 13؛ وصحيح مسلم، حديث 45',
      'category': 'الأخلاق',
    },
    {
      'text': 'الطُّهُورُ شَطْرُ الْإِيمَانِ.',
      'narrator': 'أبو مالك الأشعري رضي الله عنه',
      'source': 'صحيح مسلم، حديث 223',
      'category': 'الطهارة',
    },
    {
      'text': 'مَنْ لَا يَرْحَمُ لَا يُرْحَمُ.',
      'narrator': 'جرير بن عبد الله رضي الله عنه',
      'source': 'صحيح البخاري، حديث 6013؛ وصحيح مسلم، حديث 2319',
      'category': 'الرحمة',
    },
    {
      'text': 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ.',
      'narrator': 'عبد الله بن عمرو رضي الله عنهما',
      'source': 'صحيح البخاري، حديث 10؛ وصحيح مسلم، حديث 40',
      'category': 'حسن الخلق',
    },
    {
      'text': 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا، سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ.',
      'narrator': 'أبو هريرة رضي الله عنه',
      'source': 'صحيح مسلم، حديث 2699',
      'category': 'طلب العلم',
    },
    {
      'text': 'الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ.',
      'narrator': 'أبو هريرة رضي الله عنه',
      'source': 'صحيح البخاري، حديث 2989؛ وصحيح مسلم، حديث 1009',
      'category': 'الصدقة',
    },
    {
      'text': 'يَسِّرُوا وَلَا تُعَسِّرُوا، وَبَشِّرُوا وَلَا تُنَفِّرُوا.',
      'narrator': 'أنس بن مالك رضي الله عنه',
      'source': 'صحيح البخاري، حديث 69؛ وصحيح مسلم، حديث 1734',
      'category': 'التيسير',
    },
    {
      'text': 'إِنَّ اللَّهَ جَمِيلٌ يُحِبُّ الْجَمَالَ.',
      'narrator': 'عبد الله بن مسعود رضي الله عنه',
      'source': 'صحيح مسلم، حديث 91',
      'category': 'الجمال والتواضع',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? Colors.greenAccent : Colors.green.shade800;

    final categories = hadiths
        .map((hadith) => hadith['category']!)
        .toSet()
        .toList();

    return DefaultTabController(
      length: categories.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأحاديث النبوية'),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: primary,
            labelColor: primary,
            tabs: [
              const Tab(text: 'الكل'),
              ...categories.map((category) => Tab(text: category)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, hadiths, primary),
            ...categories.map(
                  (category) => _buildList(
                context,
                hadiths
                    .where((hadith) => hadith['category'] == category)
                    .toList(),
                primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
      BuildContext context,
      List<Map<String, String>> items,
      Color primary,
      ) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final hadith = items[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: primary.withValues(alpha: 0.10),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hadith['category']!,
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'نسخ الحديث',
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () async {
                        final text = '${hadith['text']}\n'
                            'الراوي: ${hadith['narrator']}\n'
                            'المصدر: ${hadith['source']}';

                        await Clipboard.setData(
                          ClipboardData(text: text),
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ الحديث'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '« ${hadith['text']} »',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        height: 2,
                        fontSize: 21,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'الراوي: ${hadith['narrator']}',
                      textDirection: TextDirection.rtl,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'المصدر: ${hadith['source']}',
                      textDirection: TextDirection.rtl,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
