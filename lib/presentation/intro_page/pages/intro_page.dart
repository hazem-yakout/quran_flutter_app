import 'package:flutter/material.dart';
import 'package:quran/presentation/intro/pages/get_started.dart';
import 'package:quran/presentation/choose_mode/pages/choose_mode.dart';

class IntroPages extends StatefulWidget {
  const IntroPages({super.key});

  @override
  State<IntroPages> createState() => _IntroPagesState();
}

class _IntroPagesState extends State<IntroPages> {
  final PageController pageController = PageController();

  int currentPage = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: pageController,

            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },

            children: [
              GetStartedPage(
                pageController: pageController,
              ),

              ChooseMode(
                pageController: pageController,
              ),
            ],
          ),

          // Page Indicator
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator(
                  isActive: currentPage == 0,
                ),

                const SizedBox(width: 8),

                _buildIndicator(
                  isActive: currentPage == 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator({
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 30 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}