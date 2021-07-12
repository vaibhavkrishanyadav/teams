import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams/models/group.dart';
import 'package:teams/provider/user_provider.dart';
import 'package:teams/screens/groupscreens/group_screen.dart';
import 'package:teams/utils/firebase_methods.dart';
import 'package:teams/widgets/chat_list_tile.dart';
import 'package:teams/widgets/user_circle.dart';

import '../../theme.dart';
import 'create_group.dart';
import 'join_group.dart';

// group list screen for showing all the groups in which the user is the member

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({Key key}) : super(key: key);

  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  FirebaseMethods firebaseMethods = FirebaseMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    print("hello");
    print(userProvider.user.name);

    void _goToJoin(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinGroup(
            currentUser: userProvider.user,
          ),
        ),
      );
    }

    void _goToCreate(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateGroup(
            currentUser: userProvider.user,
          ),
        ),
      );
    }

    return Scaffold(
      //backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: UserCircle(),
        title: Text(
          "Groups",
          style:
              TextStyle(color: Colors.white, fontFamily: "Arial", fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Row(
                      children: [
                        Text(
                          "Create",
                          style: TextStyle(
                            fontFamily: "Arial",
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.group),
                      ],
                    ),
                    onPressed: () => _goToCreate(context),
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: Theme.of(context).secondaryHeaderColor,
                        width: 2,
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Row(
                      children: [
                        Text(
                          "Join",
                          style: TextStyle(
                            fontFamily: "Arial",
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.group),
                      ],
                    ),
                    onPressed: () => _goToJoin(context),
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: Theme.of(context).secondaryHeaderColor,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: RefreshIndicator(
                onRefresh: userProvider.refreshUser,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: userProvider.user.groups.length,
                  itemBuilder: (context, index) {
                    print(userProvider.user.groups.length);
                    //GroupModel contact = Contact.fromMap(docList[index].data());
                    print(userProvider.user.groups[index]);
                    if ((userProvider.user.groups[index] == "" && userProvider.user.groups.length == 1) || userProvider.user.groups.length == 0) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 75.0),
                              child: Image(
                                height: MediaQuery.of(context).size.height > 800
                                    ? 300.0
                                    : 250,
                                fit: BoxFit.fill,
                                image: const AssetImage(
                                  'assets/img/chat_img.png',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Text(
                                "Join or create a group and \n start group video call",
                                style: TextStyle(
                                  fontFamily: "Arial",
                                  fontSize: 26,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return FutureBuilder<GroupModel>(
                      future: firebaseMethods
                          .getGroupData(userProvider.user.groups[index]),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          GroupModel group = snapshot.data;
                          print(group);
                          return ChatListTile(
                            mini: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupScreen(
                                    group: group,
                                    currentUser: userProvider.user,
                                  ),
                                ),
                              );
                            },
                            title: Text(
                              (group != null ? group.name : null) != null
                                  ? group.name
                                  : "..",
                              style: TextStyle(
                                //color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Arial",
                                fontSize: 19,
                              ),
                            ),
                            subtitle: Text(""),
                            leading: Container(
                              constraints:
                                  BoxConstraints(maxHeight: 60, maxWidth: 60),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(80),
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    CustomTheme.loginGradientStart,
                                    CustomTheme.loginGradientEnd
                                  ],
                                  begin: FractionalOffset(0.0, 0.0),
                                  end: FractionalOffset(1.0, 1.0),
                                  stops: <double>[0.0, 1.0],
                                  tileMode: TileMode.clamp,
                                ),
                              ),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(15),
                                    child: Icon(
                                      Icons.group,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
