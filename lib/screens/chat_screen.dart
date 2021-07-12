import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teams/models/message.dart';
import 'package:teams/models/user.dart';
import 'package:teams/screens/callscreens/pickup_screen.dart';
import 'package:teams/utils/call_methods.dart';
import 'package:teams/utils/firebase_methods.dart';

/// chat screen widget for chatting with user's contacts and doing video call

class ChatScreen extends StatefulWidget {
  final UserModel receiver;
  final int no;

  ChatScreen({this.receiver, this.no});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  FirebaseMethods firebaseMethods = FirebaseMethods();

  UserModel sender;

  String _currentUserId;

  bool isWriting = false;

  @override
  void initState() {
    super.initState();

    firebaseMethods.getCurrentUser().then((user) {
      _currentUserId = user.uid;

      setState(() {
        sender = UserModel(
          uid: user.uid,
          name: user.displayName,
          //profilePhoto: user.photoUrl,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        //backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.orange,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: false,
          title: Text(
            widget.receiver.name,
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Arial",
              fontSize: 24,
            ),
          ),
          actions: <Widget>[
            (widget.no == 1)
                ? Container()
                : IconButton(
                    icon: Icon(
                      Icons.video_call,
                    ),
                    onPressed: () async {
                      await _handleCameraAndMic(Permission.camera);
                      await _handleCameraAndMic(Permission.microphone);
                      CallUtils.dial(
                        from: sender,
                        to: widget.receiver,
                        context: context,
                      );
                    },
                  ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              child: messageList(),
            ),
            chatControls(),
          ],
        ),
      ),
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("messages")
          .doc(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.docs.length,
          reverse: true,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.docs[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(QueryDocumentSnapshot<Object> snapshot) {
    Message message = Message.fromMap(snapshot.data());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: message.senderId == _currentUserId
            ? senderLayout(message)
            : receiverLayout(message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  getMessage(Message message) {
    return SelectableText(
      message.message,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
      toolbarOptions: ToolbarOptions(
        copy: true,
        selectAll: true,
      ),
      showCursor: true,
      cursorWidth: 2,
      cursorColor: Colors.blue,
      cursorRadius: Radius.circular(5),
    );
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    sendMessage() {
      var text = textFieldController.text;

      Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: sender.uid,
        message: text,
        timestamp: Timestamp.now(),
        type: 'text',
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      firebaseMethods.addMessageToDb(_message, sender, widget.receiver);
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: textFieldController,
              style: TextStyle(
                  //color: Colors.white,
                  ),
              onChanged: (val) {
                (val.length > 0 && val.trim() != "")
                    ? setWritingTo(true)
                    : setWritingTo(false);
              },
              decoration: InputDecoration(
                hintText: "Type a message",
                hintStyle: TextStyle(
                  color: Color(0xff8f8f8f),
                ),
                border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(50.0),
                    ),
                    borderSide: BorderSide.none),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                filled: true,
                //fillColor: Color(0xff272c35),
                // suffixIcon: GestureDetector(
                //   onTap: () {},
                //   child: Icon(Icons.face),
                // ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   colors: [
                //     CustomTheme.loginGradientStart,
                //     CustomTheme.loginGradientEnd,
                //   ],
                // ),
                color: Colors.orange,
                shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(
                Icons.send,
                size: 15,
              ),
              onPressed: () => isWriting ? sendMessage() : {},
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}

// class ModalTile extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//
//   const ModalTile({
//     @required this.title,
//     @required this.subtitle,
//     @required this.icon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 15),
//       child: ChatListTile(
//         mini: false,
//         leading: Container(
//           margin: EdgeInsets.only(right: 10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             color: Colors.orange,
//           ),
//           padding: EdgeInsets.all(10),
//           child: Icon(
//             icon,
//             color: Color(0xff8f8f8f),
//             size: 38,
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: TextStyle(
//             color: Color(0xff8f8f8f),
//             fontSize: 14,
//           ),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//       ),
//     );
//   }
// }
