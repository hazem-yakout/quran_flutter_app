
import 'package:flutter/material.dart';

import 'package:quran/presentation/choose_reciter/pages/choose_reciter.dart';
import 'package:quran/presentation/quran_reader/pages/quran_reader_page.dart';
import 'package:quran/presentation/islamic_home/pages/islamic_home_page.dart';

class ChooseQuranModePage extends StatelessWidget {
  const ChooseQuranModePage({super.key});

  void openReading(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuranReaderPage(),
      ),
    );
  }

  void openListening(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseReciterPage(),
      ),
    );
  }

  void openIslamicMode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IslamicHomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final green =
    isDark ? Colors.greenAccent : Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Mode'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 25),

              Icon(
                Icons.auto_awesome_rounded,
                size: 80,
                color: green,
              ),

              const SizedBox(height: 20),

              Text(
                'Welcome to Your Islamic Companion',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Choose how you would like to explore.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 35),

              _ModeCard(
                icon: Icons.menu_book_rounded,
                title: 'Reading',
                description:
                'Read Quran verses, search, save bookmarks, and explore Tafsir.',
                color: green,
                onTap: () => openReading(context),
              ),

              const SizedBox(height: 20),

              _ModeCard(
                icon: Icons.headphones_rounded,
                title: 'Listening',
                description:
                'Choose your favorite reciter and listen to Quran surahs.',
                color: green,
                onTap: () => openListening(context),
              ),

              const SizedBox(height: 20),

              _ModeCard(
                icon: Icons.mosque_rounded,
                title: 'Islamic Mode',
                description:
                'Prayer times, Qibla, Adhkar, Duas, Tasbih, Hadith, '
                    'Prophets stories, Allah names, Zakat, and Islamic calendar.',
                color: green,
                onTap: () => openIslamicMode(context),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: color,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
