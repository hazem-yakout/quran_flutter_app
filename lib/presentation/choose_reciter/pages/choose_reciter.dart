import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'package:quran/presentation/root/pages/root.dart';

class ChooseReciterPage extends StatefulWidget {
  const ChooseReciterPage({super.key});

  @override
  State<ChooseReciterPage> createState() =>
      _ChooseReciterPageState();
}

class _ChooseReciterPageState extends State<ChooseReciterPage> {
  final GetStorage storage = GetStorage();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  int selectedIndex = 0;
  bool isLoading = true;
  bool isSaving = false;

  final List<Map<String, String>> reciters = [
    {
      'name': 'محمود خليل الحصري',
      'type': 'حفص عن عاصم',
      'server': 'https://server13.mp3quran.net/husr/',
    },
    {
      'name': 'عبد الباسط عبد الصمد',
      'type': 'حفص عن عاصم',
      'server': 'https://server7.mp3quran.net/basit/',
    },
    {
      'name': 'محمد صديق المنشاوي',
      'type': 'حفص عن عاصم',
      'server': 'https://server10.mp3quran.net/minsh/',
    },
    {
      'name': 'محمود علي البنا',
      'type': 'حفص عن عاصم',
      'server': 'https://server8.mp3quran.net/bna/',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadSavedReciter();
  }

  Future<void> loadSavedReciter() async {
    // الاختيار المحفوظ محليًا كقيمة افتراضية.
    selectReciter(storage.read<String>('reciterName'));

    try {
      final user = auth.currentUser;

      if (user != null) {
        final doc = await firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();
          final cloudName = data?['reciterName'];

          if (cloudName is String) {
            selectReciter(cloudName);

            final index = reciters.indexWhere(
                  (item) => item['name'] == cloudName,
            );

            if (index != -1) {
              await saveLocally(reciters[index]);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load reciter: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void selectReciter(String? name) {
    if (name == null) return;

    final index = reciters.indexWhere(
          (item) => item['name'] == name,
    );

    if (index != -1) {
      selectedIndex = index;
    }
  }

  Future<void> saveLocally(
      Map<String, String> reciter,
      ) async {
    await storage.write('reciterName', reciter['name']);
    await storage.write('reciterType', reciter['type']);
    await storage.write('reciterServer', reciter['server']);
  }

  Future<void> continueToQuran() async {
    if (isLoading || isSaving) return;

    setState(() {
      isSaving = true;
    });

    final reciter = reciters[selectedIndex];

    try {
      // حفظ الاختيار على الجهاز.
      await saveLocally(reciter);

      // حفظ الاختيار في حساب المستخدم.
      final user = auth.currentUser;

      if (user != null) {
        await firestore.collection('users').doc(user.uid).set({
          'reciterName': reciter['name'],
          'reciterType': reciter['type'],
          'reciterServer': reciter['server'],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Root(
            reciterName: reciter['name']!,
            reciterServer: reciter['server']!,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Failed to save reciter: $e');

      // لو فشل الاتصال بالسحابة، يظل الاختيار محفوظًا محليًا.
      await saveLocally(reciter);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذرت المزامنة مع الإنترنت، تم حفظ الاختيار على الجهاز.',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Root(
            reciterName: reciter['name']!,
            reciterServer: reciter['server']!,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Choose Reciter',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/ka3ba.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                isDark ? 0.42 : 0.28,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.55)
                          : Colors.white.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mic_rounded,
                          color: Colors.green,
                          size: 42,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose your reciter',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'اختر القارئ المفضل لديك',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: reciters.length,
                      itemBuilder: (context, index) {
                        final reciter = reciters[index];
                        final selected =
                            selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.green.withOpacity(0.78)
                                  : isDark
                                  ? Colors.black.withOpacity(0.45)
                                  : Colors.white.withOpacity(0.70),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? Colors.green
                                    : Colors.white.withOpacity(0.20),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white.withOpacity(0.20)
                                        : Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.record_voice_over_rounded,
                                    color: Colors.white,
                                    size: 27,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        reciter['name']!,
                                        textDirection:
                                        TextDirection.rtl,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        reciter['type']!,
                                        textDirection:
                                        TextDirection.rtl,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: selected
                                      ? Colors.white
                                      : Colors.white70,
                                  size: 27,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading || isSaving
                          ? null
                          : continueToQuran,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}