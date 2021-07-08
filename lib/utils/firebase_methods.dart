import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:teams/models/contact.dart';
import 'package:teams/models/group.dart';
import 'package:teams/models/message.dart';
import 'package:teams/models/user.dart';
import 'package:teams/utils/utils.dart';

class FirebaseMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  GoogleSignIn googleSignIn = GoogleSignIn();

  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  static final CollectionReference userCollection =
      firebaseFirestore.collection("users");

  /// User class
  UserModel userModel = UserModel();

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = await auth.currentUser;
    return currentUser;
  }

  Future<UserModel> getUserDetails() async {
    User currentUser = await getCurrentUser();

    print(currentUser.uid);

    DocumentSnapshot documentSnapshot =
        await userCollection.doc(currentUser.uid).get();

    print(documentSnapshot.data());

    return UserModel.fromMap(documentSnapshot.data());
  }

  Future<UserModel> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await firebaseFirestore.collection("users").doc(id).get();
      return UserModel.fromMap(documentSnapshot.data());
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User> signInWithGoogle() async {
    GoogleSignInAccount signInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential userCredential = await auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection("user")
        .where("email", isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDB(User user) async {
    userModel = UserModel(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
    );

    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap(userModel));
  }

  Future<bool> signOut() async {
    try {
      await googleSignIn.signOut();
      await auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    firebaseFirestore.collection("users").doc(userId).update({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      firebaseFirestore.collection("users").doc(uid).snapshots();

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

    addToContacts(senderId: message.senderId, receiverId: message.receiverId);

    return await firebaseFirestore
        .collection("messages")
        .doc(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  DocumentReference getContactsDocument({String of, String forContact}) =>
      firebaseFirestore
          .collection("users")
          .doc(of)
          .collection("contacts")
          .doc(forContact);

  addToContacts({String senderId, String receiverId}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exists
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: senderId, forContact: receiverId)
          .set(receiverMap);
    }
  }

  Future<void> addToReceiverContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      //does not exists
      Contact senderContact = Contact(
        uid: senderId,
        addedOn: currentTime,
      );

      var senderMap = senderContact.toMap(senderContact);

      await getContactsDocument(of: receiverId, forContact: senderId)
          .set(senderMap);
    }
  }

  Stream<QuerySnapshot> fetchContacts({String userId}) => firebaseFirestore
      .collection("users")
      .doc(userId)
      .collection("contacts")
      .snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween({
    @required String senderId,
    @required String receiverId,
  }) =>
      firebaseFirestore
          .collection("messages")
          .doc(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();


  Future<String> createGroup(String groupName, UserModel user) async {
    String retVal = "error";
    List<String> members = List();
    List<String> groups = List();
    try {
      members.add(user.uid);
      DocumentReference _docRef;
      _docRef = await firebaseFirestore.collection("groups").add({
        'name': groupName.trim(),
        'leader': user.uid,
        'members': members,
        'groupCreated': Timestamp.now(),
      });
      await firebaseFirestore.collection("groups").doc(_docRef.id).update({
        'uid': _docRef.id,
      });
      groups.add(_docRef.id);
      await firebaseFirestore.collection("users").doc(user.uid).update({
        'groups': FieldValue.arrayUnion(groups),
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }
    return retVal;
  }


  Future<String> joinGroup(String groupId, UserModel user) async {
    String retVal = "error";
    List<String> members = List();
    List<String> groups = List();
    try {
      members.add(user.uid);
      await firebaseFirestore.collection("groups").doc(groupId).update({
        'members': FieldValue.arrayUnion(members),
      });
      groups.add(groupId.trim());
      await firebaseFirestore.collection("users").doc(user.uid).update({
        'groups': FieldValue.arrayUnion(groups),
      });
      retVal = "success";
    } on PlatformException catch (e) {
      retVal = "Make sure you have the right group ID!";
      print(e);
    } catch (e) {
      print(e);
    }
    return retVal;
  }


  Future<GroupModel> getGroupData(id) async {
    DocumentSnapshot documentSnapshot =
    await firebaseFirestore.collection("groups").doc(id).get();

    print(documentSnapshot.data());

    return GroupModel.fromMap(documentSnapshot.data());
  }


  Future<String> leaveGroup(String groupId, UserModel user) async {
    String retVal = "error";
    List<String> members = List();
    List<String> groups = List();
    try {
      members.add(user.uid);
      await firebaseFirestore.collection("groups").doc(groupId).update({
        'members': FieldValue.arrayRemove(members),
      });
      groups.add(groupId.trim());
      await firebaseFirestore.collection("users").doc(user.uid).update({
        'groups': FieldValue.arrayRemove(groups),
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }
    return retVal;
  }

}
