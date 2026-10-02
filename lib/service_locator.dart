import 'package:get_it/get_it.dart';

import 'package:quran/data/repository/auth/auth_repository_impl.dart';
import 'package:quran/data/sources/auth/auth_firebase.dart';

import 'package:quran/domain/repository/auth/auth.dart';

import 'package:quran/domain/usecases/auth/signup_user.dart';
import 'package:quran/domain/usecases/auth/signin_user.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Firebase Data Source
  sl.registerSingleton<AuthFirebase>(
    AuthFirebaseImpl(),
  );

  // Repository
  sl.registerSingleton<Auth>(
    AuthRepositoryImpl(
      sl<AuthFirebase>(),
    ),
  );

  // Signup UseCase
  sl.registerSingleton<SignupUser>(
    SignupUser(
      sl<Auth>(),
    ),
  );

  // Signin UseCase
  sl.registerSingleton<SigninUser>(
    SigninUser(
      sl<Auth>(),
    ),
  );
}