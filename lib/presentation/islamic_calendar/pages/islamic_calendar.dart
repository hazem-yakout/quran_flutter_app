import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class IslamicCalendarPage extends StatefulWidget {
const IslamicCalendarPage({super.key});

@override
State<IslamicCalendarPage> createState() =>
_IslamicCalendarPageState();
}

class _IslamicCalendarPageState
extends State<IslamicCalendarPage> {
DateTime selectedDate = DateTime.now();
bool _localeReady = false;

static const List<String> hijriMonths = [
'محرم',
'صفر',
'ربيع الأول',
'ربيع الآخر',
'جمادى الأولى',
'جمادى الآخرة',
'رجب',
'شعبان',
'رمضان',
'شوال',
'ذو القعدة',
'ذو الحجة',
];

static const List<Map<String, String>> occasions = [
{
'title': 'رأس السنة الهجرية',
'date': '1 محرم',
'description': 'بداية العام الهجري الجديد.',
},
{
'title': 'عاشوراء',
'date': '10 محرم',
'description': 'يُستحب صيام يوم عاشوراء.',
},
{
'title': 'المولد النبوي',
'date': '12 ربيع الأول',
'description': 'التاريخ المشهور للمولد النبوي.',
},
{
'title': 'الإسراء والمعراج',
'date': '27 رجب',
'description': 'التاريخ المشهور لهذه المناسبة.',
},
{
'title': 'منتصف شعبان',
'date': '15 شعبان',
'description': 'ليلة النصف من شعبان.',
},
{
'title': 'بداية رمضان',
'date': '1 رمضان',
'description': 'بداية شهر الصيام بحسب ثبوت الهلال.',
},
{
'title': 'ليلة القدر',
'date': 'العشر الأواخر من رمضان',
'description':
'تُطلب ليلة القدر في العشر الأواخر، '
'وخاصة الليالي الوترية.',
},
{
'title': 'عيد الفطر',
'date': '1 شوال',
'description': 'عيد المسلمين بعد شهر رمضان.',
},
{
'title': 'يوم عرفة',
'date': '9 ذو الحجة',
'description': 'يوم عظيم ويُستحب صيامه لغير الحاج.',
},
{
'title': 'عيد الأضحى',
'date': '10 ذو الحجة',
'description': 'عيد الأضحى المبارك.',
},
];

@override
void initState() {
super.initState();
_initializeLocale();
}

Future<void> _initializeLocale() async {
try {
await initializeDateFormatting('ar', null);
} catch (_) {
// Keep the page usable even if locale initialization fails.
}

if (mounted) {
setState(() {
_localeReady = true;
});
}
}

// Arithmetic Islamic calendar conversion.
// This is an approximation, not the official Egyptian
// moon-sighting calendar.
double _islamicToJulianDay(int year, int month, int day) {
return day +
(29.5 * (month - 1)).ceil() +
(year - 1) * 354 +
((3 + 11 * year) ~/ 30) +
1948439.5 -
1;
}

Map<String, int> _getHijriDate(DateTime date) {
final utcDate = DateTime.utc(date.year, date.month, date.day);

final julianDay =
utcDate.millisecondsSinceEpoch / Duration.millisecondsPerDay +
2440587.5;

final year =
((30 * (julianDay - 1948439.5) + 10646) / 10631).floor();

final month = math.min(
12,
math.max(
1,
((julianDay -
(29 + _islamicToJulianDay(year, 1, 1))) /
29.5)
    .ceil() +
1,
),
);

final day =
(julianDay - _islamicToJulianDay(year, month, 1) + 1)
    .round();

return {
'year': year,
'month': month,
'day': day,
};
}

DateTime _hijriToGregorian(int year, int month, int day) {
final julianDay = _islamicToJulianDay(year, month, day);

final daysSinceUnixEpoch = (julianDay - 2440587.5).round();

final date = DateTime.utc(1970, 1, 1)
    .add(Duration(days: daysSinceUnixEpoch));

return DateTime(date.year, date.month, date.day);
}

String _getHijriMonthName(int month) {
if (month < 1 || month > 12) {
return '';
}

return hijriMonths[month - 1];
}

String _formatHijriDate() {
final hijri = _getHijriDate(selectedDate);

final day = hijri['day']!;
final month = hijri['month']!;
final year = hijri['year']!;

return '$day ${_getHijriMonthName(month)} $year هـ';
}

String _formatGregorianDate() {
if (!_localeReady) {
return '${selectedDate.year}/'
'${selectedDate.month}/'
'${selectedDate.day}';
}

return DateFormat('EEEE، d MMMM yyyy', 'ar')
    .format(selectedDate);
}

void _changeMonth(int amount) {
final hijri = _getHijriDate(selectedDate);

int year = hijri['year']!;
int month = hijri['month']! + amount;

if (month > 12) {
month = 1;
year++;
} else if (month < 1) {
month = 12;
year--;
}

setState(() {
selectedDate = _hijriToGregorian(year, month, 1);
});
}

Future<void> _selectDate() async {
final picked = await showDatePicker(
context: context,
initialDate: selectedDate,
firstDate: DateTime(1900),
lastDate: DateTime(2100),
helpText: 'اختر التاريخ الميلادي',
);

if (picked != null && mounted) {
setState(() {
selectedDate = DateTime(
picked.year,
picked.month,
picked.day,
);
});
}
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;
final hijri = _getHijriDate(selectedDate);

return Scaffold(
appBar: AppBar(
title: const Text('Islamic Calendar'),
centerTitle: true,
actions: [
IconButton(
tooltip: 'اختيار تاريخ',
onPressed: _selectDate,
icon: const Icon(Icons.calendar_month_rounded),
),
],
),
body: ListView(
padding: const EdgeInsets.all(16),
children: [
Container(
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: colors.primaryContainer,
borderRadius: BorderRadius.circular(24),
),
child: Column(
children: [
Icon(
Icons.nights_stay_rounded,
size: 52,
color: colors.onPrimaryContainer,
),
const SizedBox(height: 16),
Text(
'التقويم الهجري',
style: theme.textTheme.headlineSmall?.copyWith(
color: colors.onPrimaryContainer,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
Text(
_formatHijriDate(),
textAlign: TextAlign.center,
style: theme.textTheme.titleLarge?.copyWith(
color: colors.onPrimaryContainer,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
_formatGregorianDate(),
textAlign: TextAlign.center,
style: theme.textTheme.bodyMedium?.copyWith(
color: colors.onPrimaryContainer,
),
),
const SizedBox(height: 12),
Text(
'قد يختلف التاريخ الهجري يومًا '
'حسب رؤية الهلال.',
textAlign: TextAlign.center,
style: theme.textTheme.bodySmall?.copyWith(
color: colors.onPrimaryContainer,
),
),
],
),
),
const SizedBox(height: 24),
Text(
'التنقل بين الشهور الهجرية',
style: theme.textTheme.titleLarge?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
Card(
elevation: 0,
color: colors.surfaceContainerLow,
child: Padding(
padding: const EdgeInsets.symmetric(
vertical: 12,
horizontal: 8,
),
child: Row(
children: [
IconButton(
tooltip: 'الشهر السابق',
onPressed: () => _changeMonth(-1),
icon: const Icon(Icons.chevron_left_rounded),
),
Expanded(
child: Column(
children: [
Text(
_getHijriMonthName(hijri['month']!),
textAlign: TextAlign.center,
style: theme.textTheme.titleMedium?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Text(
'السنة الهجرية ${hijri['year']}',
style: theme.textTheme.bodySmall,
),
],
),
),
IconButton(
tooltip: 'الشهر التالي',
onPressed: () => _changeMonth(1),
icon: const Icon(Icons.chevron_right_rounded),
),
],
),
),
),
const SizedBox(height: 24),
Text(
'المناسبات الإسلامية',
style: theme.textTheme.titleLarge?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
...occasions.map((occasion) {
return Card(
elevation: 0,
margin: const EdgeInsets.only(bottom: 10),
color: colors.surfaceContainerLow,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
side: BorderSide(
color: colors.outlineVariant,
),
),
child: ListTile(
leading: CircleAvatar(
backgroundColor: colors.primaryContainer,
child: Icon(
Icons.event_rounded,
color: colors.onPrimaryContainer,
),
),
title: Text(
occasion['title']!,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
subtitle: Padding(
padding: const EdgeInsets.only(top: 6),
child: Text(
'${occasion['date']}\n'
'${occasion['description']}',
),
),
isThreeLine: true,
),
);
}),
const SizedBox(height: 16),
Text(
'ملاحظة: يعتمد هذا التقويم على حساب هجري '
'تقريبي، وقد يختلف عن التقويم الرسمي في مصر '
'بسبب رؤية الهلال. تأكد من المواعيد الرسمية '
'للمناسبات والأعياد.',
textAlign: TextAlign.center,
style: theme.textTheme.bodySmall?.copyWith(
color: colors.onSurfaceVariant,
height: 1.6,
),
),
],
),
);
}
}
