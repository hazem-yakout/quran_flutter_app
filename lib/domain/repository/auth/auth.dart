import 'package:dartz/dartz.dart';
import 'package:quran/data/models/auth/create_user.dart';

abstract class Auth {
  Future<Either> signup(CreateUserReq req);

  Future<Either> signin({
    required String email,
    required String password,
  });
}