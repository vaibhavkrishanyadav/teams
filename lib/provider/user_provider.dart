import 'package:flutter/widgets.dart';
import 'package:teams/models/user.dart';
import 'package:teams/utils/firebase_methods.dart';

/// this is a user provider used for getting the user details from firebase

class UserProvider with ChangeNotifier {
  UserModel user;
  FirebaseMethods firebaseMethods = FirebaseMethods();

  UserModel get getUser => user;

  Future<void> refreshUser() async {
    UserModel user1 = await firebaseMethods.getUserDetails();
    user = user1;
    notifyListeners();
  }

}