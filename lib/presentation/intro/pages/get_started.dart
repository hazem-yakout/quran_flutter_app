import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran/common/widgets/button/basic_app_button.dart';
import 'package:quran/core/configs/assets/app_images.dart';
import 'package:quran/core/configs/assets/app_vectors.dart';
import 'package:quran/core/configs/theme/app_colors.dart';

class GetStartedPage extends StatelessWidget {
  final PageController pageController;

  const GetStartedPage({
    super.key,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppImages.download,
              fit: BoxFit.fill,
            ),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(
                    AppVectors.logo,
                    width: 100,
                    height: 100,
                  ),
                ),

                const Spacer(),

                const Text(
                  'Enjoy Listening to El-Quran EL-Kareem',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 21),

                Text(
                  'By Mahmoud khalil El-Hossary',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 21),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BasicAppButton(
                    onPressed: () {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    title: "Get Started",
                  ),
                ),

                const SizedBox(height: 21),
              ],
            ),
          ),
        ],
      ),
    );
  }
}