import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:teams/models/user.dart';
import 'package:teams/utils/firebase_repo.dart';


class UserProvider with ChangeNotifier {
  UserModel user;
  FirebaseRepo repo = FirebaseRepo();

  UserModel get getUser => user;

  Future<void> refreshUser() async {
    UserModel user1 = await repo.getUserDetails();
    user = user1;
    notifyListeners();
  }

}