import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZakatCalculatorPage extends StatefulWidget {
const ZakatCalculatorPage({super.key});

@override
State<ZakatCalculatorPage> createState() =>
_ZakatCalculatorPageState();
}

class _ZakatCalculatorPageState extends State<ZakatCalculatorPage> {
final _cashController = TextEditingController();
final _savingsController = TextEditingController();
final _goldController = TextEditingController();
final _silverController = TextEditingController();
final _investmentsController = TextEditingController();
final _debtsController = TextEditingController();
final _nisabController = TextEditingController();

bool _hawlCompleted = true;
bool _calculate = false;

double _read(TextEditingController controller) {
return double.tryParse(controller.text.trim()) ?? 0;
}

double get _totalAssets {
return _read(_cashController) +
_read(_savingsController) +
_read(_goldController) +
_read(_silverController) +
_read(_investmentsController);
}

double get _netAssets {
return (_totalAssets - _read(_debtsController))
    .clamp(0.0, double.infinity)
    .toDouble();
}

double get _nisab => _read(_nisabController);

bool get _nisabReached => _nisab > 0 && _netAssets >= _nisab;

bool get _zakatDue => _nisabReached && _hawlCompleted;

double get _zakatAmount => _zakatDue ? _netAssets * 0.025 : 0;

String _formatMoney(double value) {
return value.toStringAsFixed(2);
}

void _calculateZakat() {
FocusScope.of(context).unfocus();
setState(() => _calculate = true);
}

void _clearFields() {
for (final controller in [
_cashController,
_savingsController,
_goldController,
_silverController,
_investmentsController,
_debtsController,
_nisabController,
]) {
controller.clear();
}

setState(() {
_hawlCompleted = true;
_calculate = false;
});
}

@override
void dispose() {
_cashController.dispose();
_savingsController.dispose();
_goldController.dispose();
_silverController.dispose();
_investmentsController.dispose();
_debtsController.dispose();
_nisabController.dispose();
super.dispose();
}

Widget _moneyField({
required String label,
required String hint,
required TextEditingController controller,
required IconData icon,
}) {
final colors = Theme.of(context).colorScheme;

return Padding(
padding: const EdgeInsets.only(bottom: 14),
child: TextField(
controller: controller,
keyboardType: const TextInputType.numberWithOptions(
decimal: true,
),
inputFormatters: [
FilteringTextInputFormatter.allow(
RegExp(r'^\d*\.?\d{0,2}'),
),
],
onChanged: (_) {
if (_calculate) setState(() {});
},
decoration: InputDecoration(
labelText: label,
hintText: hint,
prefixIcon: Icon(icon),
suffixText: 'جنيه',
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
filled: true,
fillColor: colors.surfaceContainerLow,
),
),
);
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;

return Scaffold(
appBar: AppBar(
title: const Text('Zakat Calculator'),
centerTitle: true,
actions: [
IconButton(
tooltip: 'مسح البيانات',
onPressed: _clearFields,
icon: const Icon(Icons.refresh_rounded),
),
],
),
body: ListView(
padding: const EdgeInsets.all(16),
children: [
Container(
padding: const EdgeInsets.all(22),
decoration: BoxDecoration(
color: colors.primaryContainer,
borderRadius: BorderRadius.circular(22),
),
child: Column(
children: [
Icon(
Icons.volunteer_activism_rounded,
size: 48,
color: colors.onPrimaryContainer,
),
const SizedBox(height: 12),
Text(
'حاسبة زكاة المال',
style: theme.textTheme.headlineSmall?.copyWith(
fontWeight: FontWeight.bold,
color: colors.onPrimaryContainer,
),
),
const SizedBox(height: 8),
Text(
'أدخل قيمة أموالك والالتزامات المستحقة '
'لتقدير الزكاة المحتملة.',
textAlign: TextAlign.center,
style: theme.textTheme.bodyMedium?.copyWith(
color: colors.onPrimaryContainer,
height: 1.7,
),
),
const SizedBox(height: 12),
Text(
'معدل الحساب: 2.5%',
style: theme.textTheme.titleMedium?.copyWith(
color: colors.onPrimaryContainer,
fontWeight: FontWeight.bold,
),
),
],
),
),
const SizedBox(height: 24),
Text(
'الأموال والأصول',
style: theme.textTheme.titleLarge?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 14),
_moneyField(
label: 'النقود المتوفرة',
hint: 'مثال: 20000',
controller: _cashController,
icon: Icons.payments_outlined,
),
_moneyField(
label: 'المدخرات والحسابات البنكية',
hint: 'مثال: 50000',
controller: _savingsController,
icon: Icons.account_balance_outlined,
),
_moneyField(
label: 'قيمة الذهب الخاضع للزكاة',
hint: 'أدخل القيمة المالية وليس الوزن',
controller: _goldController,
icon: Icons.diamond_outlined,
),
_moneyField(
label: 'قيمة الفضة الخاضعة للزكاة',
hint: 'أدخل القيمة المالية وليس الوزن',
controller: _silverController,
icon: Icons.circle_outlined,
),
_moneyField(
label: 'الاستثمارات والأصول التجارية',
hint: 'القيمة التي تدخل في وعاء الزكاة',
controller: _investmentsController,
icon: Icons.trending_up_rounded,
),
const SizedBox(height: 8),
Text(
'الالتزامات والنصاب',
style: theme.textTheme.titleLarge?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 14),
_moneyField(
label: 'الديون المستحقة حاليًا',
hint: 'أدخل الديون التي يجوز خصمها شرعًا',
controller: _debtsController,
icon: Icons.receipt_long_outlined,
),
_moneyField(
label: 'قيمة النصاب بالجنيه',
hint: 'أدخل قيمة النصاب الحالية',
controller: _nisabController,
icon: Icons.balance_outlined,
),
SwitchListTile(
contentPadding: EdgeInsets.zero,
title: const Text('مرّ حول قمري كامل'),
subtitle: const Text(
'فعّل الخيار إذا اكتملت سنة هجرية على المال '
'المستوفي لشروط الزكاة.',
),
value: _hawlCompleted,
onChanged: (value) {
setState(() {
_hawlCompleted = value;
_calculate = false;
});
},
),
const SizedBox(height: 16),
FilledButton.icon(
onPressed: _calculateZakat,
icon: const Icon(Icons.calculate_outlined),
label: const Padding(
padding: EdgeInsets.symmetric(vertical: 14),
child: Text('احسب الزكاة'),
),
),
if (_calculate) ...[
const SizedBox(height: 22),
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: colors.surfaceContainerLow,
borderRadius: BorderRadius.circular(20),
border: Border.all(color: colors.outlineVariant),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'نتيجة الحساب',
style: theme.textTheme.titleLarge?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 18),
_resultRow(
'إجمالي الأصول المدخلة',
'${_formatMoney(_totalAssets)} جنيه',
),
_resultRow(
'الالتزامات المدخلة',
'${_formatMoney(_read(_debtsController))} جنيه',
),
_resultRow(
'صافي المال المحسوب',
'${_formatMoney(_netAssets)} جنيه',
),
const Divider(height: 28),
if (_nisab <= 0)
const Text(
'أدخل قيمة النصاب الصحيحة أولًا '
'للحصول على نتيجة تقديرية.',
)
else if (!_nisabReached)
const Text(
'المبلغ الصافي أقل من النصاب المدخل؛ '
'لا تظهر زكاة واجبة وفق هذه المدخلات.',
)
else if (!_hawlCompleted)
const Text(
'بلغ المال النصاب المدخل، لكنك لم تحدد '
'اكتمال الحول القمري.',
)
else ...[
Text(
'الزكاة التقديرية',
style: theme.textTheme.titleMedium,
),
const SizedBox(height: 8),
Text(
'${_formatMoney(_zakatAmount)} جنيه',
style: theme.textTheme.headlineMedium?.copyWith(
color: colors.primary,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
const Text(
'الحساب مبني على نسبة 2.5% من صافي '
'المبلغ المدخل، بشرط صحة إدراج الأصول '
'والخصومات شرعًا.',
),
],
],
),
),
],
const SizedBox(height: 20),
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: colors.secondaryContainer,
borderRadius: BorderRadius.circular(16),
),
child: Text(
'تنبيه شرعي: النصاب يتحدد بحسب معيار الذهب أو الفضة '
'وفق الفتوى المتبعة، وتختلف أحكام الذهب المستعمل '
'والديون والاستثمارات وبعض أنواع المال. '
'هذه الحاسبة تقديرية ولا تُصدر فتوى. '
'راجع جهة إفتاء موثوقة لتحديد النصاب والأموال '
'الواجبة فيها الزكاة.',
style: theme.textTheme.bodyMedium?.copyWith(
color: colors.onSecondaryContainer,
height: 1.7,
),
),
),
],
),
);
}

Widget _resultRow(String label, String value) {
final theme = Theme.of(context);

return Padding(
padding: const EdgeInsets.symmetric(vertical: 6),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(child: Text(label)),
const SizedBox(width: 12),
Flexible(
child: Text(
value,
textAlign: TextAlign.end,
style: theme.textTheme.bodyMedium?.copyWith(
fontWeight: FontWeight.bold,
),
),
),
],
),
);
}
}
