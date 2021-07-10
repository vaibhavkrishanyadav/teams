import 'package:flutter/material.dart';
import 'package:teams/models/user.dart';
import 'package:teams/utils/firebase_methods.dart';

/// Create group widget for creating the new group with group name

class CreateGroup extends StatefulWidget {
  final UserModel currentUser;

  CreateGroup({this.currentUser});

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  TextEditingController _groupNameController = TextEditingController();
  final FirebaseMethods firebaseMethods = FirebaseMethods();

  void createGroup(BuildContext context, String groupName) async {
    String _returnString =
        await firebaseMethods.createGroup(groupName, widget.currentUser);
    if (_returnString == "success") {
      Navigator.pop(context);
    } else {
      SnackBar(
        content: Text(_returnString),
        duration: Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[BackButton()],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(
                      4.0,
                      4.0,
                    ),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _groupNameController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.group,
                        color: Colors.black54,
                      ),
                      hintText: "Group Name",
                      hintStyle: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                    color: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 80),
                      child: Text(
                        "Create Group",
                        style: TextStyle(
                          //color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      createGroup(context, _groupNameController.text);
                    },
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
