
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DuasPage extends StatelessWidget {
  const DuasPage({super.key});

  static const List<Map<String, String>> duas = [
    {
      'category': 'دعاء الاستيقاظ',
      'title': 'عند الاستيقاظ من النوم',
      'text': 'الحمد لله الذي أحيانا بعدما أماتنا وإليه النشور.',
    },
    {
      'category': 'دعاء الطعام',
      'title': 'قبل الطعام',
      'text': 'بسم الله.',
    },
    {
      'category': 'دعاء الطعام',
      'title': 'بعد الطعام',
      'text': 'الحمد لله الذي أطعمني هذا ورزقنيه من غير حول مني ولا قوة.',
    },
    {
      'category': 'دعاء الخروج',
      'title': 'عند الخروج من المنزل',
      'text': 'بسم الله، توكلت على الله، ولا حول ولا قوة إلا بالله.',
    },
    {
      'category': 'دعاء الدخول',
      'title': 'عند دخول المنزل',
      'text': 'بسم الله ولجنا، وبسم الله خرجنا، وعلى ربنا توكلنا.',
    },
    {
      'category': 'دعاء السفر',
      'title': 'دعاء السفر',
      'text': 'سبحان الذي سخر لنا هذا وما كنا له مقرنين وإنا إلى ربنا لمنقلبون.',
    },
    {
      'category': 'دعاء الكرب',
      'title': 'عند الهم والكرب',
      'text': 'لا إله إلا أنت سبحانك إني كنت من الظالمين.',
    },
    {
      'category': 'دعاء العلم',
      'title': 'لطلب العلم',
      'text': 'رب زدني علما.',
    },
    {
      'category': 'دعاء الوالدين',
      'title': 'للوالدين',
      'text': 'رب ارحمهما كما ربياني صغيرا.',
    },
    {
      'category': 'دعاء المغفرة',
      'title': 'طلب المغفرة',
      'text': 'ربنا ظلمنا أنفسنا وإن لم تغفر لنا وترحمنا لنكونن من الخاسرين.',
    },
    {
      'category': 'دعاء الدنيا والآخرة',
      'title': 'خير الدنيا والآخرة',
      'text': 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار.',
    },
    {
      'category': 'دعاء التيسير',
      'title': 'لتيسير الأمور',
      'text': 'رب اشرح لي صدري ويسر لي أمري.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? Colors.greenAccent : Colors.green.shade800;

    final categories = duas
        .map((dua) => dua['category']!)
        .toSet()
        .toList();

    return DefaultTabController(
      length: categories.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأدعية اليومية'),
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
            _buildDuaList(context, duas, primary),
            ...categories.map(
                  (category) => _buildDuaList(
                context,
                duas
                    .where((dua) => dua['category'] == category)
                    .toList(),
                primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuaList(
      BuildContext context,
      List<Map<String, String>> items,
      Color primary,
      ) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final dua = items[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.volunteer_activism_rounded,
                      color: primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dua['title']!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'نسخ الدعاء',
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: dua['text']!),
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ الدعاء'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dua['text']!,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    height: 2,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Chip(
                    label: Text(dua['category']!),
                    avatar: const Icon(
                      Icons.bookmark_outline_rounded,
                      size: 18,
                    ),
                    backgroundColor: primary.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
