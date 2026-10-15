
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/presentation/prayer_times/services/prayer_notification_service.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  List<_PrayerCity> allCities = [];
  List<String> countries = [];

  String? selectedCountry;
  _PrayerCity? selectedCity;

  Timer? _timer;
  DateTime now = DateTime.now();

  bool isLoading = true;
  bool notificationsEnabled = true;
  String? errorMessage;
  String? notificationMessage;

  final Map<String, String> countryNames = {
    'EG': 'Egypt',
    'SA': 'Saudi Arabia',
    'AE': 'United Arab Emirates',
    'US': 'United States',
    'GB': 'United Kingdom',
    'AD': 'Andorra',
    'QA': 'Qatar',
    'KW': 'Kuwait',
    'BH': 'Bahrain',
    'OM': 'Oman',
    'JO': 'Jordan',
    'IQ': 'Iraq',
    'SY': 'Syria',
    'LB': 'Lebanon',
    'PS': 'Palestine',
    'YE': 'Yemen',
    'MA': 'Morocco',
    'DZ': 'Algeria',
    'TN': 'Tunisia',
    'LY': 'Libya',
    'SD': 'Sudan',
    'TR': 'Turkey',
    'ID': 'Indonesia',
    'MY': 'Malaysia',
    'PK': 'Pakistan',
    'IN': 'India',
    'FR': 'France',
    'DE': 'Germany',
    'CA': 'Canada',
    'AU': 'Australia',
  };

  @override
  void initState() {
    super.initState();
    _loadCities();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final jsonString =
      await rootBundle.loadString('assets/data/prayer_cities.json');

      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        throw const FormatException('JSON must contain a list of cities.');
      }

      final loadedCities = <_PrayerCity>[];

      for (final item in decoded) {
        if (item is! Map) continue;

        final name = (item['name'] ?? '').toString().trim();
        final country = (item['country'] ?? '').toString().trim();

        final latitude = double.tryParse(
          (item['lat'] ?? item['latitude'] ?? '').toString(),
        );

        final longitude = double.tryParse(
          (item['lng'] ?? item['lon'] ?? item['longitude'] ?? '').toString(),
        );

        if (name.isEmpty ||
            country.isEmpty ||
            latitude == null ||
            longitude == null ||
            latitude < -90 ||
            latitude > 90 ||
            longitude < -180 ||
            longitude > 180) {
          continue;
        }

        loadedCities.add(
          _PrayerCity(
            name: name,
            country: country.toUpperCase(),
            latitude: latitude,
            longitude: longitude,
          ),
        );
      }

      loadedCities.sort((a, b) {
        final countryComparison = a.country.compareTo(b.country);
        if (countryComparison != 0) return countryComparison;
        return a.name.compareTo(b.name);
      });

      final uniqueCountries = loadedCities
          .map((city) => city.country)
          .toSet()
          .toList()
        ..sort();

      if (!mounted) return;

      setState(() {
        allCities = loadedCities;
        countries = uniqueCountries;

        if (countries.contains('EG')) {
          selectedCountry = 'EG';
        } else if (countries.isNotEmpty) {
          selectedCountry = countries.first;
        }

        final cities = _filteredCities;
        selectedCity = cities.isEmpty ? null : cities.first;

        isLoading = false;

        if (allCities.isEmpty) {
          errorMessage =
          'No valid cities found in assets/data/prayer_cities.json';
        }
      });

      if (selectedCity != null && notificationsEnabled) {
        await _scheduleNotifications(selectedCity!);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
        'Could not load cities. Check prayer_cities.json and pubspec.yaml.';
      });
    }
  }

  Future<void> _scheduleNotifications(_PrayerCity city) async {
    try {
      await PrayerNotificationService.instance.schedulePrayerNotifications(
        latitude: city.latitude,
        longitude: city.longitude,
      );

      if (!mounted) return;

      setState(() {
        notificationMessage = 'Prayer notifications scheduled.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        notificationMessage =
        'Could not schedule notifications. Check notification permissions.';
      });
    }
  }

  List<_PrayerCity> get _filteredCities {
    if (selectedCountry == null) return [];

    return allCities
        .where((city) => city.country == selectedCountry)
        .toList();
  }

  String _countryName(String code) => countryNames[code] ?? code;

  PrayerTimes _prayerTimesFor(DateTime date) {
    final city = selectedCity!;

    final coordinates = Coordinates(city.latitude, city.longitude);
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;

    return PrayerTimes(
      coordinates,
      DateComponents(date.year, date.month, date.day),
      params,
    );
  }

  List<_PrayerInfo> _getPrayerList(DateTime date) {
    final times = _prayerTimesFor(date);

    return [
      _PrayerInfo('Fajr', 'الفجر', times.fajr, Icons.nightlight_round),
      _PrayerInfo('Sunrise', 'الشروق', times.sunrise, Icons.wb_twilight),
      _PrayerInfo('Dhuhr', 'الظهر', times.dhuhr, Icons.wb_sunny_outlined),
      _PrayerInfo('Asr', 'العصر', times.asr, Icons.sunny),
      _PrayerInfo('Maghrib', 'المغرب', times.maghrib, Icons.wb_twilight),
      _PrayerInfo('Isha', 'العشاء', times.isha, Icons.nights_stay),
    ];
  }

  _PrayerInfo? get _nextPrayer {
    if (selectedCity == null) return null;

    final todayPrayers = _getPrayerList(now);
    final upcoming = todayPrayers.where(
          (prayer) => prayer.time.isAfter(now),
    );

    if (upcoming.isNotEmpty) return upcoming.first;

    return _getPrayerList(now.add(const Duration(days: 1))).first;
  }

  Duration get _remainingTime {
    final next = _nextPrayer;
    if (next == null) return Duration.zero;

    return next.time.difference(now);
  }

  String _formatCountdown(Duration duration) {
    if (duration.isNegative) duration = Duration.zero;

    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  Future<void> _chooseCity() async {
    final city = await showModalBottomSheet<_PrayerCity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => _CitySearchSheet(cities: _filteredCities),
    );

    if (city == null || !mounted) return;

    setState(() {
      selectedCity = city;
      notificationMessage = null;
    });

    if (notificationsEnabled) {
      await _scheduleNotifications(city);
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() {
      notificationsEnabled = enabled;
      notificationMessage = null;
    });

    try {
      if (enabled && selectedCity != null) {
        await _scheduleNotifications(selectedCity!);
      } else {
        await PrayerNotificationService.instance
            .cancelPrayerNotifications();

        if (!mounted) return;

        setState(() {
          notificationMessage = 'Prayer notifications disabled.';
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        notificationMessage = 'Could not update notification settings.';
      });
    }
  }

  Future<void> _changeCountry(String? country) async {
    if (country == null) return;

    final cities = allCities
        .where((city) => city.country == country)
        .toList();

    setState(() {
      selectedCountry = country;
      selectedCity = cities.isEmpty ? null : cities.first;
      notificationMessage = null;
    });

    if (selectedCity != null && notificationsEnabled) {
      await _scheduleNotifications(selectedCity!);
    } else if (cities.isEmpty) {
      await PrayerNotificationService.instance
          .cancelPrayerNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Prayer Times')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Prayer Times')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                Text(errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    _loadCities();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (selectedCountry == null ||
        _filteredCities.isEmpty ||
        selectedCity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Prayer Times')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No cities available for this country.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      );
    }

    final prayers = _getPrayerList(now);
    final nextPrayer = _nextPrayer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCities,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(Icons.mosque, size: 42, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Prayer Times',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${now.day}/${now.month}/${now.year}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    nextPrayer?.arabicName ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextPrayer == null
                        ? ''
                        : 'Next prayer: ${nextPrayer.englishName}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatCountdown(_remainingTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Time remaining',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Location',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedCountry,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Country',
                prefixIcon: const Icon(Icons.public),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: countries.map((code) {
                return DropdownMenuItem<String>(
                  value: code,
                  child: Text(
                    _countryName(code),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: _changeCountry,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _chooseCity,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_city),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('City', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            selectedCity!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.search),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Prayer notifications'),
              subtitle: const Text(
                'Schedule notifications for the five daily prayers',
              ),
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            if (notificationMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                notificationMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Today\'s Prayer Times',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...prayers.map((prayer) {
              final isNext = nextPrayer != null &&
                  prayer.englishName == nextPrayer.englishName &&
                  prayer.time == nextPrayer.time;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: isNext
                      ? primary.withValues(alpha: 0.13)
                      : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isNext ? primary : Colors.transparent,
                    width: 1.3,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      prayer.icon,
                      color: isNext ? primary : textColor,
                      size: 25,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prayer.arabicName,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            prayer.englishName,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.65),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatTime(prayer.time),
                      style: TextStyle(
                        color: isNext ? primary : textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Text(
              'Calculation method: Egyptian General Authority of Survey',
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PrayerCity {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const _PrayerCity({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

class _PrayerInfo {
  final String englishName;
  final String arabicName;
  final DateTime time;
  final IconData icon;

  const _PrayerInfo(
      this.englishName,
      this.arabicName,
      this.time,
      this.icon,
      );
}

class _CitySearchSheet extends StatefulWidget {
  final List<_PrayerCity> cities;

  const _CitySearchSheet({required this.cities});

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.cities.where((city) {
      return city.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            children: [
              const Text(
                'Choose City',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                onChanged: (value) => setState(() => query = value),
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No cities found'))
                    : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final city = filtered[index];

                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(city.name),
                      subtitle: Text(
                        '${city.latitude.toStringAsFixed(3)}, '
                            '${city.longitude.toStringAsFixed(3)}',
                      ),
                      onTap: () => Navigator.pop(context, city),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
