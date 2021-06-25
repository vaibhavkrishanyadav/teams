import 'package:firebase_auth/firebase_auth.dart';
import 'package:teams/utils/firebase_methods.dart';

class FirebaseRepo {
  FirebaseMethods firebaseMethods = FirebaseMethods();

  Future<User> getCurrentUser() => firebaseMethods.getCurrentUser();

  Future<User> signInWithGoogle() => firebaseMethods.signInWithGoogle();

  Future<bool> authenticateUser(User user) => firebaseMethods.authenticateUser(user);

  Future<void> addDataToDB(User user) => firebaseMethods.addDataToDB(user);

  Future<void> signOut() => firebaseMethods.signOut();
}