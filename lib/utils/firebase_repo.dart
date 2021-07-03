import 'package:firebase_auth/firebase_auth.dart';
import 'package:teams/models/message.dart';
import 'package:teams/models/user.dart';
import 'package:teams/utils/firebase_methods.dart';

class FirebaseRepo {
  FirebaseMethods firebaseMethods = FirebaseMethods();

  Future<User> getCurrentUser() => firebaseMethods.getCurrentUser();

  Future<UserModel> getUserDetails() => firebaseMethods.getUserDetails();

  Future<User> signInWithGoogle() => firebaseMethods.signInWithGoogle();

  Future<bool> authenticateUser(User user) => firebaseMethods.authenticateUser(user);

  Future<void> addDataToDB(User user) => firebaseMethods.addDataToDB(user);

  Future<void> signOut() => firebaseMethods.signOut();

  Future<List<UserModel>> fetchAllUsers(User user) =>
      firebaseMethods.fetchAllUsers(user);

  Future<void> addMessageToDb(Message message, UserModel sender, UserModel receiver) =>
      firebaseMethods.addMessageToDb(message, sender, receiver);
}