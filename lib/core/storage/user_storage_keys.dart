import 'package:firebase_auth/firebase_auth.dart';

class UserStorageKeys {
  static String key(String name) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No authenticated user');
    }

    return '${user.uid}_$name';
  }
}