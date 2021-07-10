import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams/models/contact.dart';
import 'package:teams/models/message.dart';
import 'package:teams/models/user.dart';
import 'package:teams/provider/user_provider.dart';
import 'package:teams/utils/firebase_methods.dart';
import 'package:teams/utils/utils.dart';
import 'package:teams/widgets/chat_list_tile.dart';
import 'package:teams/widgets/dot_indicator.dart';
import 'package:teams/widgets/user_circle.dart';

import '../theme.dart';
import 'callscreens/pickup_screen.dart';
import 'chat_screen.dart';

/// chat list screen for showing all the contacts of the user with name and last message

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String currentUserId;
  String initials = '';

  final FirebaseMethods firebaseMethods = FirebaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseMethods.getCurrentUser().then((user) {
      setState(() {
        currentUserId = user.uid;
        initials = Utils.getInitials(user.displayName);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return PickupLayout(
      scaffold: Scaffold(
        //backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.orange,
          leading: UserCircle(),
          title: Text(
            "Chats",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Arial",
              fontSize: 24,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: firebaseMethods.fetchContacts(
                userId: userProvider.getUser.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var docList = snapshot.data.docs;

                  if (docList.isEmpty) {
                    return SingleChildScrollView(
                      child: Container(
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
                                  'assets/img/chat_img1.png',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Text(
                                "Start a new conversation \n with other users",
                                style: TextStyle(
                                  fontFamily: "Arial",
                                  fontSize: 26,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: docList.length,
                    itemBuilder: (context, index) {
                      Contact contact = Contact.fromMap(docList[index].data());

                      return FutureBuilder<UserModel>(
                        future: firebaseMethods.getUserDetailsById(contact.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            UserModel user = snapshot.data;

                            return ChatListTile(
                              mini: false,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      receiver: user,
                                      no: 1,
                                    ),
                                  )),
                              title: Text(
                                (contact != null ? user.name : null) != null
                                    ? user.name
                                    : "..",
                                style: TextStyle(
                                  //color: Colors.white,
                                  fontFamily: "Arial",
                                  fontSize: 19,
                                ),
                              ),
                              subtitle: LastMessageContainer(
                                stream: firebaseMethods.fetchLastMessageBetween(
                                  senderId: userProvider.getUser.uid,
                                  receiverId: contact.uid,
                                ),
                              ),
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
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        Utils.getInitials(user.name),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    DotIndicator(
                                      uid: contact.uid,
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
                  );
                }

                return Center(child: CircularProgressIndicator());
              }),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
              color: Colors.orange, borderRadius: BorderRadius.circular(50)),
          child: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search_screen');
            },
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: 25,
            ),
            padding: EdgeInsets.all(15),
          ),
        ),
      ),
    );
  }
}

class LastMessageContainer extends StatelessWidget {
  final stream;

  LastMessageContainer({
    @required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data.docs;

          if (docList.isNotEmpty) {
            Message message = Message.fromMap(docList.last.data());
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                message.message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            );
          }

          return Text(
            "No Message",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          );
        }
        return Text(
          "..",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        );
      },
    );
  }
}
