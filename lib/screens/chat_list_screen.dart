import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams/models/contact.dart';
import 'package:teams/models/message.dart';
import 'package:teams/models/user.dart';
import 'package:teams/provider/user_provider.dart';
import 'package:teams/utils/firebase_methods.dart';
import 'package:teams/utils/firebase_repo.dart';
import 'package:teams/utils/utils.dart';
import 'package:teams/widgets/chat_list_tile.dart';
import 'package:teams/widgets/custom_appbar.dart';
import 'package:teams/widgets/dot_indicator.dart';
import 'package:teams/widgets/user_profile.dart';

import 'callscreens/pickup_screen.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

final FirebaseRepo repo = FirebaseRepo();

class _ChatListScreenState extends State<ChatListScreen> {
  String currentUserId;
  String initials = '';

  final FirebaseMethods firebaseMethods = FirebaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    repo.getCurrentUser().then((user) {
      setState(() {
        currentUserId = user.uid;
        initials = Utils.getInitials(user.displayName);
      });
    });
  }

  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.notifications,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      title: UserCircle(),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/search_screen');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        appBar: customAppBar(context),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: firebaseMethods.fetchContacts(
                userId: userProvider.getUser.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var docList = snapshot.data.docs;

                  // if (docList.isEmpty) {
                  //   return QuietBox();
                  // }
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
                                    ),
                                  )),
                              title: Text(
                                (contact != null ? user.name : null) != null
                                    ? user.name
                                    : "..",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Arial",
                                    fontSize: 19),
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
                                child: Stack(
                                  children: <Widget>[
                                    // CachedImage(
                                    //   contact.profilePhoto,
                                    //   radius: 80,
                                    //   isRound: true,
                                    // ),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.grey,
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
                          return Center(
                            child: CircularProgressIndicator(),
                          );
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
              color: Colors.blue, borderRadius: BorderRadius.circular(50)),
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: 25,
          ),
          padding: EdgeInsets.all(15),
        ),
      ),
    );
  }
}

class UserCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.black,
        builder: (context) => UserProfile(),
      ),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.grey,
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                Utils.getInitials(userProvider.getUser.name),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                  fontSize: 13,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                    color: Colors.green),
              ),
            )
          ],
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