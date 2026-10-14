import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quran/flutter_quran.dart';
import 'package:flutter_quran/src/utils/string_extensions.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'app_bloc.dart';
import 'controllers/bookmarks_controller.dart';
import 'controllers/quran_controller.dart';
import 'models/quran_constants.dart';
import 'models/quran_page.dart';

part 'utils/images.dart';
part 'utils/toast_utils.dart';
part 'widgets/bsmallah_widget.dart';
part 'widgets/quran_line.dart';
part 'widgets/quran_page_bottom_info.dart';
part 'widgets/surah_header_widget.dart';
part 'widgets/default_drawer.dart';
part 'widgets/ayah_long_click_dialog.dart';

class FlutterQuranScreen extends StatelessWidget {
const FlutterQuranScreen({
this.showBottomWidget = true,
this.useDefaultAppBar = true,
this.bottomWidget,
this.appBar,
this.onPageChanged,
this.onAyahTap,
super.key,
});

final bool showBottomWidget;
final bool useDefaultAppBar;
final Widget? bottomWidget;
final PreferredSizeWidget? appBar;
final Function(int)? onPageChanged;
final Function(Ayah)? onAyahTap;

@override
Widget build(BuildContext context) {
final deviceSize = MediaQuery.of(context).size;
final Orientation currentOrientation =
MediaQuery.of(context).orientation;

return MultiBlocProvider(
providers: AppBloc.providers,
child: MaterialApp(
debugShowCheckedModeBanner: false,
theme: ThemeData(
useMaterial3: false,
),
home: Directionality(
textDirection: TextDirection.rtl,
child: Scaffold(
appBar: appBar ??
(useDefaultAppBar
? AppBar(
elevation: 0,
backgroundColor: Colors.transparent,
iconTheme:
const IconThemeData(color: Colors.black),
)
    : null),
drawer: appBar == null && useDefaultAppBar
? const _DefaultDrawer()
    : null,
body: BlocBuilder<QuranCubit, List<QuranPage>>(
builder: (ctx, pages) {
if (pages.isEmpty) {
return const Center(
child: CircularProgressIndicator(),
);
}

return SafeArea(
child: PageView.builder(
itemCount: pages.length,
controller: AppBloc.quranCubit.pageController,
onPageChanged: (page) {
onPageChanged?.call(page);
AppBloc.quranCubit.saveLastPage(page + 1);
},
pageSnapping: true,
itemBuilder: (ctx, index) {
final List<String> newSurahs = [];

return Container(
height: deviceSize.height * 0.8,
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
Expanded(
child: index == 0 || index == 1
? Center(
child: SingleChildScrollView(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
SurahHeaderWidget(
pages[index]
    .ayahs[0]
    .surahNameAr,
),
if (index == 1)
BasmallahWidget(
pages[index]
    .ayahs[0]
    .surahNumber,
),
...pages[index]
    .lines
    .map((line) {
return BlocBuilder<
BookmarksCubit,
List<Bookmark>>(
builder:
(context, bookmarks) {
final bookmarksAyahs =
bookmarks
    .map((bookmark) =>
bookmark.ayahId)
    .toList();

return Column(
children: [
SizedBox(
width:
deviceSize.width -
32,
child: QuranLine(
line,
bookmarksAyahs,
bookmarks,
boxFit: BoxFit
    .scaleDown,
onAyahTap:
onAyahTap,
),
),
],
);
},
);
}),
],
),
),
)
    : LayoutBuilder(
builder:
(context, constraints) {
return ListView(
physics:
currentOrientation ==
Orientation.portrait
? const NeverScrollableScrollPhysics()
    : null,
children: [
...pages[index]
    .lines
    .map((line) {
bool firstAyah = false;

if (line.ayahs[0]
    .ayahNumber ==
1 &&
!newSurahs.contains(
line.ayahs[0]
    .surahNameAr,
)) {
newSurahs.add(
line.ayahs[0]
    .surahNameAr,
);
firstAyah = true;
}

return BlocBuilder<
BookmarksCubit,
List<Bookmark>>(
builder:
(context, bookmarks) {
final bookmarksAyahs =
bookmarks
    .map((bookmark) =>
bookmark.ayahId)
    .toList();

return Column(
children: [
if (firstAyah)
SurahHeaderWidget(
line.ayahs[0]
    .surahNameAr,
),
if (firstAyah &&
line.ayahs[0]
    .surahNumber !=
9)
BasmallahWidget(
line.ayahs[0]
    .surahNumber,
),
SizedBox(
width:
deviceSize.width -
30,
height:
((currentOrientation ==
Orientation
    .portrait
? constraints
    .maxHeight
    : deviceSize
    .width) -
(pages[index]
    .numberOfNewSurahs *
(line.ayahs[0].surahNumber !=
9
? 110
    : 80))) *
0.95 /
pages[index]
    .lines
    .length,
child: QuranLine(
line,
bookmarksAyahs,
bookmarks,
boxFit: line
    .ayahs
    .last
    .centered
? BoxFit
    .scaleDown
    : BoxFit.fill,
onAyahTap:
onAyahTap,
),
),
],
);
},
);
}),
],
);
},
),
),
bottomWidget ??
(showBottomWidget
? QuranPageBottomInfoWidget(
page: index + 1,
hizb: pages[index].hizb,
surahName: pages[index]
    .ayahs
    .last
    .surahNameAr,
)
    : Container()),
],
),
);
},
),
);
},
),
),
),
),
);
}
}

class _FlutterQuranSearchScreen extends StatefulWidget {
const _FlutterQuranSearchScreen();

@override
State<_FlutterQuranSearchScreen> createState() =>
_FlutterQuranSearchScreenState();
}

class _FlutterQuranSearchScreenState
extends State<_FlutterQuranSearchScreen> {
List<Ayah> ayahs = [];

@override
Widget build(BuildContext context) {
return Directionality(
textDirection: TextDirection.rtl,
child: Scaffold(
appBar: AppBar(
title: const Text('بحث'),
centerTitle: true,
),
body: SafeArea(
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
mainAxisSize: MainAxisSize.max,
children: [
TextField(
onChanged: (txt) {
final searchResult =
FlutterQuran().search(txt);

setState(() {
ayahs = [...searchResult];
});
},
decoration: const InputDecoration(
border: OutlineInputBorder(
borderSide: BorderSide(color: Colors.black),
),
hintText: 'بحث',
),
),
Expanded(
child: ListView(
children: ayahs
    .map(
(ayah) => Column(
children: [
ListTile(
title: Text(
ayah.ayah.replaceAll('\n', ' '),
),
subtitle: Text(ayah.surahNameAr),
contentPadding:
const EdgeInsets.symmetric(
horizontal: 16,
),
onTap: () {
Navigator.of(context).pop();
FlutterQuran()
    .navigateToAyah(ayah);
},
),
const Divider(
color: Colors.grey,
thickness: 1,
),
],
),
)
    .toList(),
),
),
],
),
),
),
),
);
}
}
