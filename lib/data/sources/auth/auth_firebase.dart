import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quran/data/models/auth/create_user.dart';

abstract class AuthFirebase {
  Future<Either> signup(CreateUserReq req);

  Future<Either> signin({
    required String email,
    required String password,
  });
}

class AuthFirebaseImpl implements AuthFirebase {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Future<Either> signup(CreateUserReq req) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: req.email,
        password: req.password,
      );

      return const Right('Signup successful');
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Signup failed');
    }
  }

  @override
  Future<Either> signin({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return const Right('Signin successful');
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Signin failed');
    }
  }
}