import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teams/models/group.dart';
import 'package:teams/models/user.dart';
import 'package:teams/screens/groupscreens/group_call.dart';
import 'package:teams/utils/firebase_methods.dart';
import 'package:clipboard/clipboard.dart';

// Group screen for starting the group video call

class GroupScreen extends StatefulWidget {
  final GroupModel group;
  final UserModel currentUser;

  GroupScreen({
    this.group,
    this.currentUser,
  });

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  FirebaseMethods firebaseMethods = FirebaseMethods();

  ClientRole role = ClientRole.Broadcaster;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          widget.group.name,
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Arial",
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.red,
            ),
            child: TextButton(
              onPressed: () async {
                String _returnString = await firebaseMethods.leaveGroup(
                    widget.group.uid, widget.currentUser);
                if (_returnString == "success") {
                  Navigator.pop(context);
                } else {
                  SnackBar(
                    content: Text(_returnString),
                    duration: Duration(seconds: 2),
                  );
                }
              },
              child: Text(
                "Leave",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Arial",
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "UID:  " + widget.group.uid,
                    style: TextStyle(
                      //color: Colors.white,
                      fontFamily: "Arial",
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.content_copy),
                    onPressed: () async {
                      await FlutterClipboard.copy(widget.group.uid);
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 100,
              ),
              ListTile(
                title: Text("Join as Presenter"),
                leading: Radio(
                  value: ClientRole.Broadcaster,
                  groupValue: role,
                  activeColor: Colors.orange,
                  onChanged: (ClientRole value) {
                    setState(() {
                      role = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text("Join as Audience"),
                leading: Radio(
                  value: ClientRole.Audience,
                  groupValue: role,
                  activeColor: Colors.orange,
                  onChanged: (ClientRole value) {
                    setState(() {
                      role = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: RaisedButton(
                  onPressed: onJoin,
                  child: Text('Join'),
                  color: Colors.orange,
                  textColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // update input validation
    if (widget.group.uid.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupCall(
            channelName: widget.group.uid,
            role: role,
          ),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
