import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String uid;
  String name;
  String leader;
  List<String> members;
  Timestamp groupCreated;

  GroupModel({
    this.uid,
    this.name,
    this.leader,
    this.members,
    this.groupCreated,
  });

  Map toMap() {
    var map = Map<String, dynamic>();
    map['uid'] = this.uid;
    map['name'] = this.name;
    map['leader'] = this.leader;
    map['members'] = this.members;
    map['groupCreated'] = this.groupCreated;
    return map;
  }

  GroupModel.fromMap(Map<String, dynamic> map) {
    this.uid = map['uid'];
    this.name = map['name'];
    this.leader = map['leader'];
    var mem = <String>[];
    (map['members'] as List).map((e) {
      mem.add(e.toString());
    });
    this.members = mem;
    this.groupCreated = map['groupCreated'];
  }
}