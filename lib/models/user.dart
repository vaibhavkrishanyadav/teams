
// A user model user for mapping user data from firebase

class UserModel {
  String uid, name, email, username, status;
  int state;
  List<String> groups;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.username,
    this.status,
    this.state,
    this.groups,
});

  Map toMap(UserModel userModel) {
    var data = Map<String, dynamic>();
    data['uid'] = userModel.uid;
    data['name'] = userModel.name;
    data['email'] = userModel.email;
    data['username'] = userModel.username;
    data['status'] = userModel.status;
    data['state'] = userModel.state;
    data['groups'] = userModel.groups;
    return data;
  }

  UserModel.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.username = mapData['username'];
    this.status = mapData['status'];
    this.state = mapData['state'];
    var gr = <String>[];
    (mapData['groups'] as List).forEach((e) {
      gr.add(e.toString());
    });
    this.groups = gr;
  }
}