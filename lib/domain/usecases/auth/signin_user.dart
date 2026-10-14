import 'package:dartz/dartz.dart';
import 'package:quran/core/usecase/usecase.dart';
import 'package:quran/domain/repository/auth/auth.dart';

class SigninUser implements UseCase<Either, SigninParams> {
final Auth auth;

SigninUser(this.auth);

@override
Future<Either> call({SigninParams? params}) async {
if (params == null) {
return Left('Signin parameters are missing');
}

return await auth.signin(
email: params.email.trim(),
password: params.password,
);
}
}

class SigninParams {
final String email;
final String password;

SigninParams({
required this.email,
required this.password,
});
}
