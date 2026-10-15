
import 'package:flutter/material.dart';

import 'package:quran/presentation/qibla/pages/qibla.dart';
import 'package:quran/presentation/mode/pages/choose_quran_mode.dart';
import 'package:quran/presentation/prayer_times/pages/prayer_times.dart';

import 'package:quran/presentation/azkar/pages/azkar.dart';
import 'package:quran/presentation/duas/pages/duas.dart';
import 'package:quran/presentation/tasbih/pages/tasbih.dart';
import 'package:quran/presentation/hadith/pages/hadith.dart';
import 'package:quran/presentation/prophets_stories/pages/prophets_stories.dart';
import 'package:quran/presentation/names/pages/names.dart';
import 'package:quran/presentation/about_islam/pages/about_islam.dart';
import 'package:quran/presentation/zakat_calc/pages/zakat_calc.dart';
import 'package:quran/presentation/islamic_calendar/pages/islamic_calendar.dart';

class IslamicHomePage extends StatelessWidget {
  const IslamicHomePage({super.key});

  void _openSection(
      BuildContext context,
      _IslamicSection section,
      ) {
    Widget? page;

    switch (section.title) {
      case 'Prayer Times':
        page = const PrayerTimesPage();
        break;

      case 'Qibla':
        page = const QiblaPage();
        break;

      case 'Morning Adhkar':
        page = const AzkarPage(initialEvening: false);
        break;

      case 'Evening Adhkar':
        page = const AzkarPage(initialEvening: true);
        break;

      case 'Duas':
        page = const DuasPage();
        break;

      case 'Tasbih':
        page = const TasbihPage();
        break;

      case 'Hadith':
        page = const HadithPage();
        break;

      case 'Prophets Stories':
        page = const ProphetsStoriesPage();
        break;

      case 'Names of Allah':
        page = const NamesOfAllahPage();
        break;

      case 'About Islam':
        page = const AboutIslamPage();
        break;

      case 'Zakat Calculator':
        page = const ZakatCalculatorPage();
        break;

      case 'Islamic Calendar':
        page = const IslamicCalendarPage();
        break;
    }

    if (page == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final green =
    isDark ? Colors.greenAccent : Colors.green.shade700;

    final sections = <_IslamicSection>[
      const _IslamicSection(
        title: 'Prayer Times',
        subtitle: 'مواقيت الصلاة والأذان',
        icon: Icons.access_time_rounded,
        color: Colors.teal,
      ),
      const _IslamicSection(
        title: 'Qibla',
        subtitle: 'اتجاه القبلة',
        icon: Icons.explore_rounded,
        color: Colors.blue,
      ),
      const _IslamicSection(
        title: 'Morning Adhkar',
        subtitle: 'أذكار الصباح',
        icon: Icons.wb_sunny_rounded,
        color: Colors.orange,
      ),
      const _IslamicSection(
        title: 'Evening Adhkar',
        subtitle: 'أذكار المساء',
        icon: Icons.nightlight_round,
        color: Colors.indigo,
      ),
      const _IslamicSection(
        title: 'Duas',
        subtitle: 'الأدعية اليومية',
        icon: Icons.volunteer_activism_rounded,
        color: Colors.pink,
      ),
      const _IslamicSection(
        title: 'Tasbih',
        subtitle: 'السبحة الإلكترونية',
        icon: Icons.fingerprint_rounded,
        color: Colors.green,
      ),
      const _IslamicSection(
        title: 'Hadith',
        subtitle: 'الأحاديث النبوية',
        icon: Icons.menu_book_rounded,
        color: Colors.brown,
      ),
      const _IslamicSection(
        title: 'Prophets Stories',
        subtitle: 'قصص الأنبياء',
        icon: Icons.auto_stories_rounded,
        color: Colors.deepPurple,
      ),
      const _IslamicSection(
        title: 'Names of Allah',
        subtitle: 'أسماء الله الحسنى',
        icon: Icons.star_rounded,
        color: Colors.amber,
      ),
      const _IslamicSection(
        title: 'About Islam',
        subtitle: 'الإسلام وأركانه',
        icon: Icons.mosque_rounded,
        color: Colors.cyan,
      ),
      const _IslamicSection(
        title: 'Zakat Calculator',
        subtitle: 'حساب الزكاة',
        icon: Icons.calculate_rounded,
        color: Colors.deepOrange,
      ),
      const _IslamicSection(
        title: 'Islamic Calendar',
        subtitle: 'التقويم الهجري والميلادي',
        icon: Icons.calendar_month_rounded,
        color: Colors.blueGrey,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Companion'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back to Choose Your Mode',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  24,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                        Colors.green.shade900,
                        Colors.green.shade700,
                      ]
                          : [
                        Colors.green.shade800,
                        Colors.green.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.mosque_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Assalamu Alaikum',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your daily companion for worship, '
                            'knowledge, and remembrance.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Remember Allah every day',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Islamic Services',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.grid_view_rounded,
                      color: green,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                28,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final section = sections[index];

                    return _SectionCard(
                      section: section,
                      onTap: () => _openSection(context, section),
                    );
                  },
                  childCount: sections.length,
                ),
                gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  mainAxisExtent: 160,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IslamicSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _IslamicSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _SectionCard extends StatelessWidget {
  final _IslamicSection section;
  final VoidCallback onTap;

  const _SectionCard({
    required this.section,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = section.color;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  section.icon,
                  color: color,
                  size: 28,
                ),
              ),
              const Spacer(),
              Text(
                section.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                section.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color
                      ?.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
