import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:teams/models/message.dart';
import 'package:teams/models/user.dart';

class FirebaseMethods {

  final FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  /// User class
  UserModel userModel = UserModel();

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = await auth.currentUser;
    return currentUser;
  }

  Future<User> signInWithGoogle() async {
    GoogleSignInAccount signInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential userCredential = await auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<bool> authenticateUser(User user) async {

    QuerySnapshot result = await FirebaseFirestore.instance.collection("user").where("email", isEqualTo: user.email).get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;

  }

  Future<void> addDataToDB(User user) async {
    userModel = UserModel(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
    );

    FirebaseFirestore
        .instance
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap(userModel));
  }

  Future<void> signOut() async {
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    return await auth.signOut();
  }

  Future<List<UserModel>> fetchAllUsers(User currentUser) async {
    var userList = <UserModel>[];

    QuerySnapshot querySnapshot =
    await firebaseFirestore.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(UserModel.fromMap(querySnapshot.docs[i].data()));
      }
    }
    return userList;
  }

  Future<void> addMessageToDb(
      Message message, UserModel sender, UserModel receiver) async {
    var map = message.toMap();

    await firebaseFirestore
        .collection("messages")
        .doc(message.senderId)
        .collection(message.receiverId)
        .add(map);

    return await firebaseFirestore
        .collection("messages")
        .doc(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }
}