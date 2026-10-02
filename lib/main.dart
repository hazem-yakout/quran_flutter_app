import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'firebase_options.dart';

import 'package:quran/core/configs/theme/app_theme.dart';
import 'package:quran/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:quran/presentation/splash/pages/splash.dart';
import 'package:quran/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GetStorage.init();

  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // Light Mode
            theme: AppTheme.lightTheme,

            // Dark Mode
            darkTheme: AppTheme.darkTheme,

            // Current Theme
            themeMode: mode,

            home: const Splash(),
          );
        },
      ),
    );
  }
}