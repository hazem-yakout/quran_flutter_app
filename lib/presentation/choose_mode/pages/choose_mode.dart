import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:quran/common/widgets/button/basic_app_button.dart';
import 'package:quran/core/configs/assets/app_images.dart';
import 'package:quran/core/configs/assets/app_vectors.dart';
import 'package:quran/presentation/auth/pages/signin_or_signup.dart';
import 'package:quran/presentation/choose_mode/bloc/theme_cubit.dart';

class ChooseMode extends StatelessWidget {
  final PageController pageController;

  const ChooseMode({
    super.key,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        context.watch<ThemeCubit>().state == ThemeMode.dark;

    final textColor =
    isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.lightdark,
              fit: BoxFit.fill,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.6)
                  : Colors.white.withOpacity(0.6),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(
                    AppVectors.log,
                    width: 100,
                    height: 100,
                  ),
                ),

                const Spacer(),

                Text(
                  'Choose Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 21),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context
                            .read<ThemeCubit>()
                            .updateTheme(ThemeMode.dark);
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dark_mode,
                              color: textColor,
                              size: 50,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    GestureDetector(
                      onTap: () {
                        context
                            .read<ThemeCubit>()
                            .updateTheme(ThemeMode.light);
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: !isDarkMode
                              ? Colors.black.withOpacity(0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: !isDarkMode
                                ? Colors.black
                                : Colors.white30,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.light_mode,
                              color: textColor,
                              size: 50,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Light Mode',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: BasicAppButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const SigninOrSignup(),
                        ),
                      );
                    },
                    title: 'Continue',
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}