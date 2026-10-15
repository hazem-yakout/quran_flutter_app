import 'package:flutter/material.dart';

class AboutIslamPage extends StatelessWidget {
const AboutIslamPage({super.key});

static const List<Map<String, dynamic>> _sections = [
{
'title': 'أركان الإسلام',
'subtitle': 'الأسس الخمسة للإسلام',
'icon': Icons.mosque_rounded,
'items': [
{
'title': 'الشهادتان',
'description':
'شهادة أن لا إله إلا الله وأن محمدًا رسول الله.',
},
{
'title': 'إقامة الصلاة',
'description':
'أداء الصلوات الخمس المفروضة في أوقاتها.',
},
{
'title': 'إيتاء الزكاة',
'description':
'إخراج الزكاة الواجبة لمستحقيها وفق أحكامها.',
},
{
'title': 'صوم رمضان',
'description':
'الإمساك عن المفطرات من طلوع الفجر إلى غروب الشمس بنية الصيام.',
},
{
'title': 'حج البيت',
'description':
'حج بيت الله الحرام لمن استطاع إليه سبيلًا.',
},
],
},
{
'title': 'أركان الإيمان',
'subtitle': 'أصول الإيمان الستة',
'icon': Icons.favorite_rounded,
'items': [
{
'title': 'الإيمان بالله',
'description':
'الإيمان بوجود الله وربوبيته وألوهيته وأسمائه وصفاته.',
},
{
'title': 'الإيمان بالملائكة',
'description':
'الإيمان بملائكة الله الذين خلقهم لطاعته وتنفيذ أمره.',
},
{
'title': 'الإيمان بالكتب',
'description':
'الإيمان بالكتب التي أنزلها الله على رسله.',
},
{
'title': 'الإيمان بالرسل',
'description':
'الإيمان بجميع رسل الله الذين أرسلهم لهداية البشر.',
},
{
'title': 'الإيمان باليوم الآخر',
'description':
'الإيمان بالبعث والحساب والجنة والنار وما ثبت من أحوال الآخرة.',
},
{
'title': 'الإيمان بالقدر',
'description':
'الإيمان بأن كل شيء يقع بعلم الله ومشيئته وقدره.',
},
],
},
{
'title': 'القرآن الكريم',
'subtitle': 'كتاب الله المنزل على نبيه محمد ﷺ',
'icon': Icons.menu_book_rounded,
'items': [
{
'title': 'السور',
'description':
'يتكون القرآن الكريم من 114 سورة.',
},
{
'title': 'الأجزاء',
'description':
'يقسم القرآن إلى 30 جزءًا لتيسير القراءة والمراجعة.',
},
{
'title': 'آداب التلاوة',
'description':
'الإخلاص والتدبر والإنصات واحترام كلام الله.',
},
{
'title': 'التدبر والعمل',
'description':
'المقصود من التلاوة فهم الهداية القرآنية والعمل بها.',
},
],
},
{
'title': 'الطهارة والوضوء',
'subtitle': 'التطهر استعدادًا للصلاة',
'icon': Icons.water_drop_rounded,
'items': [
{
'title': 'النية',
'description':
'ينوي المسلم الوضوء للطهارة من الحدث.',
},
{
'title': 'غسل الوجه',
'description':
'غسل الوجه كاملًا ضمن حدود الوجه المعتبرة شرعًا.',
},
{
'title': 'غسل اليدين',
'description':
'غسل اليدين مع المرفقين.',
},
{
'title': 'مسح الرأس',
'description':
'مسح الرأس وفق صفة الوضوء المشروعة.',
},
{
'title': 'غسل القدمين',
'description':
'غسل القدمين مع الكعبين.',
},
],
},
{
'title': 'الصلاة',
'subtitle': 'الصلوات الخمس المفروضة',
'icon': Icons.access_time_rounded,
'items': [
{
'title': 'الفجر',
'description': 'ركعتان فرض.',
},
{
'title': 'الظهر',
'description': 'أربع ركعات فرض.',
},
{
'title': 'العصر',
'description': 'أربع ركعات فرض.',
},
{
'title': 'المغرب',
'description': 'ثلاث ركعات فرض.',
},
{
'title': 'العشاء',
'description': 'أربع ركعات فرض.',
},
],
},
{
'title': 'الأخلاق الإسلامية',
'subtitle': 'قيم وسلوكيات المسلم',
'icon': Icons.volunteer_activism_rounded,
'items': [
{
'title': 'الصدق',
'description':
'الالتزام بالصدق في القول والعمل.',
},
{
'title': 'الأمانة',
'description':
'حفظ الحقوق وأداء الأمانات إلى أهلها.',
},
{
'title': 'الرحمة',
'description':
'الرفق بالناس والإحسان إلى المخلوقات.',
},
{
'title': 'بر الوالدين',
'description':
'الإحسان إلى الوالدين ومعاملتهما بالمعروف.',
},
{
'title': 'حسن المعاملة',
'description':
'احترام الآخرين والعدل معهم والابتعاد عن الأذى.',
},
],
},
];

void _openSection(
BuildContext context,
Map<String, dynamic> section,
) {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => _IslamicTopicPage(section: section),
),
);
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;

