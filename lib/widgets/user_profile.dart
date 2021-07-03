import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams/models/user.dart';
import 'package:teams/provider/user_provider.dart';
import 'package:teams/screens/loginScreen.dart';
import 'package:teams/utils/firebase_methods.dart';
import 'package:teams/utils/utils.dart';

import 'custom_appbar.dart';

class UserProfile extends StatelessWidget {
  //const UserProfile({Key key}) : super(key: key);
  final FirebaseMethods firebaseMethods = FirebaseMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    final UserModel userModel = userProvider.getUser;

    signOut() async {
      final bool isLoggedOut = await firebaseMethods.signOut();
      if (isLoggedOut) {
        // set userState to offline as the user logs out'
        firebaseMethods.setUserState(
          userId: userProvider.getUser.uid,
          userState: UserState.Offline,
        );

        // move the user to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 25),
      child: Column(
        children: <Widget>[
          CustomAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
            title: Center(
              child: Text("Profile"),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => signOut(),
                child: Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.grey,
                  ),
                ),
                // CachedImage(
                //   user.profilePhoto,
                //   isRound: true,
                //   radius: 50,
                // ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userModel.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userModel.email,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
