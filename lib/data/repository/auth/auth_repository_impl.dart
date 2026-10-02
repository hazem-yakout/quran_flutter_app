import 'package:dartz/dartz.dart';
import 'package:quran/data/models/auth/create_user.dart';
import 'package:quran/data/sources/auth/auth_firebase.dart';
import 'package:quran/domain/repository/auth/auth.dart';

class AuthRepositoryImpl implements Auth {
  final AuthFirebase authFirebase;

  AuthRepositoryImpl(this.authFirebase);

  @override
  Future<Either> signup(CreateUserReq req) async {
    return await authFirebase.signup(req);
  }

  @override
  Future<Either> signin({
    required String email,
    required String password,
  }) async {
    return await authFirebase.signin(
      email: email,
      password: password,
    );
  }
}