return Scaffold(
appBar: AppBar(
title: const Text('About Islam'),
centerTitle: true,
),
body: ListView(
padding: const EdgeInsets.all(16),
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: colors.primaryContainer,
borderRadius: BorderRadius.circular(24),
),
child: Column(
children: [
Icon(
Icons.mosque_rounded,
size: 58,
color: colors.onPrimaryContainer,
),
const SizedBox(height: 16),
Text(
'الإسلام',
style: theme.textTheme.headlineMedium?.copyWith(
color: colors.onPrimaryContainer,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
Text(
'الإسلام دين التوحيد، يدعو إلى عبادة الله وحده، '
'والعدل والرحمة والإحسان وحسن الخلق.',
textAlign: TextAlign.center,
style: theme.textTheme.bodyLarge?.copyWith(
color: colors.onPrimaryContainer,
height: 1.8,
),
),
const SizedBox(height: 16),
Text(
'إِنَّ الدِّينَ عِندَ اللَّهِ الْإِسْلَامُ',
textAlign: TextAlign.center,
textDirection: TextDirection.rtl,
style: theme.textTheme.titleMedium?.copyWith(
color: colors.onPrimaryContainer,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 6),
Text(
'سورة آل عمران، الآية 19',
style: theme.textTheme.bodySmall?.copyWith(
color: colors.onPrimaryContainer,
),
),
],
),
),
const SizedBox(height: 24),
Text(
'اكتشف الإسلام',
style: theme.textTheme.titleLarge?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
..._sections.map((section) {
return Card(
elevation: 0,
margin: const EdgeInsets.only(bottom: 12),
color: colors.surfaceContainerLow,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(18),
side: BorderSide(color: colors.outlineVariant),
),
child: ListTile(
contentPadding: const EdgeInsets.all(14),
leading: CircleAvatar(
radius: 25,
backgroundColor: colors.primaryContainer,
child: Icon(
section['icon'] as IconData,
color: colors.onPrimaryContainer,
),
),
title: Text(
section['title'] as String,
style: const TextStyle(fontWeight: FontWeight.bold),
),
subtitle: Padding(
padding: const EdgeInsets.only(top: 5),
child: Text(section['subtitle'] as String),
),
trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
onTap: () => _openSection(context, section),
),
);
}),
const SizedBox(height: 12),
Text(
'ملاحظة: هذه الصفحة مقدمة تعليمية مختصرة، '
'وليست بديلًا عن الرجوع إلى القرآن الكريم '
'والمصادر الشرعية الموثوقة.',
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

class _IslamicTopicPage extends StatelessWidget {
final Map<String, dynamic> section;

const _IslamicTopicPage({required this.section});

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;
final items = section['items'] as List<Map<String, String>>;

return Scaffold(
appBar: AppBar(
title: Text(section['title'] as String),
centerTitle: true,
),
body: ListView.separated(
padding: const EdgeInsets.all(16),
itemCount: items.length,
separatorBuilder: (_, __) => const SizedBox(height: 10),
itemBuilder: (context, index) {
final item = items[index];

return Card(
elevation: 0,
color: colors.surfaceContainerLow,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
side: BorderSide(color: colors.outlineVariant),
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
CircleAvatar(
backgroundColor: colors.primaryContainer,
foregroundColor: colors.onPrimaryContainer,
child: Text('${index + 1}'),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
item['title']!,
style: theme.textTheme.titleMedium?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
item['description']!,
style: theme.textTheme.bodyMedium?.copyWith(
height: 1.7,
),
),
],
),
),
],
),
),
);
},
),
);
}
}
