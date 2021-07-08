import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId, receiverId, type, message, photoUrl;
  Timestamp timestamp;

  Message({this.senderId, this.receiverId, this.type, this.message, this.timestamp});

  //to send image
  //Message.imageMessage({this.senderId, this.receiverId, this.message, this.type, this.timestamp, this.photoUrl});

  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    return map;
  }

  Message.fromMap(Map<String, dynamic> map) {
    this.senderId = map['senderId'];
    this.receiverId = map['receiverId'];
    this.type = map['type'];
    this.message = map['message'];
    this.timestamp = map['timestamp'];
  }


}