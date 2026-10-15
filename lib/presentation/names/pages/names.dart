import 'package:flutter/material.dart';

class NamesOfAllahPage extends StatefulWidget {
const NamesOfAllahPage({super.key});

@override
State<NamesOfAllahPage> createState() => _NamesOfAllahPageState();
}

class _NamesOfAllahPageState extends State<NamesOfAllahPage> {
final TextEditingController _searchController = TextEditingController();
String _searchQuery = '';

final List<Map<String, String>> _names = const [
{'name': 'الرَّحْمَنُ', 'meaning': 'واسع الرحمة لجميع خلقه'},
{'name': 'الرَّحِيمُ', 'meaning': 'كثير الرحمة بعباده'},
{'name': 'الْمَلِكُ', 'meaning': 'المالك المتصرف في كل شيء'},
{'name': 'الْقُدُّوسُ', 'meaning': 'المنزه عن كل نقص'},
{'name': 'السَّلَامُ', 'meaning': 'السالم من كل نقص وآفة'},
{'name': 'الْمُؤْمِنُ', 'meaning': 'الذي يمنح الأمن ويصدق وعده'},
{'name': 'الْمُهَيْمِنُ', 'meaning': 'الرقيب والحافظ لكل شيء'},
{'name': 'الْعَزِيزُ', 'meaning': 'الغالب الذي لا يُغلب'},
{'name': 'الْجَبَّارُ', 'meaning': 'العلي القاهر وجابر الكسير'},
{'name': 'الْمُتَكَبِّرُ', 'meaning': 'المتعالي عن صفات الخلق'},
{'name': 'الْخَالِقُ', 'meaning': 'الذي أوجد الخلق'},
{'name': 'الْبَارِئُ', 'meaning': 'الذي خلق الخلق وأوجدهم'},
{'name': 'الْمُصَوِّرُ', 'meaning': 'الذي أعطى كل مخلوق صورته'},
{'name': 'الْغَفَّارُ', 'meaning': 'كثير المغفرة لذنوب عباده'},
{'name': 'الْقَهَّارُ', 'meaning': 'الغالب لكل شيء'},
{'name': 'الْوَهَّابُ', 'meaning': 'كثير العطاء بلا مقابل'},
{'name': 'الرَّزَّاقُ', 'meaning': 'الذي يرزق جميع المخلوقات'},
{'name': 'الْفَتَّاحُ', 'meaning': 'الذي يفتح أبواب الخير ويحكم بالحق'},
{'name': 'الْعَلِيمُ', 'meaning': 'الذي أحاط علمه بكل شيء'},
{'name': 'الْقَابِضُ', 'meaning': 'الذي يقبض بحكمته'},
{'name': 'الْبَاسِطُ', 'meaning': 'الذي يبسط فضله ورزقه'},
{'name': 'الْخَافِضُ', 'meaning': 'الذي يخفض من يشاء بحكمته'},
{'name': 'الرَّافِعُ', 'meaning': 'الذي يرفع من يشاء بفضله'},
{'name': 'الْمُعِزُّ', 'meaning': 'الذي يمنح العزة لمن يشاء'},
{'name': 'الْمُذِلُّ', 'meaning': 'الذي يذل من يشاء بعدله'},
{'name': 'السَّمِيعُ', 'meaning': 'الذي يسمع كل شيء'},
{'name': 'الْبَصِيرُ', 'meaning': 'الذي يرى كل شيء'},
{'name': 'الْحَكَمُ', 'meaning': 'الذي يحكم بالحق'},
{'name': 'الْعَدْلُ', 'meaning': 'الذي لا يظلم أحدًا'},
{'name': 'اللَّطِيفُ', 'meaning': 'الرفيق بعباده والخبير بدقائق الأمور'},
{'name': 'الْخَبِيرُ', 'meaning': 'العالم ببواطن الأمور'},
{'name': 'الْحَلِيمُ', 'meaning': 'الذي لا يعجل بالعقوبة'},
{'name': 'الْعَظِيمُ', 'meaning': 'صاحب العظمة والكمال'},
{'name': 'الْغَفُورُ', 'meaning': 'واسع المغفرة'},
{'name': 'الشَّكُورُ', 'meaning': 'الذي يثيب على العمل القليل كثيرًا'},
{'name': 'الْعَلِيُّ', 'meaning': 'المتعالي فوق خلقه'},
{'name': 'الْكَبِيرُ', 'meaning': 'العظيم الذي كل شيء دونه'},
{'name': 'الْحَفِيظُ', 'meaning': 'الذي يحفظ كل شيء'},
{'name': 'الْمُقِيتُ', 'meaning': 'الذي يوصل الأقوات والأرزاق'},
{'name': 'الْحَسِيبُ', 'meaning': 'الكافي لعباده والمحاسب لهم'},
{'name': 'الْجَلِيلُ', 'meaning': 'صاحب الجلال والعظمة'},
{'name': 'الْكَرِيمُ', 'meaning': 'كثير الخير والعطاء'},
{'name': 'الرَّقِيبُ', 'meaning': 'المطلع على كل شيء'},
{'name': 'الْمُجِيبُ', 'meaning': 'الذي يجيب دعاء من دعاه'},
{'name': 'الْوَاسِعُ', 'meaning': 'الواسع في علمه ورحمته وفضله'},
{'name': 'الْحَكِيمُ', 'meaning': 'الذي يضع الأمور في مواضعها'},
{'name': 'الْوَدُودُ', 'meaning': 'المحب لعباده الصالحين'},
{'name': 'الْمَجِيدُ', 'meaning': 'العظيم كثير المجد والشرف'},
{'name': 'الْبَاعِثُ', 'meaning': 'الذي يبعث الخلق يوم القيامة'},
{'name': 'الشَّهِيدُ', 'meaning': 'الشاهد على كل شيء'},
{'name': 'الْحَقُّ', 'meaning': 'الثابت الذي لا شك فيه'},
{'name': 'الْوَكِيلُ', 'meaning': 'الكافي لمن توكل عليه'},
{'name': 'الْقَوِيُّ', 'meaning': 'صاحب القوة الكاملة'},
{'name': 'الْمَتِينُ', 'meaning': 'شديد القوة الذي لا يضعف'},
{'name': 'الْوَلِيُّ', 'meaning': 'ناصر عباده المؤمنين'},
{'name': 'الْحَمِيدُ', 'meaning': 'المستحق للحمد والثناء'},
{'name': 'الْمُحْصِي', 'meaning': 'الذي أحاط بكل شيء عددًا وعلمًا'},
{'name': 'الْمُبْدِئُ', 'meaning': 'الذي يبدأ الخلق'},
{'name': 'الْمُعِيدُ', 'meaning': 'الذي يعيد الخلق بعد الموت'},
{'name': 'الْمُحْيِي', 'meaning': 'الذي يهب الحياة'},
{'name': 'الْمُمِيتُ', 'meaning': 'الذي يقدر الموت على خلقه'},
{'name': 'الْحَيُّ', 'meaning': 'الحي الذي لا يموت'},
{'name': 'الْقَيُّومُ', 'meaning': 'القائم بنفسه والمدبر لكل شيء'},
{'name': 'الْوَاجِدُ', 'meaning': 'الذي لا يعجزه شيء'},
{'name': 'الْمَاجِدُ', 'meaning': 'الكريم العظيم كثير المجد'},
{'name': 'الْوَاحِدُ', 'meaning': 'المتفرد الذي لا شريك له'},
{'name': 'الصَّمَدُ', 'meaning': 'السيد الكامل الذي يُقصد في الحوائج'},
{'name': 'الْقَادِرُ', 'meaning': 'الذي له القدرة على كل شيء'},
{'name': 'الْمُقْتَدِرُ', 'meaning': 'تام القدرة ولا يعجزه شيء'},
{'name': 'الْمُقَدِّمُ', 'meaning': 'الذي يقدم ما يشاء بحكمته'},
{'name': 'الْمُؤَخِّرُ', 'meaning': 'الذي يؤخر ما يشاء بحكمته'},
{'name': 'الْأَوَّلُ', 'meaning': 'الذي ليس قبله شيء'},
{'name': 'الْآخِرُ', 'meaning': 'الذي ليس بعده شيء'},
{'name': 'الظَّاهِرُ', 'meaning': 'الذي ليس فوقه شيء'},
{'name': 'الْبَاطِنُ', 'meaning': 'الذي ليس دونه شيء وهو المحيط بكل شيء'},
{'name': 'الْوَالِي', 'meaning': 'المالك المدبر لجميع الأمور'},
{'name': 'الْمُتَعَالِي', 'meaning': 'المتعالي عن كل نقص'},
{'name': 'الْبَرُّ', 'meaning': 'الكثير الإحسان والفضل'},
{'name': 'التَّوَّابُ', 'meaning': 'الذي يقبل توبة عباده'},
{'name': 'الْمُنْتَقِمُ', 'meaning': 'الذي يعاقب الظالمين بعدله'},
{'name': 'الْعَفُوُّ', 'meaning': 'الذي يمحو الذنوب ويتجاوز عنها'},
{'name': 'الرَّؤُوفُ', 'meaning': 'شديد الرحمة بعباده'},
{'name': 'مَالِكُ الْمُلْكِ', 'meaning': 'المالك لكل الملك والمتصرف فيه'},
{'name': 'ذُو الْجَلَالِ وَالْإِكْرَامِ', 'meaning': 'صاحب العظمة والكمال والكرم'},
{'name': 'الْمُقْسِطُ', 'meaning': 'العادل الذي يقيم القسط'},
{'name': 'الْجَامِعُ', 'meaning': 'الذي يجمع الخلق ليوم القيامة'},
{'name': 'الْغَنِيُّ', 'meaning': 'المستغني عن كل ما سواه'},
{'name': 'الْمُغْنِي', 'meaning': 'الذي يغني من يشاء من فضله'},
{'name': 'الْمَانِعُ', 'meaning': 'الذي يمنع بحكمته'},
{'name': 'الضَّارُّ', 'meaning': 'الذي يقدر ما يقع من الضر بحكمته'},
{'name': 'النَّافِعُ', 'meaning': 'الذي يقدر النفع ويمنحه'},
{'name': 'النُّورُ', 'meaning': 'نور السماوات والأرض وهادي أهلها'},
{'name': 'الْهَادِي', 'meaning': 'الذي يهدي إلى الحق'},
{'name': 'الْبَدِيعُ', 'meaning': 'الذي خلق الخلق على غير مثال سابق'},
{'name': 'الْبَاقِي', 'meaning': 'الدائم الذي لا يفنى'},
{'name': 'الْوَارِثُ', 'meaning': 'الباقي بعد فناء الخلق'},
{'name': 'الرَّشِيدُ', 'meaning': 'الذي يرشد إلى الصواب'},
{'name': 'الصَّبُورُ', 'meaning': 'الذي لا يعجل بالعقوبة'},
];

List<Map<String, String>> get _filteredNames {
if (_searchQuery.trim().isEmpty) return _names;

final query = _searchQuery.trim();
return _names.where((item) {
return item['name']!.contains(query) ||
item['meaning']!.contains(query);
}).toList();
}

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;
final names = _filteredNames;

return Scaffold(
appBar: AppBar(
title: const Text('أسماء الله الحسنى'),
centerTitle: true,
),
body: Column(
children: [
Container(
width: double.infinity,
margin: const EdgeInsets.all(16),
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: colors.primaryContainer,
borderRadius: BorderRadius.circular(20),
),
child: Column(
children: [
Icon(
Icons.mosque_rounded,
size: 42,
color: colors.onPrimaryContainer,
),
const SizedBox(height: 12),
Text(
'وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ',
textAlign: TextAlign.center,
style: theme.textTheme.titleLarge?.copyWith(
color: colors.onPrimaryContainer,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
'فَادْعُوهُ بِهَا',
style: theme.textTheme.titleMedium?.copyWith(
color: colors.onPrimaryContainer,
),
),
const SizedBox(height: 8),
Text(
'سورة الأعراف، الآية 180',
style: theme.textTheme.bodySmall?.copyWith(
color: colors.onPrimaryContainer,
),
),
],
),
),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 16),
child: TextField(
controller: _searchController,
onChanged: (value) {
setState(() => _searchQuery = value);
},
decoration: InputDecoration(
hintText: 'ابحث عن اسم أو معنى...',
prefixIcon: const Icon(Icons.search),
suffixIcon: _searchQuery.isEmpty
? null
    : IconButton(
icon: const Icon(Icons.close),
onPressed: () {
_searchController.clear();
setState(() => _searchQuery = '');
},
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(16),
),
),
),
),
const SizedBox(height: 12),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 16),
child: Row(
children: [
Text(
'الأسماء',
style: theme.textTheme.titleMedium?.copyWith(
fontWeight: FontWeight.bold,
),
),
const Spacer(),
Text(
'${names.length} اسم',
style: theme.textTheme.bodySmall?.copyWith(
color: colors.primary,
),
),
],
),
),
const SizedBox(height: 8),
Expanded(
child: names.isEmpty
? const Center(
child: Text('لا توجد نتائج مطابقة'),
)
    : ListView.builder(
padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
itemCount: names.length,
itemBuilder: (context, index) {
final item = names[index];

return Card(
margin: const EdgeInsets.only(bottom: 10),
elevation: 0,
color: colors.surfaceContainerLow,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
side: BorderSide(
color: colors.outlineVariant,
),
),
child: ListTile(
contentPadding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 8,
),
leading: CircleAvatar(
backgroundColor: colors.primaryContainer,
child: Text(
'${_names.indexOf(item) + 1}',
style: TextStyle(
color: colors.onPrimaryContainer,
fontWeight: FontWeight.bold,
),
),
),
title: Text(
item['name']!,
textDirection: TextDirection.rtl,
style: theme.textTheme.titleLarge?.copyWith(
color: colors.primary,
fontWeight: FontWeight.bold,
),
),
subtitle: Padding(
padding: const EdgeInsets.only(top: 6),
child: Text(
item['meaning']!,
textDirection: TextDirection.rtl,
style: theme.textTheme.bodyMedium,
),
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
}
