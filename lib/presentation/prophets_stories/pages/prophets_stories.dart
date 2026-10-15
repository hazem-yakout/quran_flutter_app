
import 'package:flutter/material.dart';

class ProphetsStoriesPage extends StatelessWidget {
  const ProphetsStoriesPage({super.key});

  static const List<Map<String, String>> stories = [
    {
      'name': 'آدم عليه السلام',
      'title': 'بداية البشرية',
      'summary':
      'خلق الله آدم عليه السلام، وعلّمه الأسماء، وأمر الملائكة بالسجود له سجود تكريم. ثم أسكنه الجنة، وبعد أن وقع هو وزوجه في المخالفة تابا إلى الله، فتاب عليهما. وجعل الله الأرض دارًا لذريته.',
      'lesson': 'التوبة والرجوع إلى الله.',
      'icon': '🌿',
    },
    {
      'name': 'نوح عليه السلام',
      'title': 'الصبر في الدعوة',
      'summary':
      'دعا نوح عليه السلام قومه إلى عبادة الله وحده زمنًا طويلًا، لكن كثيرًا منهم أصروا على التكذيب. فأمره الله بصنع السفينة، ونجّى المؤمنين معه، وأغرق المكذبين بالطوفان.',
      'lesson': 'الصبر والثبات على الحق.',
      'icon': '🚢',
    },
    {
      'name': 'إبراهيم عليه السلام',
      'title': 'خليل الرحمن',
      'summary':
      'دعا إبراهيم عليه السلام قومه إلى التوحيد، ورفض عبادة الأصنام. وابتلاه الله بابتلاءات عظيمة فصبر، وجعل الله في ذريته النبوة، ورفع مع ابنه إسماعيل قواعد الكعبة.',
      'lesson': 'التوحيد والتوكل على الله.',
      'icon': '🕋',
    },
    {
      'name': 'يوسف عليه السلام',
      'title': 'الصبر والعفو',
      'summary':
      'تعرض يوسف عليه السلام للحسد من إخوته، وأُلقي في البئر، ثم بيع وعاش في مصر. مرّ بابتلاءات كثيرة، حتى مكّنه الله في الأرض، واجتمع بأسرته، وعفا عن إخوته.',
      'lesson': 'الصبر والعفة والعفو عند المقدرة.',
      'icon': '⭐',
    },
    {
      'name': 'موسى عليه السلام',
      'title': 'مواجهة الظلم',
      'summary':
      'أرسل الله موسى عليه السلام إلى فرعون ليدعوه إلى عبادة الله وإطلاق بني إسرائيل. أيده الله بالآيات، وشق له البحر، فنجّى موسى ومن معه وأغرق فرعون وجنوده.',
      'lesson': 'الثقة بنصر الله ومواجهة الظلم.',
      'icon': '🌊',
    },
    {
      'name': 'داود عليه السلام',
      'title': 'العدل والعبادة',
      'summary':
      'آتَى الله داود عليه السلام الملك والحكمة، وأنزل عليه الزبور، وألان له الحديد. وكان نبيًا ملكًا، عُرف بالعبادة والإنابة إلى الله.',
      'lesson': 'العدل وشكر النعم.',
      'icon': '👑',
    },
    {
      'name': 'سليمان عليه السلام',
      'title': 'الشكر على النعم',
      'summary':
      'آتَى الله سليمان عليه السلام ملكًا عظيمًا، وعلّمه منطق الطير، وسخّر له الريح والجن بإذنه. ولما سمع كلام النملة شكر الله على نعمه.',
      'lesson': 'التواضع والشكر مهما عظمت النعم.',
      'icon': '🐜',
    },
    {
      'name': 'يونس عليه السلام',
      'title': 'الفرج بعد الكرب',
      'summary':
      'خرج يونس عليه السلام من قومه، فابتلعه الحوت بأمر الله، فنادى في الظلمات: لا إله إلا أنت سبحانك إني كنت من الظالمين. فاستجاب الله له ونجّاه من الغم.',
      'lesson': 'الدعاء والتوبة وعدم اليأس.',
      'icon': '🐋',
    },
    {
      'name': 'عيسى عليه السلام',
      'title': 'آية من الله',
      'summary':
      'خلق الله عيسى عليه السلام من أم بلا أب، وجعله آية للناس. أرسله إلى بني إسرائيل، وأيده بالمعجزات بإذن الله، ودعا إلى عبادة الله وحده.',
      'lesson': 'الإيمان بقدرة الله ورحمته.',
      'icon': '✨',
    },
    {
      'name': 'محمد ﷺ',
      'title': 'خاتم الأنبياء والمرسلين',
      'summary':
      'بعث الله محمدًا ﷺ بالقرآن الكريم رحمة للعالمين. دعا إلى التوحيد، وصبر على الأذى، وهاجر إلى المدينة، وبنى مجتمعًا قائمًا على الإيمان والعدل والرحمة، حتى أكمل الله به الدين.',
      'lesson': 'الرحمة وحسن الخلق والاقتداء بالنبي ﷺ.',
      'icon': '🌙',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? Colors.greenAccent : Colors.green.shade800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('قصص الأنبياء'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProphetStoryDetailsPage(
                      story: story,
                      primary: primary,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        story['icon']!,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story['name']!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            story['title']!,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'اضغط لقراءة القصة',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: primary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProphetStoryDetailsPage extends StatelessWidget {
  final Map<String, String> story;
  final Color primary;

  const ProphetStoryDetailsPage({
    super.key,
    required this.story,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(story['name']!),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  story['icon']!,
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 16),
                Text(
                  story['name']!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  story['title']!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'القصة',
            style: theme.textTheme.titleLarge?.copyWith(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            story['summary']!,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 2,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: primary.withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: primary),
                      const SizedBox(width: 8),
                      Text(
                        'العبرة المستفادة',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    story['lesson']!,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'هذه نبذة مختصرة، ويُرجى الرجوع إلى القرآن الكريم والتفاسير الموثوقة للتفاصيل.',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
