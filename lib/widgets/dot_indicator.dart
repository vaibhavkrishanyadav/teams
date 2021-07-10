import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teams/models/user.dart';
import 'package:teams/utils/firebase_methods.dart';
import 'package:teams/utils/utils.dart';

/// dot indicator used for showing whether the user is online or offline

class DotIndicator extends StatelessWidget {
  //const DotIndicator({Key key}) : super(key: key);

  final String uid;
  final FirebaseMethods methods = FirebaseMethods();

  DotIndicator({
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return Colors.red;
        case UserState.Online:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return Align(
      alignment: Alignment.topRight,
      child: StreamBuilder<DocumentSnapshot>(
        stream: methods.getUserStream(
          uid: uid,
        ),
        builder: (context, snapshot) {
          UserModel user;

          if (snapshot.hasData && snapshot.data.data() != null) {
            user = UserModel.fromMap(snapshot.data.data());
          }

          return Container(
            height: 10,
            width: 10,
            margin: EdgeInsets.only(right: 5, top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getColor(user?.state),
            ),
          );
        },
      ),
    );
  }
}
