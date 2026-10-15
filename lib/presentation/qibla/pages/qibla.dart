import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;

  bool _loading = true;
  String? _error;
  double? _qiblaBearing;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _loadQiblaDirection();
  }

  Future<void> _loadQiblaDirection() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Location is disabled. Please enable GPS and try again.',
        );
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission was denied. Allow location access to find Qibla.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is permanently denied. Enable it in app settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );

      final bearing = _calculateBearing(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _qiblaBearing = bearing;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  double _calculateBearing(double latitude, double longitude) {
    final lat1 = latitude * math.pi / 180;
    final lat2 = _kaabaLatitude * math.pi / 180;
    final deltaLongitude =
        (_kaabaLongitude - longitude) * math.pi / 180;

    final y = math.sin(deltaLongitude) * math.cos(lat2);

    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) *
            math.cos(lat2) *
            math.cos(deltaLongitude);

    final bearing = math.atan2(y, x) * 180 / math.pi;

    return (bearing + 360) % 360;
  }

  String _directionName(double degrees) {
    const directions = [
      'North',
      'North-East',
      'East',
      'South-East',
      'South',
      'South-West',
      'West',
      'North-West',
    ];

    final index = ((degrees + 22.5) / 45).floor() % 8;

    return directions[index];
  }

  String _formatCoordinate(double? value) {
    if (value == null) return '--';
    return value.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadQiblaDirection,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              Container(
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
                child: const Column(
                  children: [
                    Icon(
                      Icons.mosque_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Find Your Qibla',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Face the Holy Kaaba in Makkah '
                          'for your prayers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Finding your location...'),
                    ],
                  ),
                )
              else if (_error != null)
                _buildErrorCard(colors)
              else if (_qiblaBearing != null)
                  _buildCompass(colors, isDark),
              if (!_loading && _error == null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: colors.surfaceContainerHighest
                      .withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Location',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _locationRow(
                          Icons.location_on_outlined,
                          'Latitude',
                          _formatCoordinate(_latitude),
                        ),
                        const SizedBox(height: 10),
                        _locationRow(
                          Icons.location_on_outlined,
                          'Longitude',
                          _formatCoordinate(_longitude),
                        ),
                        const SizedBox(height: 10),
                        _locationRow(
                          Icons.explore_outlined,
                          'Qibla bearing',
                          '${_qiblaBearing!.toStringAsFixed(1)}° '
                              'from true north',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'For the best result, keep your phone flat and '
                      'away from magnets, metal objects, and other '
                      'devices that may affect its compass.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.65),
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompass(ColorScheme colors, bool isDark) {
    return Column(
      children: [
        Text(
          'Qibla Compass',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 22),
        StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            final heading = snapshot.data?.heading;

            if (heading == null) {
              return _compassUnavailable(colors);
            }

            final normalizedHeading = (heading + 360) % 360;

            final relativeAngle =
                (_qiblaBearing! - normalizedHeading) *
                    math.pi /
                    180;

            return Column(
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surface,
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.4),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(
                                alpha: 0.10,
                              ),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      for (var i = 0; i < 4; i++)
                        Transform.rotate(
                          angle: i * math.pi / 2,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                ['N', 'E', 'S', 'W'][i],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: i == 0
                                      ? Colors.red
                                      : colors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      for (var i = 0; i < 36; i++)
                        Transform.rotate(
                          angle: i * math.pi / 18,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 43),
                              width: i % 3 == 0 ? 2 : 1,
                              height: i % 3 == 0 ? 12 : 6,
                              color: colors.onSurface.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                        ),
                      Transform.rotate(
                        angle: relativeAngle,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.navigation_rounded,
                              size: 94,
                              color: Colors.green,
                            ),
                            Container(
                              width: 8,
                              height: 22,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.surface,
                            width: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_qiblaBearing!.toStringAsFixed(1)}°',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _directionName(_qiblaBearing!),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Phone heading: '
                            '${normalizedHeading.toStringAsFixed(1)}°',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _compassUnavailable(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.explore_off_rounded,
            size: 50,
            color: colors.error,
          ),
          const SizedBox(height: 12),
          const Text(
            'Compass sensor unavailable',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Qibla bearing is calculated, but this device '
                'is not providing a compass heading.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Qibla: ${_qiblaBearing!.toStringAsFixed(1)}° '
                'from true north',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ColorScheme colors) {
    return Card(
      elevation: 0,
      color: colors.errorContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 48,
              color: colors.onErrorContainer,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to find Qibla',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onErrorContainer,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadQiblaDirection,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
            if (_error!.contains('permanently denied')) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: Geolocator.openAppSettings,
                child: const Text('Open App Settings'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _locationRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}