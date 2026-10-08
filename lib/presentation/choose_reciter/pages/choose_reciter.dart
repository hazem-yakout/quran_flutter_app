import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'package:quran/presentation/root/pages/root.dart';

class ChooseReciterPage extends StatefulWidget {
  const ChooseReciterPage({super.key});

  @override
  State<ChooseReciterPage> createState() =>
      _ChooseReciterPageState();
}

class _ChooseReciterPageState
    extends State<ChooseReciterPage> {
  final GetStorage storage = GetStorage();

  int selectedIndex = 0;

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

    final String? savedReciter =
    storage.read('reciterName');

    if (savedReciter != null) {
      final int index = reciters.indexWhere(
            (reciter) =>
        reciter['name'] == savedReciter,
      );

      if (index != -1) {
        selectedIndex = index;
      }
    }
  }

  void continueToQuran() {
    final Map<String, String> reciter =
    reciters[selectedIndex];

    storage.write(
      'reciterName',
      reciter['name'],
    );

    storage.write(
      'reciterType',
      reciter['type'],
    );

    storage.write(
      'reciterServer',
      reciter['server'],
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
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

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
          // =========================
          // BACKGROUND
          // =========================

          Positioned.fill(
            child: Image.asset(
              'assets/images/ka3ba.webp',
              fit: BoxFit.cover,
            ),
          ),

          // =========================
          // DARK OVERLAY
          // =========================

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                isDark ? 0.42 : 0.28,
              ),
            ),
          ),

          // =========================
          // CONTENT
          // =========================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),

              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // =========================
                  // TITLE CARD
                  // =========================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),

                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black
                          .withOpacity(0.55)
                          : Colors.white
                          .withOpacity(0.72),

                      borderRadius:
                      BorderRadius.circular(20),

                      border: Border.all(
                        color: Colors.white
                            .withOpacity(0.25),
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
                            fontWeight:
                            FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'اختر القارئ المفضل لديك',
                          textDirection:
                          TextDirection.rtl,
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

                  // =========================
                  // RECITERS
                  // =========================

                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: reciters.length,

                      itemBuilder:
                          (context, index) {
                        final Map<String, String>
                        reciter =
                        reciters[index];

                        final bool selected =
                            selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex =
                                  index;
                            });
                          },

                          child: Container(
                            margin:
                            const EdgeInsets.only(
                              bottom: 10,
                            ),

                            padding:
                            const EdgeInsets.all(
                              13,
                            ),

                            decoration:
                            BoxDecoration(
                              color: selected
                                  ? Colors.green
                                  .withOpacity(
                                0.78,
                              )
                                  : isDark
                                  ? Colors.black
                                  .withOpacity(
                                0.45,
                              )
                                  : Colors.white
                                  .withOpacity(
                                0.70,
                              ),

                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),

                              border: Border.all(
                                color: selected
                                    ? Colors.green
                                    : Colors.white
                                    .withOpacity(
                                  0.20,
                                ),
                                width: selected
                                    ? 2
                                    : 1,
                              ),
                            ),

                            child: Row(
                              children: [
                                // MIC ICON
                                Container(
                                  width: 52,
                                  height: 52,

                                  decoration:
                                  BoxDecoration(
                                    color: selected
                                        ? Colors.white
                                        .withOpacity(
                                      0.20,
                                    )
                                        : Colors.green,

                                    shape:
                                    BoxShape.circle,
                                  ),

                                  child: Icon(
                                    Icons
                                        .record_voice_over_rounded,
                                    color:
                                    Colors.white,
                                    size: 27,
                                  ),
                                ),

                                const SizedBox(
                                  width: 13,
                                ),

                                // NAME
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .end,

                                    children: [
                                      Text(
                                        reciter['name']!,
                                        textDirection:
                                        TextDirection
                                            .rtl,

                                        style:
                                        TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                          FontWeight
                                              .bold,

                                          color:
                                          Colors.white,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        reciter['type']!,
                                        textDirection:
                                        TextDirection
                                            .rtl,

                                        style:
                                        const TextStyle(
                                          fontSize: 12,
                                          color:
                                          Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                // RADIO
                                Icon(
                                  selected
                                      ? Icons
                                      .radio_button_checked
                                      : Icons
                                      .radio_button_off,

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

                  // =========================
                  // CONTINUE BUTTON
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed:
                      continueToQuran,

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.green,

                        foregroundColor:
                        Colors.white,

                        elevation: 5,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),

                      child: const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          SizedBox(width: 8),

                          Icon(
                            Icons.arrow_forward_rounded,
                          ),
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