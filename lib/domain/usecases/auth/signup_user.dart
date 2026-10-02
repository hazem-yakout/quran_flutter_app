import 'package:dartz/dartz.dart';
import 'package:quran/core/usecase/usecase.dart';
import 'package:quran/data/models/auth/create_user.dart';
import 'package:quran/domain/repository/auth/auth.dart';

class SignupUser implements UseCase<Either, CreateUserReq> {
  final Auth auth;

  SignupUser(this.auth);

  @override
  Future<Either> call({CreateUserReq? params}) async {
    return await auth.signup(params!);
  }
}