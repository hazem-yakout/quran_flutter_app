import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran/core/configs/assets/app_vectors.dart';
import 'package:quran/presentation/intro_page/pages/intro_page.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  late Animation<double> imageAnimation;
  late Animation<double> logoFadeAnimation;
  late Animation<Offset> logoSlideAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    imageAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ),
    );

    logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.3,
          1.0,
          curve: Curves.easeIn,
        ),
      ),
    );

    logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.3,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    animationController.forward();

    redirect();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: imageAnimation,
              child: Image.asset(
                AppVectors.image,
                height:
                MediaQuery.of(context).size.height * 0.25,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 24),

            FadeTransition(
              opacity: logoFadeAnimation,
              child: SlideTransition(
                position: logoSlideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: SvgPicture.asset(
                    AppVectors.logo,
                    height: 120,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      isDarkMode
                          ? Colors.white
                          : Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const IntroPages(),
      ),
    );
  }
}