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
email: req.email.trim(),
password: req.password,
);

return const Right('Signup successful');
} on FirebaseAuthException catch (e) {
print('Firebase Signup Error Code: ${e.code}');
print('Firebase Signup Error Message: ${e.message}');

return Left(e.message ?? 'Signup failed');
} catch (e) {
print('Unexpected Signup Error: $e');
return Left('Signup failed');
}
}

@override
Future<Either> signin({
required String email,
required String password,
}) async {
try {
await firebaseAuth.signInWithEmailAndPassword(
email: email.trim(),
password: password,
);

return const Right('Signin successful');
} on FirebaseAuthException catch (e) {
print('Firebase Auth Error Code: ${e.code}');
print('Firebase Auth Error Message: ${e.message}');

return Left(e.message ?? 'Signin failed');
} catch (e) {
print('Unexpected Signin Error: $e');
return Left('Signin failed');
}
}
}
